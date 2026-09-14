---
name: story-manual-revise
description: "Stress-tests a single author-decided wording change against a fixed validation gate (grammar, syntax, idiom, in-context repetition, continuity) and returns a clean/problem verdict in the terminal. It evaluates the change and anything within the pasted phrase or paragraph, never the wider chapter, and never edits any file."
when_to_use: "Use when the author is working through their own reading notes one change at a time and wants a specific, decided wording change checked before they apply it by hand. The author brings one change; the skill brainstorms options if asked, then validates the locked version. Do NOT use it to review or revise a whole chapter (use /story-line-edit or /story-copy-edit); do NOT evaluate beyond the pasted phrase or paragraph; do NOT edit any file. Follow all steps in order; do not shortcut based on this description."
effort: xhigh
disable-model-invocation: true
---

## Critical

This skill never edits any file. Every verdict and every suggested wording goes to the terminal; the author applies changes by hand. It also never evaluates the chapter as a whole. The unit it checks is the phrase or paragraph the author pastes: the change itself, plus anything else wrong within that span. The rest of the chapter is reference only, for grep checks.

## Steps

### 1. Identify the target chapter

You almost always know the chapter already, from the passage under discussion. Use that. Only ask which chapter the change is in if you genuinely cannot tell from context. Locate the file when you need to grep it:
- If a `Chapters/` folder exists, the file whose name starts with the chapter reference.
- Otherwise (short story), the file in the story root.

Do not read the whole chapter into context. You will pull only the spans you need, per change, in Step 3.

Each change the author brings runs the gate in Step 3 automatically.

### 2. Brainstorm the change (only if the note is open-ended)

If the author is still deciding, give insight, not compliance: show the specific passage in its immediate context, offer options with a recommendation, and say plainly if the original is already better or if the note is really a structural concern for `/story-dev-edit`. If the author already has the exact wording, skip straight to Step 3.

### 3. The validation gate (runs automatically on every locked change)

**This step is not optional and runs on every locked change without being asked.** The author may also trigger it explicitly ("check that"). Evaluate the change and the rest of the pasted span (the phrase or paragraph it sits in). If a check turns up a problem anywhere in that span, flag it, even when it predates the change. Do not extend the evaluation to the wider chapter. Run every check in order; the author cares most about the first three, but never skip the rest.

1. **Grammar and syntax** — correct on its own? Past-tense narration except in dialogue.
2. **Idiom** — technically correct but non-native: unnatural article use, literal prepositions, calqued idioms, awkward word order, progressive where English narration prefers the simple past. Be assertive; preserve voice.
3. **CMOS mechanics** — American conventions, Oxford comma, punctuation, dashes, ellipses, capitalization, numbers.
4. **Repetition in context** — grep the chapter for the specific new or changed words; flag an echo within a short span. Deliberate repetition per the writing-style skill is not a flag.
5. **Continuity** — does the change contradict an established fact? Check `_Index.md`, `Timeline.md`, and the Character/Location files. Escalate to a grep across chapters only when the change alters a concrete referenced detail (a name, number, object, time of day).
6. **Fit** — does the new text sit naturally against the surrounding cadence, or does the seam show? Note a craft side effect the edit introduced (a weak verb, a new echo), but the author decides; never override a deliberate choice.

Respect deliberate form throughout: whatever the writing-style skill declares the author's register (minimalism, short standalone paragraphs, perspective bleed, free indirect discourse, dark comedy, intentional repetition, and the like) is not an error. The writing-style skill at `../.claude/skills/writing-style/SKILL.md` is the authority; consult it when unsure whether a pattern is deliberate.

### 4. Verdict

Report to the terminal, tightly:
- **Clean** — passes every check; say so in one line with the final text.
- **Problem** — name the exact issue, the check it failed, and the span. Offer a fix and iterate until clean.

If a check finds a pre-existing problem in the span that the author's change did not introduce, report it as a separate flag, clearly distinguished from the locked change's verdict, and leave the fix to the author.

The author applies the change by hand. Never write to the chapter file.

## What to avoid

- **Evaluating the wider chapter.** The pasted phrase or paragraph is in scope (the change plus anything wrong within it); the rest of the chapter is reference for grep checks, nothing more.
- **Editing any file.** Verdict and wording go to the terminal; the author applies by hand.
- **Running the gate inconsistently.** Same checks, same order, every locked change.
- **Second-guessing the author's wording on taste.** The gate flags errors, idiom problems, repetition, and contradictions, not voice.
- **Loading the whole book for continuity.** Digests first; grep across chapters only when a concrete referenced detail changed.
