---
name: story-line-edit
description: "Produces a per-paragraph line-edit review of one chapter at sentence-craft level (voice, rhythm, weak verbs, redundancy, sentence-level showing-vs-telling), self-hardened by an internal critique loop and written to _reviews/<chapter>/line-edit/suggestions.md. It never edits the chapter prose."
when_to_use: "Use when the author invokes /story-line-edit with a chapter reference (e.g. /story-line-edit ch-01). This is editorial stage 4: sentence craft, assuming grammar is already correct. Do NOT use it to fix grammar, CMOS, punctuation, or idiom (use /story-copy-edit); do NOT use it for structure, pacing, or arcs (use /story-dev-edit); do NOT use it for typos or formatting (use /story-proof); do NOT edit chapter prose directly. Follow all steps in order; do not shortcut based on this description."
argument-hint: "ch-XX"
effort: xhigh
disable-model-invocation: true
---

## Steps

### 1. Parse the argument and locate the chapter

Parse the argument for a chapter reference (e.g. "ch-01"). If none is given, ask which chapter and stop until answered.

Locate the chapter file from the reference:
- If a `Chapters/` folder exists, find the file whose name starts with the chapter reference.
- If no `Chapters/` folder exists (short story), look for the file in the story root.

### 2. Read the chapter fresh, then the references

**This step is not optional. ALWAYS read the chapter file fresh from disk with the Read tool at the start of every run, with no exceptions, even if you ran a pass on the same chapter moments ago in this same conversation.** Never reconstruct the chapter prose, or the findings of a previous run, from memory, from an earlier report, or from any cached context. The author edits the chapter between runs, so prior analysis is stale by definition; the file on disk is the only source of truth. If you cannot read the file this turn, stop and say so.

Then read, also in full:
- This story's `CLAUDE.md` and the vault-level `CLAUDE.md`. Use them to distinguish intentional choices from genuine craft weaknesses; never flag or "improve" deliberate form.
- `_Index.md`, the story bible, for premise, voice, and Locked decisions, so a deliberate device is never flagged.
- The writing-style skill at `../.claude/skills/writing-style/SKILL.md`. This is the single source of truth for the author's aesthetic. Any pattern described there is intentional and must never be flagged.

### 3. Produce the line-edit review

Apply the **## Standards**, the **## What this pass corrects** remit, and the **## Output format**. Process the entire chapter, paragraph by paragraph.

**This pass stays strictly in its lane: sentence-level craft only.** Report only craft items. Never flag, preview, or defer a grammar, CMOS, idiom, or structural item; the copy-edit and dev-edit stages re-read the chapter fresh and will catch their own. If a paragraph needs no craft change, say so and move on.

Write the full review to `_reviews/<chapter-ref>/line-edit/suggestions.md`, creating the folders if needed. A re-run overwrites the existing file. Add this frontmatter at the top so the author can gauge staleness later:

```
---
chapter: <chapter-ref>
stage: line-edit
date: <YYYY-MM-DD>
chapter_modified: <ISO mtime of the chapter file at review time>
---
```

Get `chapter_modified` from a single `stat -c '%y' <chapter-path>`. Do not print the review to the terminal.

Write the review with the `Write` tool directly; the author's quoted prose may carry em-dashes and they must be preserved verbatim, never stripped or normalized.

### 4. Harden the review with the critique loop

Run the **## Critique loop** by default, after the review file is written and before the confirmation. It hardens the review against its own misses and false flags; it refines the review document only and never touches the chapter prose.

### 5. Confirm

Print one line to the terminal only: the saved path plus a brief count of paragraphs changed versus left unchanged. Nothing else: no review dump, no critique transcript.

---

## Standards

American English, Chicago Manual of Style (CMOS), Oxford comma. The edited prose should respect these even though fixing punctuation is not this pass's job.

## What this pass corrects

**Job:** Sentence-level craft, assuming grammar is already correct. Make each sentence land harder without changing what it says or whose voice says it.

