# Learning Record Format

Learning records live in `learning-records/` and use sequential names such as `0001-slug.md`. Create the directory lazily when the first record is needed.

Learning records capture non-obvious lessons, prior knowledge, corrected misconceptions, and mission shifts. They are not session logs.

## Template

```md
# {Short title}

{1-3 sentences describing what was learned or established, why it matters, and how it should affect future teaching.}
```

## Optional Sections

Use optional sections only when they add value:

- `Status: active | superseded by LR-NNNN`
- `Evidence`: how the user demonstrated the understanding.
- `Implications`: what this unlocks or rules out for future sessions.

## When To Write One

Write a learning record when:

- The user demonstrates real understanding of something non-trivial.
- The user discloses prior knowledge and its depth.
- A misconception is corrected.
- The mission changes in response to learning.

Do not write one for mere coverage, material already compressed into `GLOSSARY.md`, or routine activity logs.

When a later record contradicts an earlier one, mark the old record superseded rather than deleting it.
