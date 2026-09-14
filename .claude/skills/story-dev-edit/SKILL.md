---
name: story-dev-edit
description: "Produces a whole-manuscript developmental edit of a complete, beta-read story as a severity-ranked, actionable editorial letter, self-hardened by an internal critique loop, written to _reviews/_full/dev/dev-edit-YYYY-MM-DD.md. It never edits the prose."
when_to_use: "Use when the author invokes /story-dev-edit on a complete, self-revised, beta-read manuscript (stage 3 of the editorial pipeline). Whole-work only, takes no arguments. Do NOT run on an isolated chapter or a partial draft (use /dev-edit ch-XX for a single-chapter pass). Do NOT edit chapter prose. Follow all steps in order; do not shortcut based on this description."
effort: high
disable-model-invocation: true
---

## Steps

### 1. Confirm the model and locate the story

This pass benefits from a top-tier model, and the critique sub-agents inherit the session model. If you are on a mid- or low-tier model (e.g. Sonnet or Haiku), tell the author and suggest switching to the strongest available model with `/model` before proceeding; wait for their response.

Locate the story:
- If the working directory is a story folder (contains `_Index.md` and either a `Chapters/` folder or chapter files at the root), use it. Otherwise list the story folders under the vault root and ask which one.
- Ask once: "Is the manuscript complete, self-revised, and beta-read? A developmental edit assumes a finished draft; running it on a partial or actively-rewritten draft wastes the pass." If no, stop. If yes, proceed.

### 2. Read the manuscript fresh, then the references

**This step is not optional. ALWAYS read every file fresh from disk with the Read tool at the start of every run, even if you read the same files moments ago in this conversation.** Never reconstruct the manuscript, or a prior report's findings, from memory or cached context. The author edits between runs, so prior analysis is stale by definition; the files on disk are the only source of truth. If you cannot read the files this turn, stop and say so.

Read, in full and in order:
- The whole manuscript: every `Chapters/*.md` in filename order, or the single root story file for a short story.
- `_Index.md`, the story bible: premise, themes, world rules, locked decisions, intended final beats. Reading it here is correct and required; a developmental edit is an authoring task that works from the author's intent, unlike a cold beta read.
- This story's `CLAUDE.md` and the vault-level `CLAUDE.md`: to distinguish intentional choices from genuine problems.
- The writing-style skill at `../.claude/skills/writing-style/SKILL.md`: the single source of truth for the author's aesthetic. Anything it describes as intentional must never be flagged as a defect.
- Character files under `_Characters/` and `Timeline.md` if present: for arc and continuity checks.

### 3. Produce the developmental edit

Apply the **## Axes** and **## Output format**. Assess the manuscript as a whole; this is an editorial letter, not a chapter-by-chapter pass.

**The goal is the most publishable version of the book, not the author's comfort or agreement.** Take a clear position on every finding: name the problem plainly, recommend a concrete fix or the question to resolve, and state how strongly you hold it (confident or tentative). Rank findings by severity and lead with what to fix first. Do not hedge to soften and do not bury a real weakness under qualifications; a finding the author cannot act on is a wasted finding. The opposite failure is equally real: do not manufacture or inflate findings, and never name a literary influence (Kafka, Béla Tarr, Lynch, Kieślowski, etc.) as a substitute for an observation — describe the behaviour you actually see in the text, with chapter evidence, not the label.

