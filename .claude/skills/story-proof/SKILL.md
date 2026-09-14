---
name: story-proof
description: "Produces a final fresh-eye proofreading sweep of one chapter for typos and formatting errors only, self-hardened by an internal critique loop and written to _reviews/<chapter>/proof/suggestions.md. It never edits the chapter prose."
when_to_use: "Use when the author invokes /story-proof with a chapter reference (e.g. /story-proof ch-01). This is editorial stage 6, the last per-chapter pass: typos, doubled or missing words, and formatting glitches only, assuming line-edit and copy-edit have run. Do NOT use it for grammar, CMOS, or idiom (use /story-copy-edit); do NOT use it for sentence craft (use /story-line-edit); do NOT edit chapter prose directly. Follow all steps in order; do not shortcut based on this description."
argument-hint: "ch-XX"
disable-model-invocation: true
---

## Steps

### 1. Parse the argument and locate the chapter

Parse the argument for a chapter reference (e.g. "ch-01"). If none is given, ask which chapter and stop until answered.

Locate the chapter file from the reference:
- If a `Chapters/` folder exists, find the file whose name starts with the chapter reference.
- If no `Chapters/` folder exists (short story), look for the file in the story root.

### 2. Read the chapter fresh, then the references

**This step is not optional. ALWAYS read the chapter file fresh from disk with the Read tool at the start of every run, with no exceptions, even if you ran a pass on the same chapter moments ago in this same conversation.** Never reconstruct the chapter prose from memory or any cached context. The author edits the chapter between runs, so prior analysis is stale by definition; the file on disk is the only source of truth. If you cannot read the file this turn, stop and say so.

Then read, also in full:
- This story's `CLAUDE.md` and the vault-level `CLAUDE.md`, and the writing-style skill at `../.claude/skills/writing-style/SKILL.md`. Use them so deliberate form (intentional one-word paragraphs, unusual spacing, free indirect discourse) is never mistaken for a formatting error.

### 3. Produce the proof review

Apply the **## What this pass corrects** remit and the **## Output format**. Read the chapter as if seeing it for the first time and flag only what a fresh eye snags on mechanically.

**This pass is minimal by design and stays strictly in its lane.** It is not another copy-edit. Flag only typos, doubled or missing words, and formatting glitches. **If you find more than a handful of substantive issues (grammar, idiom, awkward phrasing), stop flagging them and instead note at the top of the review that the chapter needs another `/story-copy-edit` pass before proofing.**

Write the review to `_reviews/<chapter-ref>/proof/suggestions.md`, creating the folders if needed. A re-run overwrites the existing file. Add this frontmatter at the top:

```
---
chapter: <chapter-ref>
stage: proof
date: <YYYY-MM-DD>
chapter_modified: <ISO mtime of the chapter file at review time>
---
```

Get `chapter_modified` from a single `stat -c '%y' <chapter-path>`. Do not print the review to the terminal.

Write the review with the `Write` tool directly; any quoted prose may carry em-dashes and they must be preserved verbatim.

### 4. Harden the review with the critique loop

Run the **## Critique loop** by default, after the review file is written and before the confirmation. It refines the review document only and never touches the chapter prose.

### 5. Confirm

Print one line to the terminal only: the saved path plus the number of items found (often zero or near zero). If you flagged that the chapter needs another copy-edit pass, say so in that line. Nothing else.

---

## What this pass corrects

**Job:** A final fresh-eye sweep. Typos and formatting errors only. Minimal by design; do not manufacture changes.

**Flag:**
- Typos and misspellings that slipped through.
- Doubled words ("the the"), missing words, transposed letters.
- Formatting glitches: doubled spaces between words, inconsistent quotation marks or dashes left over from earlier editing, a broken Markdown construct, an accidental blank line inside a paragraph, a missing or duplicated paragraph break.
- Anything that would make a careful reader's eye physically snag on the page.

**Do not:**
- Re-examine grammar, CMOS, idiom, or sentence craft. Those were copy-edit and line-edit; this pass assumes they are done.
- Rephrase for any reason.
- Flag deliberate form (a one-word paragraph, an intentional spacing choice, free indirect discourse) as a formatting error; the writing-style skill is the authority.
- Flag trailing whitespace at line ends, of any count, ever. It is invisible in render (with one-line-per-paragraph prose, even a doubled trailing space at a paragraph end produces no hard break), and a careful reader's eye cannot snag on what it cannot see; it is categorically out of remit. If the author ever wants trailing whitespace stripped from the files, that is a one-line mechanical `sed` job, not a proof finding.

