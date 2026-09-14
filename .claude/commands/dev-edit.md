**Positioning:** This is the informal, drafting-time developmental pass on a single chapter, useful while the manuscript is still growing. The formal pipeline stage 3 is `/story-dev-edit` (whole-manuscript, developmental altitude only, critique loop, persisted output). This pass deliberately ranges wider, from structure down to sentence-level showing-vs-telling, because it serves revision during drafting, before the pipeline starts. Findings go to the chat; nothing is persisted.

**Before starting:** This task benefits from deep reasoning. If you are on a mid- or low-tier model (e.g. Sonnet or Haiku), let the author know and suggest switching to the strongest available model with `/model` before proceeding. Wait for their response.

Locate the file to edit from "$ARGUMENTS":
- If a `Chapters/` folder exists, find the file whose name starts with or matches the argument.
- If no `Chapters/` folder exists (short story), look for the file in the story root.
- If ambiguous, list matches and ask.

Then read:
- `_Index.md` (the story bible: premise, themes, world rules, character voice, locked decisions, developmental focus)
- `CLAUDE.md` in this story folder (process notes only; the bible lives in `_Index.md`)
- The preceding chapter if it exists (for continuity context)
- Any Character files for characters appearing in this chapter (for voice drift checks)
- The writing-style skill at `../.claude/skills/writing-style/SKILL.md` (author's aesthetic — use this to calibrate every finding)

Perform a **developmental editing pass** on the chapter. Do not rewrite. Return structured findings only — the author decides what to act on.

---

## Developmental Edit Report: $ARGUMENTS

### Structure & Pacing
Note scenes that stall without narrative purpose, or significant moments that feel rushed. Be specific about which paragraph or beat.

### Showing vs Telling
Quote instances where an emotional beat is told rather than shown. Suggest the showing approach briefly.

### Dialogue
Flag:
- On-the-nose dialogue (characters saying exactly what they mean or feel)
- Exposition dumps disguised as conversation
- Voice drift from the character's established speech pattern (check the Character files and the craft & voice notes in `_Index.md`)

### POV Consistency
Flag any head-hopping or POV slippage if the story uses a limited perspective.

### Repetition
List repeated words, phrases, or ideas within this chapter. Group by type (word-level vs. idea-level).

### Continuity
Flag anything that conflicts with established facts from `_Index.md`, character files, or the timeline.

### Story-Specific Focus
Apply the developmental priorities recorded in this story's `_Index.md` (a Developmental focus or similar section). Note findings under each listed priority. If the bible records none, say so in one line and move on.

### Strengths
Note what is working well. Developmental editing is not only corrective.

---

Do not apply changes. Present findings only.
