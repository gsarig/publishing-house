---
name: story-copy-edit
description: "Produces a per-paragraph copy-edit review of one chapter (grammar, syntax, CMOS, idiom, tense, intra-chapter continuity), self-hardened by an internal critique loop and written to _reviews/<chapter>/copy-edit/suggestions.md. It never edits the chapter prose."
when_to_use: "Use when the author invokes /story-copy-edit with a chapter reference (e.g. /story-copy-edit ch-01). This is editorial stage 5: grammar, CMOS, punctuation, syntax, idiom, and continuity, assuming voice and structure are settled. Do NOT use it for rhythm, weak verbs, or sentence craft (use /story-line-edit); do NOT use it for structure, pacing, or arcs (use /story-dev-edit); do NOT use it for a whole-story consistency sweep (use /story-audit); do NOT edit chapter prose directly. Follow all steps in order; do not shortcut based on this description."
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
- This story's `CLAUDE.md` and the vault-level `CLAUDE.md`. Use them to distinguish intentional stylistic choices from genuine errors; never flag or correct deliberate form.
- `_Index.md`, the story bible, for premise, world rules, and Locked decisions, so a deliberate device is never flagged and intra-chapter continuity is judged against the established facts.
- The writing-style skill at `../.claude/skills/writing-style/SKILL.md`. This is the single source of truth for the author's aesthetic. Any pattern described there is intentional and must not be flagged as an error.

### 3. Produce the copy-edit review

Apply the **## Standards**, the **## What this pass corrects** remit, and the **## Output format**. Process the entire chapter, paragraph by paragraph.

**This pass stays strictly in its lane: mechanics, idiom, and intra-chapter continuity.** Assume `/story-line-edit` has already settled the voice and rhythm; do not rephrase for craft, and do not flag or defer a craft item. Cross-chapter continuity belongs to `/story-audit`; flag only contradictions internal to this chapter here.

Write the full review to `_reviews/<chapter-ref>/copy-edit/suggestions.md`, creating the folders if needed. A re-run overwrites the existing file. Add this frontmatter at the top:

