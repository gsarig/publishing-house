---
name: story-quick-clean
description: "Produces a whole-manuscript, pre-beta triage list of only obvious language errors (broken grammar, typos, wrong words, blatantly non-idiomatic phrasing, character-name inconsistencies, glaring repetition); present-only, never editing the prose."
when_to_use: "Use when the author invokes /story-quick-clean on a complete, self-revised manuscript to catch obvious language errors before a beta read (editorial stage 1.5). Whole-work only, takes no arguments. Do NOT use for per-chapter sentence-level craft, idiom refinement, or CMOS polish (use /story-line-edit or /story-copy-edit ch-XX); do NOT use for structure, pacing, or arcs (use /story-dev-edit); do NOT edit chapter prose. Follow all steps in order; do not shortcut based on this description."
disable-model-invocation: true
---

## Steps

### 1. Locate the story and gate the run

Locate the story:
- If the working directory is a story folder (contains a `Chapters/` folder or chapter files at the root), use it. Otherwise list the story folders under the vault root and ask which one.
- Ask once: "Have you finished your own self-revision? This is a quick obvious-error sweep before the beta read, not a substitute for your own pass, and not a line edit." If the draft is not complete, say so and confirm they still want to run it; a whole-manuscript triage assumes a finished draft.

### 2. Read the manuscript fresh, then the references

**This step is not optional. Always read every file fresh from disk with the Read tool at the start of every run, even if you read the same files moments ago in this conversation.** The author edits between runs; the files on disk are the only source of truth. If you cannot read the files this turn, stop and say so.

Read, in full:
- The whole manuscript: every `Chapters/*.md` in filename order, or the single root story file for a short story.
- The writing-style skill at `../.claude/skills/writing-style/SKILL.md`: the authority on the author's aesthetic. Anything it marks as intentional (short standalone paragraphs, fragments, perspective bleed, dark comedy, em-dashes, deliberate repetition, ambiguous endings) is never an error.
- This story's `CLAUDE.md` and the vault-level `CLAUDE.md`: to separate intentional choices from genuine errors.
- The canonical names in `_Characters/` and `_Locations/` (the `name:` frontmatter and the filenames): the reference for catching misspelled or varied character and location names.

Do not read `_Index.md` or other bible material; this pass is about surface language, not intent, and needs no plot or theme context.

### 3. Produce the triage list

Scan the whole manuscript and flag **only obvious errors** in these categories:

