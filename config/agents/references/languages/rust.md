# Rust

## Defaults

- Follow local `rustfmt`, Clippy, crate layout, and API conventions.
- Prefer clear ownership over clever lifetime tricks.
- Use the type system to make invalid states hard to represent.
- Keep public API small and predictable.
- Prefer standard library before dependencies.
- Avoid unnecessary macros.
- Avoid cloning to silence the borrow checker unless the cost and intent are acceptable.
- Do not use `unsafe` unless required and justified.

## Comments

- Use `//` for implementation intent.
- Use `///` for public item docs and `//!` for module or crate docs.
- Require `SAFETY:` comments around `unsafe` rationale.
- Document panics, errors, and safety contracts when they are part of the public contract.
- Follow `../comments/comments.md` for shared comment quality, freshness, markers, TODOs, links, placement, and tone.

## Errors

- Use `Result` for recoverable errors.
- Preserve source errors when useful.
- Do not panic in library code unless the contract justifies it.
- Keep error messages actionable and non-secret.

## APIs

- Preserve semver expectations.
- Document public behavior and examples where useful.
- Prefer explicit conversions and trait bounds that callers can understand.

## Checks

Use local commands first:

```bash
cargo test
cargo clippy -- -D warnings
cargo fmt --check
```

## Sources

- Rust API Guidelines.
- Rust standard library and repo conventions.