**Use the writing-style skill as a false-flag filter, not a gag.** Its job is to stop you flagging an intentional device as a defect: devices it declares deliberate (intentional slowness with presence, unexplained weirdness, perspective bleed, contradictory characters, dark comedy, ambiguous endings, or whatever this author's file names) are craft, not faults. It does **not** place those devices beyond developmental assessment. You may still ask whether an intended device is well-calibrated or well-executed — whether a slow stretch actually has presence, whether a deliberate voice-blur is confined to isolated slips or has spread until two characters are no longer distinct, whether a recurring beat still escalates, whether a seeded setup actually pays off. Flagging the *execution or calibration* of an intended choice is fair game; demanding the choice itself be removed is not.

Write the full review with the Write tool to `_reviews/_full/dev/dev-edit-YYYY-MM-DD.md` (today's date), creating folders if needed. Do not print the review to the terminal.

### 4. Harden the review with the critique loop

Run the **## Critique loop** by default, after the review file is written and before the confirmation. It hardens the review against its own misses and false flags; it refines the review document only and never touches the prose.

### 5. Confirm

Print one line to the terminal only: the saved path plus a brief finding count (e.g. total findings, or a per-axis tally). Nothing else: no review dump, no critique transcript.

Then offer once, with a single question: generate `_reviews/_full/dev/revision-checklist.md`, a checkbox digest of the Weaknesses & priorities entries (one `- [ ]` per finding, severity-tagged, one line each) for tracking the revision in Obsidian. Only write it if the author accepts; a re-run overwrites it.

---

## Axes

Developmental altitude only. Do not descend to line level (prose, dialogue polish, sentence-level showing-vs-telling, word repetition, grammar, idiom); those belong to the later line-edit and copy-edit stages. Every axis runs through the writing-style skill as a false-flag filter (see Step 3): it prevents flagging an intentional device as a defect, but never places the calibration or execution of that device beyond assessment.

1. **Structure & architecture**: overall shape, act and movement balance, chapter ordering, scenes that do not earn their place.
2. **Pacing & momentum**: where the arc drags or rushes across the whole book. Slowness is not automatically a fault; per writing-style, duration can be a deliberate value, so ask whether a slow stretch has presence before flagging it.
3. **Plot & causality**: setups and payoffs, logic gaps, contrivance, cause-and-effect across chapters. When the writing-style skill embraces unexplained elements, an unexplained weird element is almost certainly intentional; do not treat it as a plot hole.
4. **Character arcs & motivation**: whether characters change, whether the change is earned, motivation consistency across the book. Contradiction is often deliberate; do not flatten it into consistency.
5. **Theme**: how the theme develops and deepens across the arc; whether it is over- or under-stated.
6. **Opening & ending**: does the opening hook, does the ending land. When the writing-style skill declares ambiguous, unresolved, or mid-sentence endings part of the author's register, they are VALID and must never be flagged as unfinished or in need of resolution.
7. **Strengths**: what is working at the developmental level, so revision does not break it. Developmental editing is not only corrective.

## Output format

Write an editorial letter with this structure:

```
---
stage: dev
date: <YYYY-MM-DD>
---

# Developmental Edit: "<title>"

## Overall assessment
<one or two paragraphs leading with the verdict: the book's core developmental strengths, then the few highest-severity issues to fix first>

## Weaknesses & priorities
<the actionable core of the letter: every weakness as its own entry, ranked highest-severity first. Each entry carries:
- **severity** — High (hurts the book's reception; fix before publishing), Medium (a real weakness worth fixing; the book survives it), or Low (minor; fix if convenient);
- the problem in one or two sentences, citing the chapter or scene it rests on;
- an explicit **recommendation**: what to change, or the precise question to resolve;
- your **confidence**: confident or tentative.
This section is where the author looks to know what to do and how much it matters. If nothing rises above Low, say so plainly rather than inflating a finding to look thorough.>

## Structure & architecture
<fuller evidence for the findings; tag each with its severity. "Nothing significant to flag" is a valid section body>

## Pacing & momentum
...

## Plot & causality
...

## Character arcs & motivation
...

## Theme
...

## Opening & ending
...

## Strengths
<what is working developmentally, so revision does not break it>
```

- Cite specific chapters and scenes as evidence for every finding; a developmental claim without a location is not actionable.
- Every weakness carries a severity, a recommendation, and a stated confidence, and appears in **Weaknesses & priorities**. A hedged observation with no recommendation and no severity is a failure of this pass, not a safe default.
- The axis sections hold the fuller evidence and reasoning; **Weaknesses & priorities** is the ranked digest. Do not pad the axes with restatement — point back to the digest entry.
- A section with nothing worth raising says so in one line. Do not manufacture findings to fill a section, and do not inflate a Low into a High to seem rigorous. Calibrated honesty runs in both directions.
- Stay at developmental altitude throughout. If you notice a line-level issue, leave it for the later stages; do not record it here.

## Critique loop

Runs by default after the review file is written, before the terminal confirmation. It hardens the review against its own misses and false flags, automating what the author would otherwise do by hand. It refines the **review document only** and **never alters the prose**. The loop is silent: the deliverable and its format are unchanged; the critic only makes the review more correct.

Loop **at most 3 rounds**:

1. **Spawn one independent critic** via the Agent tool (`subagent_type: general-purpose`, no `model` override; the critic inherits the session model), passing the brief in **## Critique sub-agent brief** with the absolute paths filled in. Pass nothing else from your own context; the critic reads the files itself.
2. **If the critic returns `CLEAN`, stop.**
3. **Otherwise adjudicate every finding yourself. This step is not optional; never apply a critic's finding blindly.** Accept a finding only when it is genuinely valid against the writing-style skill, the story's locked decisions (from `_Index.md`), and developmental altitude. Reject any finding that would have the *existence* of a deliberate device removed (ambiguous ending, intentional duration, unexplained weirdness, perspective bleed, dark comedy), that descends to line level, or that the critic simply got wrong. But do **not** reject a finding merely because it touches an intentional device: accept it when it concerns the device's calibration or execution (is the voice-blur isolated or pervasive, does the slow stretch have presence, does the recurring beat still escalate, does the seeded setup pay off) rather than its existence. Accept a **SOFT** finding when the review raised a real weakness but hedged it into non-actionability, or left it without a severity or a recommendation — the remedy is to sharpen it, not delete it. If a finding exactly reverses a change an earlier round already made, treat it as settled and reject it (oscillation guard).
4. **If you accepted no findings this round, stop.** Otherwise apply the accepted findings with targeted `Edit` calls on the affected entries and sections only: add missed items, delete false flags, fix evidence. Never rewrite the whole letter with the Write tool to apply a handful of findings: re-emitting the full document wastes output tokens and risks silently altering cited evidence the findings never touched. A full rewrite is justified only when accepted findings restructure most of the letter. Keep the structure identical.
5. **Stop** when any holds: the critic returned `CLEAN`, you accepted nothing this round, or you completed 3 rounds.

The loop replaces the manual second-pass critique convention for this skill. Do not also append a paste-ready second-pass prompt to the review; the loop is the second pass.

## Critique sub-agent brief

The orchestrator passes this as the prompt of the `Agent` call (`subagent_type: general-purpose`, no `model` override), with `<chapters-or-manuscript-path>`, `<review-path>`, `<index-path>`, and `<writing-style-path>` filled in. Pass nothing else from your context. Do not add the vault or story `CLAUDE.md` to the read list: the harness auto-injects both into the sub-agent, so listing them just doubles them in its context.

---

You are an independent developmental-editing critic reviewing a whole-manuscript developmental edit (an editorial letter) for one story. Your job is to critique **the review, never the prose**. You edit no file; you only report findings.

Read all of these in full (absolute paths):
- The manuscript: every chapter file under `<chapters-or-manuscript-path>` in filename order, or the single story file at that path.
- The review under critique: `<review-path>`
- The story bible: `<index-path>`
- Writing-style skill: `<writing-style-path>`

(The vault and story `CLAUDE.md` are already in your context, auto-injected by the harness; do not re-read them.)

This is a developmental edit. Its remit is the seven developmental axes: structure, pacing, plot and causality, character arcs, theme, opening and ending, strengths. It must stay at developmental altitude and must not flag line-level matters (prose, dialogue polish, word choice, grammar, idiom). The review is also required to be **actionable**: every weakness must carry a severity (High/Medium/Low), a concrete recommendation, and a stated confidence, ranked in a Weaknesses & priorities section. Catching where it fails that standard is part of your job.

The writing-style skill is a false-flag filter, not a gag: a deliberate device (intentional duration, perspective bleed, ambiguous ending, dark comedy, unexplained weirdness) must not be flagged for *existing*, but its calibration or execution may legitimately be assessed (e.g. a deliberate voice-blur that has spread until two characters are indistinct, a slow stretch with no presence, a recurring beat that has stopped escalating, a seeded setup that never pays off). Do not report such calibration findings as FALSE-FLAG.

Check the review against the manuscript. Report only these kinds of finding:
- **MISS**: a genuine developmental problem the review failed to raise — including a real weakness the review softened away or omitted, and a seeded setup whose payoff (or missing payoff) the review did not register.
- **FALSE-FLAG**: something the review raised that is actually (a) the mere existence of deliberate authorial form per the writing-style skill or the story's locked decisions (an ambiguous ending, intentional duration, an unexplained weird element, perspective bleed, dark comedy) — but NOT a finding about that device's calibration or execution, which is valid; (b) below developmental altitude; or (c) simply wrong about the text.
- **BAD-EVIDENCE**: a valid concern whose cited chapter or scene evidence is wrong or missing.
- **SOFT**: a real weakness the review did raise but hedged into non-actionability, or stated with no severity or no recommendation, so the author cannot act on it.

Hold a high bar. Return the single token `CLEAN` if nothing is genuinely worth changing; manufacturing findings to look useful is a failure, not diligence. Do not propose line-level edits, do not rewrite prose, do not pitch stylistic preferences.

Output either `CLEAN`, or a numbered list with one finding per line in the form `<TAG> <section>: <one-line justification, citing the chapter or scene>`. Output nothing else.

## What to avoid

- **Editing the manuscript prose.** The skill only ever writes the review file. The prose is the author's; only the author changes it.
- **Running on a partial draft or a single chapter.** A developmental edit is whole-manuscript or nothing; one chapter cannot show structure, arc, or pacing. For single-chapter feedback, use the separate `/dev-edit ch-XX`.
- **Descending to line level.** Prose, dialogue polish, word repetition, grammar, and idiom belong to the later line-edit and copy-edit stages. Keep this pass developmental.
- **Flagging deliberate form as a defect.** Ambiguous endings, intentional duration, unexplained weirdness, perspective bleed, dark comedy: when the writing-style skill declares such devices the author's register, it is the authority on whether the device should *exist*. Note the limit: assessing whether an intended device is well-calibrated or well-executed (an intentional voice-blur gone pervasive, a slow stretch with no presence, a recurring beat that no longer escalates, a seeded setup with no payoff) is not flagging the device, and is part of the job.
- **Hedging instead of deciding.** A weakness with no severity, no recommendation, or so buried in qualifications that the author cannot act on it is a failed finding, not a safe one. Take a position, recommend a fix, rank it, and say how confident you are. Softness that reads as wanting to please the author defeats the purpose of the pass.
- **Name-dropping an influence as analysis.** Do not write that a passage "feels like Béla Tarr" or "is very Kafka" in place of describing what the text actually does. Cite the behaviour and the chapter, not the label.
- **Findings without evidence.** Every developmental claim cites the specific chapter or scene it rests on.
- **Reconstructing the manuscript or a prior report from memory.** Always read fresh from disk at the start of every run.
- **Applying critic findings without adjudication.** The critic informs; the orchestrator decides. Reject anything that flags deliberate form or belongs to another stage.
- **Looping past 3 rounds, or oscillating** by re-applying a change a prior round reversed.
- **Printing the review or the critique transcript to the terminal.** Only the one-line confirmation goes there.
- **Appending a manual second-pass prompt.** The critique loop is the second pass.