**Correct or flag:**
- Weak, vague, or abstract verbs; nominalizations; "to be" plus adjective where a single strong verb is available.
- Rhythm and cadence: monotonous sentence length, clunky flow, a clause that trips the ear.
- Redundancy and repetition: an idea said twice (cut one), and distracting word or phrase echoes within a short span (offer up to three drop-in alternatives in the author's plain register, or name which to cut; never a generic "vary it"). This pass owns repetition; copy-edit does not re-flag it. Also padding and throat-clearing openers.
- Filtering ("she saw that," "he felt that," "he noticed") where cutting the filter brings the reader closer to the experience.
- Telling at the sentence level where a small change shows instead: offer two or three candidate images or actions in the author's plain register (never a bare "show, don't tell"). If no image carries the valence without strain, say so and keep the stated emotion; attribution-telling and information-bearing emotion words are in-style and not flagged (see the writing-style skill). (Scene-level telling is dev-edit's call, not this pass's.)
- Dead adverbs and hedges that weaken a strong verb or image.

**Do not:**
- Touch grammar, syntax, punctuation, CMOS, spelling, or idiom. That is `/story-copy-edit`'s lane; do not flag, preview, or defer it.
- Restructure scenes, reorder beats, or comment on pacing, arc, or theme. That is `/story-dev-edit`'s lane.
- Override the author's aesthetic. The writing-style skill is authoritative on what is deliberate (registers like plain minimalism, short standalone paragraphs, deliberate repetition, blurt interior monologue, perspective bleed, absence of lyricism, or dark comedy). Never smooth the author's declared register into conventional prose. Flag only what works against the author's own register, never against generic taste.
- Add, remove, or invent content.

## Output format

- For each paragraph with at least one change, reproduce it showing inline edits using `~~strikethrough~~` for deletions and `**bold**` for additions. Keep the edited paragraph as normal Markdown so the strikethrough and bold render. Do not reproduce paragraphs with no changes (see the clean-paragraph line below).
- Polish Notes are labeled sequentially (PN1, PN2, PN3...) across the full chapter, and every paragraph gets one, clean paragraphs included. The numbering doubles as a coverage audit: a missing number means a skipped paragraph, never a clean one.
- **Wrap the Polish Note of every changed paragraph in its own fenced code block**, placed below the edited paragraph. Put each change on its own numbered line (`1)`, `2)`, `3)`...). Each line has two parts separated by `|`: Part A is what was done; Part B is the rationale (why the change strengthens the sentence while preserving meaning and voice; quote the changed phrase). Example:

```
PN4:
1) Changed "was walking slowly" to "trudged" | weak verb + adverb collapsed into one strong verb; same image, tighter, keeps the plain register.
```

- For a paragraph that needs no craft change, do not reproduce the paragraph and use no code block. Emit one plain line instead: `PN6 — "<first 5-8 words of the paragraph>" — no craft changes needed.` Quote the opening words verbatim so the author can locate the paragraph by search.
- Do not summarize or add commentary outside the Polish Notes.

---

## Critique loop

Runs by default after the review file is written, before the terminal confirmation. It hardens the review against its own misses and false flags, automating what the author would otherwise do by hand. It refines the **review document only** and **never alters the chapter prose**. The loop is silent: the deliverable and its format are unchanged; the critic only makes the same review more correct.

Loop **at most 3 rounds**:

1. **Spawn one independent critic** via the Agent tool (`subagent_type: general-purpose`, no `model` override; the critic inherits the session model), passing the brief in **## Critique sub-agent brief** with the absolute paths filled in. Pass nothing else from your own context; the critic reads the files itself. While the critic runs, just wait: the harness re-invokes you when it completes. Never schedule a ScheduleWakeup as a polling fallback for it.
2. **If the critic returns `CLEAN`, stop.**
3. **Otherwise adjudicate every finding yourself. This step is not optional; never apply a critic's finding blindly.** Accept a finding only when it is genuinely valid against the writing-style skill, the story's Locked decisions, and this pass's craft remit. Reject any finding that would flag deliberate form, that belongs to another stage (grammar, idiom, structure), or that the critic simply got wrong. If a finding exactly reverses a change an earlier round already made, treat that item as settled and reject it (oscillation guard).
4. **If you accepted no findings this round, stop.** Otherwise apply the accepted findings with targeted `Edit` calls on the affected paragraphs and Polish Notes only: add missed items, delete false flags, fix rationales, including the small one-line renumbering edits when an insertion or deletion shifts later PN labels. Never rewrite the whole file with the Write tool to apply a handful of findings: re-emitting the full document wastes output tokens and risks silently altering quoted prose the findings never touched. A full rewrite is justified only when accepted findings restructure most of the document. Keep PN numbering sequential and the output format identical.
5. **Stop** when any holds: the critic returned `CLEAN`, you accepted nothing this round, or you completed 3 rounds.

The loop replaces the manual second-pass critique convention. Do not also append a paste-ready second-pass prompt to the review; the loop is the second pass.

---

## Critique sub-agent brief

The orchestrator passes this as the prompt of the `Agent` call (`subagent_type: general-purpose`, no `model` override), with `<chapter-path>`, `<review-path>`, `<index-path>`, and `<writing-style-path>` filled in. Pass nothing else from your context. Do not add the vault or story `CLAUDE.md` to the read list: the harness auto-injects both into the sub-agent, so listing them just doubles them in its context.

---

You are an independent line-editing critic reviewing a line-edit review document for one chapter. Your job is to critique **the review, never the chapter prose**. You edit no file; you only report findings.

Read all of these in full (absolute paths):
- Chapter: `<chapter-path>`
- The review under critique: `<review-path>`
- Story bible: `<index-path>`
- Writing-style skill: `<writing-style-path>`

(The vault and story `CLAUDE.md` are already in your context, auto-injected by the harness; do not re-read them.)

This is a **line-edit** review. Its remit is sentence-level craft only: weak verbs, rhythm and cadence, redundancy, filtering, and sentence-level telling-vs-showing, assuming grammar is already correct. It must never touch grammar, CMOS, punctuation, idiom (those are copy-edit), or structure, pacing, and arc (those are dev-edit).

Check every Polish Note against the chapter. Report only these three kinds of finding:
- **MISS**: a genuine sentence-craft weakness in the prose that the review failed to catch.
- **FALSE-FLAG**: something the review changed that is actually (a) deliberate authorial form per the writing-style skill or the story's Locked decisions, (b) outside the line-edit remit (a grammar/idiom/structure item), or (c) simply wrong (the change weakens the sentence).
- **BAD-RATIONALE**: a correct catch whose explanation or suggested change is wrong.

Hold a high bar. Return the single token `CLEAN` if nothing is genuinely worth changing; manufacturing findings to look useful is a failure, not diligence. Do not propose grammar fixes, do not re-pitch items that belong to another stage, and do not touch the prose.

Output either `CLEAN`, or a numbered list with one finding per line in the form `<TAG> PN<n>: <one-line justification, quoting the phrase>`. Output nothing else.

---

## What to avoid

- **Editing the chapter prose.** The skill only ever writes the review file. The prose is the author's; only the author changes it.
- **Cross-lane leakage.** A line-edit review never flags or defers a grammar, CMOS, idiom, or structural item. Copy-edit and dev-edit re-read fresh and catch their own.
- **Smoothing the author's voice into conventional prose.** The writing-style skill is the authority on what is deliberate; respect every pattern it declares the author's own.
- **Applying critic findings without adjudication.** The critic informs; the orchestrator decides.
- **Looping past 3 rounds, or oscillating** by re-applying a change a prior round reversed.
- **Reconstructing the chapter or a prior run from memory.** Always read the chapter fresh from disk.
- **Printing the review or the critique transcript to the terminal.** Only the one-line confirmation goes there.