1. **Broken grammar or syntax** — subject-verb or plural agreement, tense breaks in narration, malformed or incomplete sentences, scrambled clauses that misread.
2. **Typos, spelling, wrong words** — misspellings, missing or doubled words, homophones (their/there, its/it's), wrong-word substitutions.
3. **Blatantly non-idiomatic phrasing** — only the obvious cases a fluent reader would stumble on: calqued idioms, clearly wrong articles or prepositions, word order that reads as broken English (common when the author writes in English as a second language). Leave subtle, technically-correct-but-non-native phrasing for `/story-copy-edit`.
4. **Character or location name inconsistencies** — any spelling or form that varies from the canonical `_Characters/` and `_Locations/` names.
5. **Glaring word or phrase repetition** — an obvious, distracting echo within a short span. Not stylistic repetition, not an intentional refrain. When you flag one, give the fix concretely: one or two drop-in replacements that fit the author's plain register (per the writing-style skill — no lyricism), or name which instance to cut. Never a generic "vary it."

**The discipline that defines this pass: when in doubt, leave it.** If an item is not an outright error but a matter of rhythm, flow, idiom refinement, voice, word choice, CMOS nicety, or subtle non-native phrasing, it is out of scope; it belongs to `/story-line-edit`, `/story-copy-edit`, or the later proof stage. Flag only what a competent reader would read as a mistake, not a style you would have chosen differently. Never flag anything the writing-style skill marks as deliberate form.

Write the list with the Write tool to `_reviews/_full/quick-clean/quick-clean-YYYY-MM-DD.md` (today's date), creating folders if needed. If that file already exists (a same-day re-run), suffix the filename `-pass2`, `-pass3`, and so on instead of overwriting. Do not print it to the terminal. Apply the **## Output format**.

### 4. Harden with a light critique pass

Run the **## Critique pass** once — a single round, not the multi-round loop the heavier editorial skills use; this pass is shallow enough that one sweep suffices and the author reviews every flag by hand. It refines the list only and never touches the prose.

### 5. Confirm

Print one line to the terminal only: the saved path plus a per-category flag count (or total). Nothing else: no list dump, no critique transcript. If the manuscript was clean, say so in that one line.

## Output format

```
---
stage: quick-clean
date: <YYYY-MM-DD>
---

# Quick Clean: "<title>"

<One-line scope reminder: obvious errors only; present-only; not a line edit.>

## ch-01 — <title>
- [ ] **[grammar]** "<quoted snippet>" → <what's wrong / the fix, one line>
- [ ] **[typo]** "<quoted snippet>" → <fix>
- [ ] **[idiom]** "<quoted snippet>" → <fix, naming the calque or article/preposition issue>
- [ ] **[name]** "<variant>" → canonical "<name>"
- [ ] **[repetition]** "<word/phrase>" repeated in <where> → <1–2 concrete drop-in replacements in the author's register, or which instance to cut — never a generic "vary it">

## ch-02 — <title>
- _Nothing flagged._
```

- Every flag is a Markdown task-list item (`- [ ]`) so the author can tick it off in Obsidian as each fix is applied. The `_Nothing flagged._` line stays a plain line, not a checkbox.
- Quote enough of each snippet that the author can locate it by search; do not cite line numbers (they drift).
- Tag every item with its category: `[grammar]`, `[typo]`, `[idiom]`, `[name]`, `[repetition]`.
- A chapter with nothing to flag gets a single `_Nothing flagged._` line. Do not manufacture flags.
- One line per item. This is a triage list, not a line edit: no inline strikethrough editing, no paragraph rewrites, no commentary on style.

## Critique pass

Run once, after the list is written and before the terminal confirmation. Spawn one independent critic via the Agent tool (`subagent_type: general-purpose`, no `model` override; the critic inherits the session model), passing the brief in **## Critique sub-agent brief** with the absolute paths filled in. Pass nothing else from your context; the critic reads the files itself.

If the critic returns `CLEAN`, stop. Otherwise adjudicate every finding yourself; never apply one blindly. Accept a finding only when it is genuinely valid: a real obvious error missed, or a flag that overreaches (not an outright error, or deliberate form per the writing-style skill, or an item that belongs to `/story-line-edit` or `/story-copy-edit`). Reject anything that pushes this pass toward subtle line-editing. Then apply the accepted findings with targeted `Edit` calls on the affected list items only (add missed flags, delete overreaching ones, fix wrong ones); do not rewrite the whole list with the Write tool. Keep the format identical. Do not run further rounds.

## Critique sub-agent brief

The orchestrator passes this as the prompt of the `Agent` call, with `<manuscript-path>`, `<list-path>`, and `<writing-style-path>` filled in. Pass nothing else from your context. Do not add the vault or story `CLAUDE.md` to the read list: the harness auto-injects both into the sub-agent, so listing them just doubles them in its context.

---

You are an independent critic checking a pre-beta "quick clean" triage list for one story. Your job is to critique **the list, never the prose**. You edit no file; you only report findings.

Read all of these in full (absolute paths):
- The manuscript: every chapter file under `<manuscript-path>` in filename order, or the single story file at that path.
- The list under critique: `<list-path>`
- Writing-style skill: `<writing-style-path>`

(The vault and story `CLAUDE.md` are already in your context, auto-injected by the harness; do not re-read them.)

This pass flags **only obvious language errors**: broken grammar or syntax, typos and wrong words, blatantly non-idiomatic phrasing, character or location name inconsistencies, and glaring word repetition. It is deliberately shallow. It must NOT flag subtle or technically-correct non-native phrasing, rhythm, flow, idiom refinement, voice, word choice, CMOS niceties, or anything the writing-style skill marks as deliberate form; those belong to /story-line-edit, /story-copy-edit, and the later stages.

Report only these kinds of finding:
- **MISS**: an obvious error in the prose (in the categories above) the list failed to flag.
- **OVERREACH**: an item the list flagged that is not an outright error — a refinement, a style preference, a subtle non-native phrasing, a CMOS nicety, or deliberate authorial form per the writing-style skill or a locked decision.
- **WRONG**: a flag whose quoted snippet, category, or suggested fix is incorrect.

Hold a high bar. Return the single token `CLEAN` if nothing is genuinely worth changing; manufacturing findings is a failure, not diligence. Do not propose line-level rewrites of your own, do not pitch stylistic preferences, do not touch the prose.

Output either `CLEAN`, or a numbered list with one finding per line in the form `<TAG> <chapter>: <one-line justification, quoting the phrase>`. Output nothing else.

## What to avoid

- **Editing the manuscript prose.** This skill only ever writes the triage list. The prose is the author's; only the author changes it.
- **Descending into line-editing.** This is not a line or copy edit. Flag outright errors, not refinements, idiom polish, rhythm, or subtle non-native phrasing. When in doubt, leave it.
- **Flagging deliberate form.** The writing-style skill is the authority on what is deliberate craft (short standalone paragraphs, fragments, perspective bleed, intentional repetition, ambiguous endings, and the like); never flag what it declares the author's own.
- **Running on a single chapter.** This is a whole-manuscript pass; for one chapter's language, use /story-copy-edit ch-XX (or /story-line-edit for craft).
- **Manufacturing flags** to look thorough, or padding a clean chapter. A clean manuscript is a valid result.
- **Re-running until clean.** Repeated runs on the same draft do not converge: each fresh read samples new marginal flags. One re-run to verify applied fixes is reasonable; beyond that, treat new low-grade flags as noise and move on to the beta read. If a re-run keeps surfacing genuinely substantive errors, that is a signal the draft needs another self-revision pass, not another quick-clean.
- **Reconstructing the manuscript from memory.** Always read fresh from disk.
- **Printing the list or the critique transcript to the terminal.** Only the one-line confirmation goes there.
