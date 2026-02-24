.PHONY: fmt lint markdown-lint check test test-bats hooks-install hooks-run install uninstall help

DOTFILES_DIR := $(shell pwd)
EXCLUDES := --exclude zimfw --exclude opencode
GIT_HOOKS_DIR := $(shell git rev-parse --git-path hooks 2>/dev/null)
FD_CMD := $(shell command -v fd || command -v fdfind)

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  fmt       Format shell scripts"
	@echo "  lint      Lint shell scripts"
	@echo "  markdown-lint Lint README markdown"
	@echo "  check     Run lint (CI)"
	@echo "  test      Run installer dry-run and bats smoke tests"
	@echo "  test-bats Run bats smoke tests"
	@echo "  hooks-install Install native git hook"
	@echo "  hooks-run Run native git hook checks"
	@echo "  install   Run full installation"
	@echo "  uninstall Restore backed up configs"
	@echo "  backups   List available backups"

fmt:
	@if [ -z "$(FD_CMD)" ]; then \
		echo "fd (or fdfind) is required"; \
		exit 1; \
	fi
	@$(FD_CMD) -e sh -t f . $(DOTFILES_DIR) $(EXCLUDES) -x shfmt -w
	@shfmt -w $(DOTFILES_DIR)/install
	@shfmt -w $(DOTFILES_DIR)/uninstall
	@echo "Done."

lint:
	@if [ -z "$(FD_CMD)" ]; then \
		echo "fd (or fdfind) is required"; \
		exit 1; \
	fi
	@shellcheck $(DOTFILES_DIR)/install
	@shellcheck $(DOTFILES_DIR)/uninstall
	@$(FD_CMD) -e sh -t f . $(DOTFILES_DIR) $(EXCLUDES) -x shellcheck
	@echo "Done."

markdown-lint:
	@if command -v npx >/dev/null 2>&1; then \
		npx --yes markdownlint-cli2 README.md; \
	elif command -v markdownlint-cli2 >/dev/null 2>&1; then \
		markdownlint-cli2 README.md; \
	else \
		echo "npx (Node.js) is required to fetch latest markdownlint-cli2"; \
		echo "Fallback: install markdownlint-cli2 globally if Node.js is unavailable"; \
		exit 1; \
	fi

check: lint markdown-lint

test:
	@$(DOTFILES_DIR)/install --dry-run
	@$(MAKE) test-bats

test-bats:
	@if command -v bats >/dev/null 2>&1; then \
		bats tests; \
	else \
		echo "Skipping bats tests (bats not installed)"; \
	fi

hooks-install:
	@if [ -z "$(GIT_HOOKS_DIR)" ]; then \
		echo "Not a git repository"; \
		exit 1; \
	fi
	@mkdir -p "$(GIT_HOOKS_DIR)"
	@chmod +x "$(DOTFILES_DIR)/.githooks/pre-commit"
	@ln -sfn "$(DOTFILES_DIR)/.githooks/pre-commit" "$(GIT_HOOKS_DIR)/pre-commit"
	@echo "Native pre-commit hook installed"

hooks-run:
	@"$(DOTFILES_DIR)/.githooks/pre-commit"

install:
	@$(DOTFILES_DIR)/install

uninstall:
	@$(DOTFILES_DIR)/uninstall

backups:
	@$(DOTFILES_DIR)/uninstall --list