## Output format

For each item, one numbered task-list entry (`1. [ ] ...`) so the author can tick it off in Obsidian as each fix is applied. Each entry carries the verbatim phrase it sits in (as a Ctrl-F anchor), a one-line description of the error, and the fix.

Example:

```
1. [ ] "the the sun had set" — doubled word "the"; delete one.
2. [ ] "out of  existence" — doubled space; collapse to one.
```

If the whole chapter is clean, the review body is a single line: `No proofing issues found.` — a plain line, not a checkbox. Do not add commentary beyond the entries.

---

## Critique loop

Runs by default after the review file is written, before the terminal confirmation. It hardens the review against its own misses and false flags. It refines the **review document only** and **never alters the chapter prose**. The loop is silent.

Loop **at most 3 rounds**:

1. **Spawn one independent critic** via the Agent tool (`subagent_type: general-purpose`, no `model` override; the critic inherits the session model), passing the brief in **## Critique sub-agent brief** with the absolute paths filled in. Pass nothing else from your own context; the critic reads the files itself.
2. **If the critic returns `CLEAN`, stop.**
3. **Otherwise adjudicate every finding yourself. This step is not optional; never apply a critic's finding blindly.** Accept a finding only when it is a genuine typo or formatting error the review missed or wrongly flagged. Reject anything that pushes this pass toward copy-editing (grammar, idiom, phrasing) or that flags deliberate form. If a finding reverses a change a prior round made, treat it as settled and reject it.
4. **If you accepted no findings this round, stop.** Otherwise apply the accepted findings with targeted `Edit` calls on the affected entries only; do not rewrite the whole file with the Write tool. Keep the numbering sequential and the format identical.
5. **Stop** when any holds: the critic returned `CLEAN`, you accepted nothing this round, or you completed 3 rounds.

---

## Critique sub-agent brief

The orchestrator passes this as the prompt of the `Agent` call (`subagent_type: general-purpose`, no `model` override), with `<chapter-path>`, `<review-path>`, and `<writing-style-path>` filled in. Pass nothing else from your context. Do not add the vault or story `CLAUDE.md` to the read list: the harness auto-injects both into the sub-agent, so listing them just doubles them in its context.

---

You are an independent proofreading critic reviewing a proof review document for one chapter. Your job is to critique **the review, never the chapter prose**. You edit no file; you only report findings.

Read all of these in full (absolute paths):
- Chapter: `<chapter-path>`
- The review under critique: `<review-path>`
- Writing-style skill: `<writing-style-path>`

(The vault and story `CLAUDE.md` are already in your context, auto-injected by the harness; do not re-read them.)

This is a **proof** review. Its remit is typos, doubled or missing words, and formatting errors only, assuming copy-edit and line-edit have run. It must never flag grammar, idiom, phrasing, or sentence craft, and must never flag deliberate form (intentional one-word paragraphs, spacing, free indirect discourse) as a formatting error. Trailing whitespace at line ends, of any count, is categorically out of remit and must never be reported: it is invisible in render. Doubled spaces *between* words remain legitimate glitches.

Report only these kinds of finding:
- **MISS**: a genuine typo or formatting error the review failed to catch.
- **FALSE-FLAG**: something the review flagged that is actually deliberate form, outside the proof remit (a grammar/phrasing item), or simply wrong.

Hold a high bar. Return the single token `CLEAN` if nothing is genuinely worth changing; manufacturing findings is a failure, not diligence. Do not propose copy-edits or rewrites, and do not touch the prose.

Output either `CLEAN`, or a numbered list with one finding per line in the form `<TAG>: <one-line justification, quoting the phrase>`. Output nothing else.

---

## What to avoid

- **Editing the chapter prose.** The skill only ever writes the review file.
- **Turning proof into a second copy-edit.** Flag only typos and formatting. If substantive issues pile up, signal that copy-edit needs another pass instead of fixing them here.
- **Flagging deliberate form** (one-word paragraphs, intentional spacing) as a formatting error.
- **Applying critic findings without adjudication.**
- **Reconstructing the chapter from memory.** Always read it fresh from disk.
- **Printing the review or the critique transcript to the terminal.** Only the one-line confirmation goes there.
