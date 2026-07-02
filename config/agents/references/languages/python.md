# Python

## Defaults

- Follow local formatter, linter, type checker, packaging, and test conventions.
- Prefer simple functions and explicit data flow.
- Use type hints where the repo uses them or where they clarify contracts.
- Avoid clever metaprogramming.
- Avoid mutable default arguments.
- Validate external data at boundaries.
- Keep IO, network, database, and framework code at the edge when practical.
- Prefer context managers for resources.
- Prefer standard library before dependencies.

## Comments

- Use `#` line comments for implementation intent.
- Use PEP 257 docstrings for modules, classes, public functions, and non-obvious contracts.
- Do not use triple-quoted strings as block comments.
- Keep inline comments rare.
- Follow `../comments/comments.md` for shared comment quality, freshness, markers, TODOs, links, placement, and tone.

## Types

- Use dataclasses or typed models when they clarify domain data.
- Use protocols only when they make a real seam clearer.
- Avoid over-broad `Any`.
- Avoid inheritance when composition or functions are clearer.

## Errors

- Catch specific exceptions.
- Do not hide failures with broad `except Exception`.
- Preserve traceability.
- Do not log secrets.

## Checks

Use local commands first:

```bash
pytest
python -m pytest
ruff check .
ruff format --check .
mypy .
pyright
```

## Sources

- PEP 8.
- PEP 257.
- Project formatter/linter/type-checker config.
