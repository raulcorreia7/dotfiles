# Coding Standards

## Dependency Addition
- Prefer standard library and existing dependencies first
- Add dependencies only for clear net value now
- Record rationale: problem solved, why existing stack is insufficient, maintenance/security/license fit, runtime/build impact
- Keep versions explicit; rely on lockfiles
- Remove unused dependencies promptly

## Library, Framework, and Tool Selection
- Prefer battle-tested, maintained options with strong docs
- Avoid reinventing the wheel unless explicitly requested or truly required
- Prefer latest stable versions when compatibility/migration cost is reasonable
- Verify version and maintenance status via official docs/registries/release notes and MCP research tools when needed
- If not using latest stable, document the pragmatic reason

## Config vs Constants
- Config: environment-specific, secret, deploy-varying, and tunable values
- Constants: stable domain/protocol invariants
- Inline literals only when obvious and local (`0`, `1`, `""`, `true`)
- Validate config once at startup and pass explicitly through boundaries

## Cache Semantics
- Treat cache as disposable by default; cache must not be the only recoverable source
- If cache is a runtime source, define freshness checks, retention policy, and rehydration path
- Cleanup rules must protect active/required artifacts or provide deterministic recovery

## TODO/HACK Hygiene
- No orphan TODO/HACK markers
- Every TODO/HACK includes owner or issue reference
- TODOs include intent and exit condition
- HACKs include constraint and removal condition

## Anti-Patterns (Non-Negotiable)
- Deep nesting
- Magic numbers
- Hidden dependencies
- Hardcoded environment assumptions/values
- Premature abstraction

## Formatting, Linting, and Style
- Run formatter before commit; formatter output is source of truth
- Fix linter errors; do not introduce new warnings in changed files
- Prefer explicit names and readable multi-line code
- Keep lines readable (about 80-100 chars when practical)
- Keep indentation, spacing, imports, and quote/bracket style consistent
- Avoid style-only churn in behavior-focused changes

### Switch/Case Style
When the language supports switch/case statements:
- Wrap each case body in braces `{}`
- Include explicit `break` after the closing brace
- Prevents fallthrough bugs and scopes case-local variables

```cpp
switch (fmt) {
    case Format::png:
    {
        ok = stbi_write_png_to_func(write_callback, &ctx, img.width, img.height, 4,
                                    img.pixels.data(), img.width * 4);
        name = "PNG";
    }
    break;
    case Format::tga:
    {
        ok = stbi_write_tga_to_func(write_callback, &ctx, img.width, img.height, 4,
                                    img.pixels.data());
        name = "TGA";
    }
    break;
    case Format::bmp:
    {
        ok = stbi_write_bmp_to_func(write_callback, &ctx, img.width, img.height, 4,
                                    img.pixels.data());
        name = "BMP";
    }
    break;
}
```
