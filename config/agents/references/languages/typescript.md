# TypeScript / JavaScript

## Defaults

- Prefer TypeScript for typed project code when the repo uses it.
- Use existing lint, formatter, tsconfig, test framework, and module style.
- Prefer precise domain types over broad `any`.
- Avoid `any` unless crossing an untyped boundary and local convention allows it.
- Validate unknown external data before trusting it.
- Keep async errors explicit.
- Prefer small pure helpers for domain logic.
- Keep framework, IO, and provider code at the edge when practical.
- Do not add state managers, abstractions, decorators, or generic helpers without real pressure.

## TSConfig Strictness

- Repo `tsconfig` wins. Do not loosen compiler strictness to make a local edit pass.
- For new TypeScript projects or new strict subprojects, use high-strictness compiler settings by default.
- Prefer fixing strictness errors with narrower types, guards, parser/validator boundaries, or better API contracts. Avoid `as`, `!`, and `any` unless there is a real boundary or compatibility reason.
- Treat strictness migrations as behavior-risk work. Stage them separately from feature changes and keep escape hatches narrow and documented.

Default baseline for high-quality new TypeScript code:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitOverride": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "forceConsistentCasingInFileNames": true,
    "isolatedModules": true,
    "verbatimModuleSyntax": true
  }
}
```

These high-strictness flags are intentional:

| Option | Why |
|---|---|
| `noUncheckedIndexedAccess` | Adds `undefined` to unchecked index-signature and indexed access reads. Useful for maps, arrays, env vars, and dictionaries. |
| `exactOptionalPropertyTypes` | Distinguishes a missing optional property from a property explicitly set to `undefined`. Useful for DTOs, patch objects, and config. |
| `noPropertyAccessFromIndexSignature` | Forces bracket access for fields only known through an index signature. Useful when dictionary keys are uncertain. |
| `noUnusedLocals` / `noUnusedParameters` | Good for apps and libraries when the repo does not already rely on ESLint for unused checks. |

Use `isolatedModules` when a bundler or test runner transpiles files independently. It catches TypeScript patterns that can be unsafe for single-file transpilers. Use `verbatimModuleSyntax` with explicit `type` imports/exports when the project uses modern TypeScript module emit; it makes type-only imports visible in source instead of relying on import elision.

Relax only with a clear reason:

- generated code that cannot be changed;
- third-party compatibility surfaces;
- legacy migrations staged behind a plan;
- test fixtures where strictness adds noise without improving confidence.

Avoid suppressions when a narrower type, guard, parser, or contract fix is practical. If `@ts-expect-error` is unavoidable, keep it one-line, reasoned, and tied to a real boundary.

Use typescript-eslint as a complement, not a replacement for the compiler:

- Start with `recommended-type-checked` when the project already supports typed linting.
- Consider `strict-type-checked` only for teams comfortable with TypeScript and willing to maintain opinionated lint rules.
- Do not enable `all`; it is intentionally not a recommended project baseline.
- Keep stylistic lint rules separate from type-safety rules so formatting and correctness failures are easy to triage.

## Files And Folders

- Repo conventions win. When creating new TypeScript files without a local convention, use `snake_case`.
- Prefer noun-based file and folder names, such as `customer_order.ts`, over action names such as `create_customer_order.ts`.
- Use dot suffixes for stable subcategories when useful: `customer_order.spec.ts`, `customer_order.test.ts`, `customer_order.mock.ts`, `customer_order.internal.ts`.
- Avoid `camelCase` and `PascalCase` filenames unless matching an existing framework or repo convention.
- Avoid renaming existing files only to normalize case. On case-insensitive file systems, casing-only renames can be noisy and risky.

## Comments

- Use `//` for implementation intent.
- Use `/** ... */` JSDoc or TSDoc for exported APIs when types do not fully explain behavior.
- Avoid `/* ... */` implementation blocks unless local style already uses them.
- Prefer names and narrow types over comments that explain ordinary data shape.
- Keep `@ts-expect-error` rare, narrow, and reasoned; prefer fixing the type boundary.
- Follow `../comments/comments.md` for shared comment quality, freshness, markers, TODOs, links, placement, and tone.

## Imports

- Follow existing import ordering.
- Do not introduce barrel files unless the repo already uses them safely.
- Avoid circular dependencies.
- Prefer named imports for frequently used symbols with clear names.
- Use namespace imports when they make a large API or common symbol names clearer.
- Use `import type` / `export type` when a symbol is type-only and local tooling expects explicit type imports.

## Types

- Use discriminated unions for meaningful variants.
- Use `unknown` for untrusted values until narrowed.
- Avoid boolean parameter soup; prefer named options when it improves readability.
- Avoid over-generic types that make call sites harder to read.
- Prefer inference for obvious local values; add annotations at public boundaries, exported functions, async return contracts, and places where inference would hide intent.
- Use primitive type names: `string`, `number`, `boolean`; avoid boxed `String`, `Number`, `Boolean`.
- Model optional data explicitly. Check for `undefined` before using optional properties.
- Prefer `readonly` and immutable shapes when mutation is not part of the contract.
- Avoid enums for new domain modeling unless the repo already uses them consistently; string literal unions are often simpler and easier to serialize.

## Modules And API Shape

- Prefer modules with explicit imports/exports over TypeScript `namespace`.
- Keep exported surface small. Export only symbols used outside the module.
- Prefer named exports unless the repo or framework convention requires default exports.
- Avoid container classes used only for namespacing; export functions, constants, and types directly.

## Errors

- Preserve error contracts.
- Do not swallow promise rejections.
- Add context without leaking secrets.

## Runtime Boundaries

- Validate external data at boundaries: HTTP, forms, storage, env vars, messages, files, and third-party SDK responses.
- Treat parsed JSON and caught errors as `unknown` until narrowed.
- Keep parsing/validation close to IO; keep internal domain functions typed and narrow.
- Do not trust generated client types more than the runtime source they represent.

## Checks

Use local commands first:

```bash
npm test
npm run test
npm run typecheck
npm run lint
```

or the repo's package manager equivalents.

## Sources

- TypeScript Blackbook: https://unional.github.io/typescript-blackbook/docs/
- TypeScript Blackbook file/folder naming convention: https://unional.github.io/typescript-blackbook/docs/guidelines/files_and_folders/naming-convention/
- TypeScript TSConfig Reference: https://www.typescriptlang.org/tsconfig/
- TypeScript TSConfig `strict`: https://www.typescriptlang.org/tsconfig/strict.html
- TypeScript TSConfig `noUncheckedIndexedAccess`: https://www.typescriptlang.org/tsconfig/noUncheckedIndexedAccess.html
- TypeScript TSConfig `exactOptionalPropertyTypes`: https://www.typescriptlang.org/tsconfig/exactOptionalPropertyTypes.html
- TypeScript TSConfig `isolatedModules`: https://www.typescriptlang.org/tsconfig/isolatedModules.html
- TypeScript TSConfig `verbatimModuleSyntax`: https://www.typescriptlang.org/tsconfig/verbatimModuleSyntax.html
- TypeScript Handbook, Everyday Types: https://www.typescriptlang.org/docs/handbook/2/everyday-types.html
- TypeScript Handbook, Narrowing: https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- typescript-eslint shared configs: https://typescript-eslint.io/users/configs/
- Google TypeScript Style Guide: https://google.github.io/styleguide/tsguide.html
- TypeScript project style/config in the repo.
