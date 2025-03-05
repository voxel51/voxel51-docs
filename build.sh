#!/bin/bash

# Basic settings
set -e

# Constant variables and configuration
readonly ROOT_DIR="$(pwd)"
readonly SCRIPT_DIR="$ROOT_DIR"
readonly WORKSPACE_DIR="$(dirname "$ROOT_DIR")/temp_workspace"
readonly FIFTYONE_DIR="$WORKSPACE_DIR/fiftyone"
readonly API_DOC_DIR="$WORKSPACE_DIR/api_docs"
readonly TS_API_DOC_DIR="$WORKSPACE_DIR/ts_api_docs"
readonly NODE_VERSION=17.9.0

# Color definitions for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Default values for command line parameters
VERBOSE=0
SKIP_CLONE=0
SKIP_PYTHON_API=0
SKIP_TS_API=0
VERSION="1.3.0"
REPO_URL="https://github.com/voxel51/fiftyone.git"
VENV_ACTIVATE="${HOME}/virtualenvs/vdoc-mkdocs/bin/activate"

parse_args() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=1
                set -x  # Enable bash debug mode
                shift
                ;;
            --skip-clone)
                SKIP_CLONE=1
                shift
                ;;
            --version)
                VERSION="$2"
                shift 2
                ;;
            --repo-url)
                REPO_URL="$2"
                shift 2
                ;;
            --venv)
                VENV_ACTIVATE="$2"
                shift 2
                ;;
            --skip-python-api)
                SKIP_PYTHON_API=1
                shift
                ;;
            --skip-ts-api)
                SKIP_TS_API=1
                shift
                ;;
            --skip-all-api)
                SKIP_PYTHON_API=1
                SKIP_TS_API=1
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to display script usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Build documentation for the FiftyOne project.

Options:
    -h, --help             Show this help message
    -v, --verbose          Enable verbose output
    --skip-clone           Skip repository cloning
    --skip-python-api      Skip Python API documentation build
    --skip-ts-api          Skip TypeScript API documentation build
    --skip-all-api         Skip all API documentation builds
    --version VERSION      Specify the version number (default: 1.3)
    --venv VENV_ACTIVATE   Specify the path to your venv's activate script (default: \$HOME/virtualenvs/vdoc-mkdocs/bin/activate)
    --repo-url URL         Specify the repository URL (default: https://github.com/voxel51/fiftyone.git)
EOF
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()

    # Check for git
    if ! command_exists git; then
        missing_deps+=("git")
    fi

    # Check for python dependencies
    if ! command_exists python3; then
        missing_deps+=("python3")
    fi

    if ! command_exists pydoctor; then
        missing_deps+=("pydoctor")
    fi

    if ! command_exists mkdocs; then
        missing_deps+=("mkdocs")
    fi

    # Check for Node.js and npm
    if ! command_exists node; then
        missing_deps+=("node")
    fi

    if ! command_exists npm; then
        missing_deps+=("npm")
    fi

    # If there are missing dependencies, print them and exit
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies:"
        printf '%s\n' "${missing_deps[@]}"
        log_error "Please install missing dependencies and try again."
        exit 1
    fi
}

# Function to check and activate virtual environment
check_venv() {
    if [ ! -f "$VENV_ACTIVATE" ]; then
        # Try again with /bin/activate
        VENV_ACTIVATE="$VENV_ACTIVATE/bin/activate"
        if [ ! -f "$VENV_ACTIVATE" ]; then
            log_error "Virtual environment activation script not found at: $VENV_ACTIVATE"
            exit 1
        fi
    fi
    log_info "Activating virtual environment..."
    # shellcheck source=/dev/null
    source "$VENV_ACTIVATE" || {
        log_error "Failed to activate virtual environment"
        exit 1
    }
}

# Main execution starts here
main() {
    parse_args "$@"

    log_info "Starting documentation build process..."

    # Check and activate virtual environment
    check_venv

    # Check dependencies
    log_info "Checking dependencies..."
    check_dependencies

    # Create workspace directory as a sibling to ROOT_DIR
    mkdir -p "$WORKSPACE_DIR"
    log_info "Created temporary workspace directory at: $WORKSPACE_DIR"

    # Clone repository if not skipped
    if [ $SKIP_CLONE -eq 0 ]; then
        log_info "Cloning fiftyone repository..."
        if [ -d "$FIFTYONE_DIR" ]; then
            rm -rf "$FIFTYONE_DIR"
        fi
        git clone --progress --depth=1 --single-branch --branch=main "$REPO_URL" "$FIFTYONE_DIR" || {
            log_error "Failed to clone repository"
            exit 1
        }
    fi

    # Create output directories if they don't exist
    log_info "Creating output directories..."
    mkdir -p "$API_DOC_DIR"
    mkdir -p "$TS_API_DOC_DIR"

    # Build Python API documentation
    if [ $SKIP_PYTHON_API -eq 0 ]; then
      log_info "Building Python API documentation with pydoctor..."
      cd "$FIFTYONE_DIR" || exit 1

      # Capture pydoctor output and status
      pydoctor \
          --project-name=FiftyOne \
          --project-version="$VERSION" \
          --project-url=https://github.com/voxel51/ \
          --html-viewsource-base="https://github.com/voxel51/fiftyone/tree/v${VERSION}" \
          --html-base-url=https://docs.voxel51.com/api \
          --html-output="$API_DOC_DIR" \
          --docformat=google \
          --intersphinx=https://docs.python.org/3/objects.inv \
          fiftyone || true

      # Check if the output directory was created successfully
      if [ ! -d "$API_DOC_DIR" ] || ! ls "$API_DOC_DIR"/*.html >/dev/null 2>&1; then
          log_error "Pydoctor failed to generate documentation. Output:"
          echo "$pydoctor_output"
          exit 1
      else
          log_info "Pydoctor documentation generated successfully"
          # If you want to see the output even on success:
          if [ $VERBOSE -eq 1 ]; then
              echo "$pydoctor_output"
          fi
      fi
  fi

    # Build TypeScript API documentation
    if [ $SKIP_TS_API -eq 0 ]; then
        log_info "Building TypeScript API documentation..."
        cd "$FIFTYONE_DIR/app" || exit 1
        yarn install > /dev/null 2>&1
        yarn workspace @fiftyone/fiftyone compile
        # NODE_OPTIONS=--max-old-space-size=4096 && tsc && vite build
        npx typedoc \
            --out "$TS_API_DOC_DIR" \
            --name "FiftyOne TypeScript API" \
            --options typedoc.js \
            --theme default
        log_info "Finished typedoc build"
    else
        log_info "Skipping TypeScript API documentation build..."
    fi

    # Return to root directory and set up symlinks
    cd "$ROOT_DIR" || exit 1

    log_info "Creating symlinks..."
    # Handle symlinks based on what was built
    if [ $SKIP_PYTHON_API -eq 0 ]; then
        if [ -L docs/api ]; then
            rm docs/api
        fi
        ln -s "$API_DOC_DIR" docs/api
    fi

    if [ $SKIP_TS_API -eq 0 ]; then
        if [ -L docs/ts_api ]; then
            rm docs/ts_api
        fi
        ln -s "$TS_API_DOC_DIR" docs/ts_api
    fi

    # Embed all the images in the jupyter notebooks so we don't have to worry about
    # path references
    python jupyter-image-embed.py

    # Build final documentation
    log_info "Building documentation with mkdocs..."
    mkdocs build
    log_info "Documentation build complete!"
}

# Execute main function
main "$@"
