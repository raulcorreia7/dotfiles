# Shared skills

Place portable agent skills in one directory per skill:

```text
skills/
`-- example/
    `-- SKILL.md
```

The installer exposes this directory as `~/.agents/skills`, which is discovered
by both Codex and OpenCode.
