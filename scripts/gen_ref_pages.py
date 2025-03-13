"""Generate the code reference pages and index."""

import sys
import os
from pathlib import Path
from collections import defaultdict

import mkdocs_gen_files

# Add the source directory to the Python path
root = Path(__file__).parent.parent
src = root / "temp_workspace"
sys.path.insert(0, str(src))  # Add to Python path

src_fiftyone = src / "fiftyone"

# Add debugging to see what's happening
print(f"Python path: {sys.path}")
print(f"Looking for Python files in: {src_fiftyone}")

# Files or modules to skip - add any patterns here
SKIP_PATTERNS = [
    "service/main.py",  # Skip this specific file
    # Add more patterns as needed
]

def should_skip(file_path):
    """Check if a file should be skipped based on patterns."""
    rel_path = file_path.relative_to(src_fiftyone)
    return any(str(rel_path).endswith(pattern) for pattern in SKIP_PATTERNS)

def is_valid_package_path(path, src_dir):
    """Check if a path is a valid package path by verifying __init__.py files exist."""
    current = path.parent
    while str(current).startswith(str(src_dir)):
        init_file = current / "__init__.py"
        if not init_file.exists() and current != src_dir:
            print(f"WARNING: Missing __init__.py in {current.relative_to(src_dir)}")
            return False
        current = current.parent
    return True

# Dictionary to store module hierarchies
# Structure: {top_level: {second_level: [third_level, ...], ...}}
module_hierarchy = defaultdict(lambda: defaultdict(list))
top_level_docs = {}  # Store paths to top-level module docs

for path in sorted(src_fiftyone.rglob("*.py")):
    # Skip files matching our exclusion patterns
    if should_skip(path):
        print(f"Skipping excluded file: {path}")
        continue

    # Skip files in directories without __init__.py files
    if not is_valid_package_path(path, src_fiftyone):
        print(f"Skipping file in non-package directory: {path}")
        continue

    module_path = path.relative_to(src).with_suffix("")
    doc_path = path.relative_to(src_fiftyone).with_suffix(".md")
    full_doc_path = Path("api", doc_path)

    parts = tuple(module_path.parts)

    if parts[-1] == "__init__":
        parts = parts[:-1]
        # Skip if we end up with empty parts (root __init__.py)
        if not parts:
            continue
    elif parts[-1] == "__main__":
        continue

    identifier = ".".join(parts)

    # Build the module hierarchy for the index page
    if len(parts) >= 2:
        top_level = parts[1]  # parts[0] is 'fiftyone', parts[1] is the top-level module

        if len(parts) >= 3:
            second_level = parts[2]

            if len(parts) >= 4:
                third_level = parts[3]
                if third_level not in module_hierarchy[top_level][second_level]:
                    module_hierarchy[top_level][second_level].append(third_level)

            # Store path to second-level module (for linking)
            second_level_path = Path("api", parts[1], parts[2]).with_suffix(".md")

        # Store path to top-level module (for linking)
        top_level_path = Path("api", parts[1]).with_suffix(".md")
        top_level_docs[top_level] = top_level_path

    with mkdocs_gen_files.open(full_doc_path, "w") as fd:
        # Add a check to ensure we're not writing an empty identifier
        if not identifier.strip():
            print(f"Warning: Empty identifier for {path}, skipping")
            continue
        print("::: " + identifier, file=fd)
        print(f"Writing: {full_doc_path} for module {identifier}")

    mkdocs_gen_files.set_edit_path(full_doc_path, Path("../") / path)

# Create the index page
index_path = Path("api", "index.md")
with mkdocs_gen_files.open(index_path, "w") as index_file:
    index_file.write("# FiftyOne API Reference\n\n")
    index_file.write("Welcome to the FiftyOne API reference documentation. This section contains auto-generated API documentation for all public modules in FiftyOne.\n\n")

    # List all top-level modules
    index_file.write("## Top-Level Modules\n\n")

    for module_name in sorted(module_hierarchy.keys()):
        # Create a link to the module documentation
        rel_path = f"{module_name}/"
        index_file.write(f"### [{module_name}]({rel_path})\n\n")

        # Write a brief description of submodules (can be enhanced)
        if module_hierarchy[module_name]:
            submodules = sorted(module_hierarchy[module_name].keys())
            index_file.write(f"The `fiftyone.{module_name}` module contains the following submodules:\n\n")

            for submodule in submodules:
                submodule_path = f"{module_name}/{submodule}/"
                index_file.write(f"- [{submodule}]({submodule_path})\n")

            index_file.write("\n")

print(f"Generated index page at {index_path}")