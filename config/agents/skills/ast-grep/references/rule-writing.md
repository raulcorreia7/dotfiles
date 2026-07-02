# ast-grep Rule Writing

Use this reference when writing, debugging, or explaining ast-grep patterns and YAML rules. Official ast-grep docs and installed CLI help are the source of truth when behavior differs.

## Contents

- Command Choice
- Patterns
- YAML Rules
- Rule Categories
- Debugging
- Safe Rewrites
- Examples
- Pitfalls

## Command Choice

- Verify availability first: `command -v ast-grep`.
- Simple structural search: `ast-grep run --pattern '<pattern>' --lang <lang> <path>`.
- Complex structural search: `ast-grep scan --inline-rules '<yaml>' <path>` or `ast-grep scan --rule <rule.yml> <path>`.
- Rule tests: `ast-grep test --test-dir <dir>` when a repo has ast-grep test fixtures.
- AST inspection: `ast-grep run --pattern '<sample>' --lang <lang> --debug-query=ast|cst|pattern`.
- Prefer `--json=stream` for machine parsing and `--max-results <n>` for initial broad probes.

## Patterns

- Patterns are code-shaped and must be parseable in the selected language.
- Quote patterns with single quotes in shell commands so `$META` is not expanded by the shell.
- `$A` captures one named AST node.
- `$$OP` captures one unnamed node, such as an operator, when the grammar supports that shape.
- `$$$ARGS` captures zero or more nodes, such as arguments, parameters, or statements.
- `$_` and other underscore-prefixed metavariables are non-capturing and may match different content.
- Reusing a metavariable name requires equal syntax, e.g. `$A == $A` matches repeated structure.

## YAML Rules

Minimal scan rule:

```yaml
id: no-console-log
language: TypeScript
rule:
  pattern: console.log($$$ARGS)
message: "Avoid console.log in committed code"
severity: warning
```

Useful top-level fields:

| Field | Use |
|---|---|
| `id` | Stable rule identifier |
| `language` | Parser and file-extension selection |
| `rule` | Required rule object |
| `constraints` | Filters for captured single metavariables |
| `utils` | Local utility rules referenced by `matches` |
| `fix` | Rewrite template |
| `message`, `note`, `severity` | Lint-style reporting |
| `files`, `ignores` | Rule-level path scoping |

Do not prefix rule `files` or `ignores` globs with `./`; ast-grep treats them as relative to the project root.

## Rule Categories

Atomic rules match a node directly:

```yaml
rule:
  pattern: console.log($ARG)
```

```yaml
rule:
  kind: call_expression
```

```yaml
rule:
  regex: ^use[A-Z].*
```

Relational rules match context:

```yaml
rule:
  pattern: console.log($$$ARGS)
  inside:
    kind: method_definition
    stopBy: end
```

```yaml
rule:
  kind: function_declaration
  has:
    pattern: await $EXPR
    stopBy: end
```

Composite rules combine sub-rules:

```yaml
rule:
  all:
    - kind: function_declaration
    - has:
        pattern: await $EXPR
        stopBy: end
    - not:
        has:
          pattern: try { $$$BODY } catch ($ERR) { $$$HANDLER }
          stopBy: end
```

Use explicit `all` when rule order matters for metavariables or debugging clarity. Plain rule objects are logically conjunctive, but matching order can be surprising with relational rules.

## Debugging

- If no matches appear, first simplify to a direct `pattern`.
- If a `kind` fails, inspect a representative sample with `--debug-query=ast` or `--debug-query=cst`.
- If metavariables are missing, check that they occupy a whole AST node and use valid uppercase names.
- If relational rules miss nested content, add or verify `stopBy: end`.
- If a pattern is ambiguous or incomplete, use object-style pattern with `context`, `selector`, or `strictness`.
- If output is too broad, add `files`, `ignores`, `constraints`, `inside`, or `has` rather than post-filtering text.

## Safe Rewrites

One-off rewrite preview:

```bash
ast-grep run --pattern '$OBJ && $OBJ()' --rewrite '$OBJ?.()' --lang ts --interactive src
```

Rule-based fix:

```yaml
id: console-to-logger
language: TypeScript
rule:
  pattern: console.log($$$ARGS)
fix: logger.log($$$ARGS)
message: "Use logger.log instead of console.log"
severity: warning
```

Use `--update-all` only after explicit approval and after a scoped preview or test proves the rewrite.

## Examples

Find calls with any number of arguments:

```bash
ast-grep run --pattern 'console.log($$$ARGS)' --lang tsx src
```

Find React state updates inside effects:

```yaml
id: set-state-inside-effect
language: Tsx
rule:
  pattern: $SETTER($VALUE)
  inside:
    pattern: useEffect($$$ARGS)
    stopBy: end
constraints:
  SETTER:
    regex: ^set[A-Z].*
```

Find async functions with `await`:

```yaml
id: async-function-with-await
language: TypeScript
rule:
  all:
    - kind: function_declaration
    - has:
        pattern: await $EXPR
        stopBy: end
```

Find a pattern missing expected error handling:

```yaml
id: await-without-try-catch
language: TypeScript
rule:
  all:
    - has:
        pattern: await $EXPR
        stopBy: end
    - not:
        inside:
          pattern: try { $$$BODY } catch ($ERR) { $$$HANDLER }
          stopBy: end
```

## Pitfalls

- Do not use ast-grep if `command -v ast-grep` fails.
- Do not use `sg` as the only binary check; it can refer to another system command.
- Do not use ast-grep for simple literal search where grep-like text search is clearer and cheaper. Use `rg` when available.
- Do not forget shell quoting around `$META`.
- Do not assume JavaScript `kind` names apply to Python, Rust, Go, or TSX.
- Do not let generated rules scan the whole repo first; test on snippets and scope paths.
- Do not commit generated rule files unless the user asked for persistent rules.