```
---
chapter: <chapter-ref>
stage: copy-edit
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

American English, Chicago Manual of Style (CMOS), Oxford comma. Past-tense narration throughout, except inside dialogue.

## What this pass corrects

**Job:** Make the prose mechanically correct and idiomatically native, assuming the voice is already settled. Two distinct kinds of work: hard errors, and idiom-level corrections.

**Correct or flag:**
- Grammar and syntax errors.
- CMOS punctuation: American quotation conventions, the Oxford comma, capitalization, numbers, dash and ellipsis usage.
- Spelling and clear typos. (The final fresh-eye sweep is `/story-proof`, but obvious errors in this lane get fixed here.)
- Tense slips: maintain past-tense narration except inside dialogue.
- Dummy pronouns and unclear pronoun references where fixing yields a clear improvement.
- **Idiom:** phrasing that is grammatically acceptable but does not read like natural, idiomatic English to a fluent American ear: unnatural article use, off preposition choices, calqued idioms, awkward word order, progressive where English narration prefers the simple past. (These patterns are common when the author writes in English as a second language.) Be assertive on these, but preserve voice; if a construction fits the author's register, leave it.
- Intra-chapter continuity: a detail that contradicts another detail inside this same chapter.

**Do not:**
- Rephrase for rhythm, cadence, weak verbs, or any sentence-craft reason. That is `/story-line-edit`'s lane; assume it has run, and do not flag or defer it.
- Restructure scenes or comment on pacing, arc, or theme. That is `/story-dev-edit`'s lane.
- Chase cross-chapter consistency (a character's eye colour two chapters ago, a timeline order). That is `/story-audit`'s lane.
- Flag word or phrase repetition and echoes. That is `/story-line-edit`'s craft lane; assume it has handled them.
- Override deliberate form. The writing-style skill is authoritative: whatever it marks as deliberate (for example perspective bleed, free indirect discourse without quotation marks, short standalone paragraphs, deliberate repetition, or dark comedy) is not an error.
- Add, remove, or invent content.

## Output format

- For each paragraph with at least one correction, reproduce it showing inline edits using `~~strikethrough~~` for deletions and `**bold**` for additions. Keep the edited paragraph as normal Markdown so the strikethrough and bold render. Do not reproduce paragraphs with no corrections (see the clean-paragraph line below).
- Polish Notes are labeled sequentially (PN1, PN2, PN3...) across the full chapter, and every paragraph gets one, clean paragraphs included. The numbering doubles as a coverage audit: a missing number means a skipped paragraph, never a clean one.
- **Wrap the Polish Note of every changed paragraph in its own fenced code block**, placed below the edited paragraph. Put each correction on its own numbered line (`1)`, `2)`, `3)`...). For a hard error (grammar, CMOS, typo), state what was changed and why in one line. For an idiom-level correction, use two parts separated by `|`: Part A is what was done; Part B is the rationale (why the change reads native and preserves meaning and voice; quote the flagged phrase; list alternatives separated by semicolons). Example:

```
PN4:
1) "off existence" to "out of existence" | idiom: native phrasing is "out of existence"; same meaning.
2) "he was feeling" to "he felt" | idiom: English narration prefers the simple past over the progressive here; preserves tense and voice.
```

- For a paragraph that needs no changes, do not reproduce the paragraph and use no code block. Emit one plain line instead: `PN6 — "<first 5-8 words of the paragraph>" — no corrections needed.` Quote the opening words verbatim so the author can locate the paragraph by search.
- Do not summarize or add commentary outside the Polish Notes.

---

## Critique loop

Runs by default after the review file is written, before the terminal confirmation. It hardens the review against its own misses and false flags, automating what the author would otherwise do by hand. It refines the **review document only** and **never alters the chapter prose**. The loop is silent: the deliverable and its format are unchanged; the critic only makes the same review more correct.

Loop **at most 3 rounds**:

1. **Spawn one independent critic** via the Agent tool (`subagent_type: general-purpose`, no `model` override; the critic inherits the session model), passing the brief in **## Critique sub-agent brief** with the absolute paths filled in. Pass nothing else from your own context; the critic reads the files itself. While the critic runs, just wait: the harness re-invokes you when it completes. Never schedule a ScheduleWakeup as a polling fallback for it.
2. **If the critic returns `CLEAN`, stop.**
3. **Otherwise adjudicate every finding yourself. This step is not optional; never apply a critic's finding blindly.** Accept a finding only when it is genuinely valid against the writing-style skill, the story's Locked decisions, and this pass's remit (mechanics, idiom, intra-chapter continuity). Reject any finding that would flag deliberate form, that belongs to another stage (craft, structure, cross-chapter continuity), or that the critic simply got wrong. If a finding exactly reverses a change an earlier round already made, treat that item as settled and reject it (oscillation guard).
4. **If you accepted no findings this round, stop.** Otherwise apply the accepted findings with targeted `Edit` calls on the affected paragraphs and Polish Notes only: add missed items, delete false flags, fix rationales, including the small one-line renumbering edits when an insertion or deletion shifts later PN labels. Never rewrite the whole file with the Write tool to apply a handful of findings: re-emitting the full document wastes output tokens and risks silently altering quoted prose the findings never touched. A full rewrite is justified only when accepted findings restructure most of the document. Keep PN numbering sequential and the output format identical.
5. **Stop** when any holds: the critic returned `CLEAN`, you accepted nothing this round, or you completed 3 rounds.

The loop replaces the manual second-pass critique convention. Do not also append a paste-ready second-pass prompt to the review; the loop is the second pass.

---

## Critique sub-agent brief

The orchestrator passes this as the prompt of the `Agent` call (`subagent_type: general-purpose`, no `model` override), with `<chapter-path>`, `<review-path>`, `<index-path>`, and `<writing-style-path>` filled in. Pass nothing else from your context. Do not add the vault or story `CLAUDE.md` to the read list: the harness auto-injects both into the sub-agent, so listing them just doubles them in its context.

---

You are an independent copy-editing critic reviewing a copy-edit review document for one chapter. Your job is to critique **the review, never the chapter prose**. You edit no file; you only report findings.

Read all of these in full (absolute paths):
- Chapter: `<chapter-path>`
- The review under critique: `<review-path>`
- Story bible: `<index-path>`
- Writing-style skill: `<writing-style-path>`

(The vault and story `CLAUDE.md` are already in your context, auto-injected by the harness; do not re-read them.)

This is a **copy-edit** review. Its remit is grammar, syntax, CMOS punctuation, spelling, tense consistency, idiom (technically-correct phrasing that reads non-native), and intra-chapter continuity, assuming voice and structure are settled. It must never rephrase for rhythm or craft (that is line-edit), restructure or comment on pacing (that is dev-edit), or chase cross-chapter consistency (that is story-audit).

Check every Polish Note against the chapter. Report only these three kinds of finding:
- **MISS**: a genuine error in this remit (grammar, CMOS, idiom, tense, intra-chapter contradiction) that the review failed to catch.
- **FALSE-FLAG**: something the review changed that is actually (a) deliberate authorial form per the writing-style skill or the story's Locked decisions, (b) outside the copy-edit remit (a craft, structural, or cross-chapter item), or (c) simply wrong.
- **BAD-RATIONALE**: a correct catch whose explanation or suggested fix is wrong.

Hold a high bar. Return the single token `CLEAN` if nothing is genuinely worth changing; manufacturing findings to look useful is a failure, not diligence. Do not propose stylistic rewrites, do not re-pitch items that belong to another stage, and do not touch the prose.

Output either `CLEAN`, or a numbered list with one finding per line in the form `<TAG> PN<n>: <one-line justification, quoting the phrase>`. Output nothing else.

---

## What to avoid

- **Editing the chapter prose.** The skill only ever writes the review file. The prose is the author's; only the author changes it.
- **Cross-lane leakage.** A copy-edit review never rephrases for craft (line-edit's lane) and never chases cross-chapter continuity (story-audit's lane). It also never previews or defers a craft item.
- **Flagging deliberate form.** Whatever the writing-style skill marks as the author's register (perspective bleed, free indirect discourse without quotation marks, short standalone paragraphs, deliberate repetition, dark comedy, and the like) is not an error.
- **Applying critic findings without adjudication.** The critic informs; the orchestrator decides.
- **Looping past 3 rounds, or oscillating** by re-applying a change a prior round reversed.
- **Reconstructing the chapter or a prior run from memory.** Always read the chapter fresh from disk.
- **Printing the review or the critique transcript to the terminal.** Only the one-line confirmation goes there.
