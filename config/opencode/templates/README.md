# Project Name

> One-line description of what this project does.

**Status**: [WIP | Alpha | Beta | Stable]

## Quick Start

```bash
# Minimal commands to get running
make install
make dev
```

## Features

- Key feature 1
- Key feature 2
- Key feature 3

## Installation

### Prerequisites

- Requirement 1 (e.g., Node.js 20+)
- Requirement 2 (e.g., PostgreSQL 15)

### Steps

```bash
# Clone and setup
git clone https://github.com/org/repo.git
cd repo
make install

# Configure
cp .env.example .env
# Edit .env with your values

# Run
make dev
```

## Usage

```language
# Basic usage example
```

See [docs/USAGE.md](docs/USAGE.md) for advanced usage.

## Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start development server |
| `make test` | Run test suite |
| `make build` | Build for production |
| `make check` | Lint + typecheck + test |
| `make clean` | Remove build artifacts |

## Architecture

```
├── src/
│   ├── module-a/       # Description
│   └── module-b/       # Description
├── tests/
├── docs/
├── scripts/
├── Makefile
└── README.md
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture.

## Configuration

See [.env.example](.env.example) for required environment variables.

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_PORT` | Server port | `3000` |
| `APP_LOG_LEVEL` | Log verbosity | `info` |

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## License

MIT
