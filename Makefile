SHELL := $(SHELL) -e

# Help
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

dependencies: asdf

asdf:  ## Update plugins, add plugins, install plugins, set local, reshim
	@echo "Updating asdf plugins..."
	@asdf plugin update --all >/dev/null 2>&1 || true

	@echo "Adding asdf plugins..."
	@cut -d" " -f1 .tool-versions | xargs -I{} asdf plugin add {} >/dev/null 2>&1 || true

	@echo "Installing asdf tools..."
	@cat .tool-versions | xargs -I{} bash -c 'asdf install {}'

	@echo "Setting local package versions..."
	@cat .tool-versions | xargs -I{} bash -c 'asdf set {}'

	@echo "Reshimming.."
	@asdf reshim

hooks:  ## Install git hooks (pre-commit)
	@pre-commit install
	@pre-commit install --hook-type commit-msg

	# Install environments for all available hooks now (rather than when they are first executed)
	@pre-commit install --install-hooks

pre-commit:  ## Run pre-commit against all files
	@pre-commit run -a

build:  ## Run `mkdocs build` in a poetry virtual environment
	mkdocs build

serve: ## Run `mkdocs serve` in a poetry virtual environment
	mkdocs serve

serve-dirty: ## Run `mkdocs serve` in a poetry virtual environment
	mkdocs serve --dirty

venv:
	python3 -m venv .venv
	source .venv/bin/activate
	pip install -r requirements.txt
