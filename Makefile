.PHONY: fmt lint check test install help

DOTFILES_DIR := $(shell pwd)
EXCLUDES := --exclude zimfw --exclude opencode

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  fmt      Format shell scripts"
	@echo "  lint     Lint shell scripts"
	@echo "  check    Run lint (CI)"
	@echo "  test     Run installer dry-run"
	@echo "  install  Run full installation"

fmt:
	@fd -e sh -t f . $(DOTFILES_DIR) $(EXCLUDES) -x shfmt -w
	@shfmt -w $(DOTFILES_DIR)/install
	@echo "Done."

lint:
	@shellcheck $(DOTFILES_DIR)/install
	@fd -e sh -t f . $(DOTFILES_DIR) $(EXCLUDES) -x shellcheck
	@echo "Done."

check: lint

test:
	@$(DOTFILES_DIR)/install --dry-run

install:
	@$(DOTFILES_DIR)/install
