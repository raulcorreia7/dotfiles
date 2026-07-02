---
name: teach
description: "Manual productivity skill. Use only when explicitly invoked to teach the user a topic over multiple sessions in a workspace with a mission, resources, lessons, references, learning records, and notes."
license: MIT
---

# Teach

## Job

Teach one topic over multiple sessions by maintaining a small learning workspace and producing short, interactive HTML lessons.

Inspired by Matt Pocock's `teach`; adapted for this skills pack.

## Workspace

Treat the current directory as the teaching workspace.

Use these files and directories:

- `MISSION.md`: why the user wants to learn the topic. Read `references/mission-format.md` before creating or changing it.
- `RESOURCES.md`: trusted sources and communities for the topic. Read `references/resources-format.md` before editing it.
- `GLOSSARY.md`: canonical terms the user already understands. Read `references/glossary-format.md` before editing it.
- `reference/*.html`: quick-reference documents that compress reusable knowledge.
- `learning-records/*.md`: durable insights, prior knowledge, corrected misconceptions, and mission shifts. Read `references/learning-record-format.md` before writing one.
- `lessons/*.html`: short, self-contained lessons, numbered sequentially.
- `assets/*`: reusable styles, widgets, simulators, and diagram helpers shared by lessons.
- `NOTES.md`: teaching preferences and working notes that should persist.

## Steps

1. Inspect the workspace files that exist.
2. If `MISSION.md` is missing or vague, interview the user until the real-world goal is concrete before teaching.
3. Populate or refine `RESOURCES.md` from high-trust sources before making knowledge claims. Use current sources when the topic may have changed.
4. Determine the user's zone of proximal development from the mission, learning records, glossary, notes, and explicit request.
5. Choose one tightly scoped lesson objective that gives the user a tangible win.
6. Reuse `assets/*` first. Add a shared stylesheet before creating the first lesson if none exists.
7. Create one lesson in `lessons/NNNN-slug.html`. Keep it short, attractive, printable, cited, and interactive where useful.
8. Add or update `reference/*.html` when the lesson creates reusable knowledge.
9. Write a learning record only when there is evidence of learning, prior knowledge, a corrected misconception, or a mission shift.
10. Update `GLOSSARY.md` only after the user can use the term correctly.
11. Report the lesson path, what changed, what the user should do next, and any source or confidence gaps.

## Lesson Rules

- Tie every lesson to the mission.
- Teach only the knowledge needed for the current skill.
- Prefer retrieval practice, spacing, interleaving, and tight feedback loops.
- Avoid answer-length clues in quizzes; keep choices similarly sized.
- Link lessons to related lessons and reference documents with HTML anchors.
- Include one primary high-trust source for the user to read or watch.
- Remind the user they can ask follow-up questions.

## Guardrails

- Do not rely on unsupported model memory for teachable facts when sources are available.
- Do not create generic courseware; each artifact must serve the user's mission.
- Do not treat coverage as learning. Require evidence before recording mastery.
- Confirm with the user before changing the mission.
- Respect stated preferences about not joining communities.

## References

- Read `references/mission-format.md` before creating or changing `MISSION.md`.
- Read `references/resources-format.md` before creating or changing `RESOURCES.md`.
- Read `references/glossary-format.md` before creating or changing `GLOSSARY.md`.
- Read `references/learning-record-format.md` before writing a learning record.

## Source

- Upstream: https://github.com/mattpocock/skills/tree/main/skills/productivity/teach
- License: MIT, Copyright (c) 2026 Matt Pocock.
