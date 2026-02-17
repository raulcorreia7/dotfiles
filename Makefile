.PHONY: fmt lint check test install uninstall help

DOTFILES_DIR := $(shell pwd)
EXCLUDES := --exclude zimfw --exclude opencode

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  fmt       Format shell scripts"
	@echo "  lint      Lint shell scripts"
	@echo "  check     Run lint (CI)"
	@echo "  test      Run installer dry-run"
	@echo "  install   Run full installation"
	@echo "  uninstall Restore backed up configs"
	@echo "  backups   List available backups"

fmt:
	@fd -e sh -t f . $(DOTFILES_DIR) $(EXCLUDES) -x shfmt -w
	@shfmt -w $(DOTFILES_DIR)/install
	@shfmt -w $(DOTFILES_DIR)/uninstall
	@echo "Done."

lint:
	@shellcheck $(DOTFILES_DIR)/install
	@shellcheck $(DOTFILES_DIR)/uninstall
	@fd -e sh -t f . $(DOTFILES_DIR) $(EXCLUDES) -x shellcheck
	@echo "Done."

check: lint

test:
	@$(DOTFILES_DIR)/install --dry-run

install:
	@$(DOTFILES_DIR)/install

uninstall:
	@$(DOTFILES_DIR)/uninstall

backups:
	@$(DOTFILES_DIR)/uninstall --list
