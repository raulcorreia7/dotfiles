# AI Collaboration

## Communication
- Tone: direct and professional
- Evidence: cite files/logs or mark `Unverified`
- AI drives boilerplate, patterns, and research
- I drive architecture, complex logic, security, and perf-critical work
- Prompt with context (`@file`), acceptance criteria, and examples

## Context Management
- Read file structure before diving into implementation
- Use @file for specific context, summarize for broad understanding
- Check imports and dependencies to understand relationships
- Review git history for recent changes and context
- Prefer targeted reads over loading entire files into context

## Tool Selection
- Use glob for file discovery by pattern
- Use grep for searching content across files
- Use read for examining specific files
- Use task agents for parallel research across multiple files
- Use bash for git operations and file system commands
- Batch independent operations; chain dependent ones

## Verification
- Cite files/logs as evidence or mark `Unverified`
- Verify tool outputs before proceeding
- When tools fail, report the error and stop
- Do not proceed with "best guess" on failed operations

## Assumption Handling
- Ask when requirements are ambiguous
- Detect project conventions before assuming
- Preserve existing code style and patterns
- Do not change unrelated code unless explicitly asked
