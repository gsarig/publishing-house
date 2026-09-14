---
name: story-personas
description: "Builds target-audience and hostile-critic beta-reader personas for a story, and calibrates existing personas against accumulated beta-read reactions, saved under _personas/."
when_to_use: "Use when the author invokes /story-personas. No argument (or 'discovery') drafts and refines personas interactively; 'calibrate' hardens existing personas using cross-round beta-read reactions. Run discovery once before the first beta-read; run calibrate between rounds. Do NOT auto-invoke from conversations that drift near 'audience' or 'readers'. Follow all steps in order; do not shortcut based on this description."
argument-hint: "[calibrate]"
effort: high
disable-model-invocation: true
---

## Steps

### 0. Determine the mode

If the author passed `calibrate` as the argument, or chooses "Calibrate" from the menu in step 3, go to **## Calibrate mode** near the bottom. Otherwise run discovery: steps 1 through 8.

### 1. Locate the story folder

If the current working directory is a story folder (contains `_Index.md` and either a `Chapters/` folder or chapter files at the root), use it.

If not, list the story folders under the vault root and ask the author which one to work on.

### 2. Load context

Read the following in full:
- The story's `CLAUDE.md`
- The story's `_Index.md`
- Any existing files under `_personas/` if the folder already exists.

### 3. Check existing personas

If `_personas/` already contains persona files, ask the author one of these:
- Add to existing personas (keep what is there, create additional ones).
- Replace existing personas (start fresh).
- Review only (no new work; summarise what is saved and stop).
- Calibrate (offer this only if `_reviews/_full/beta/` holds at least two rounds): harden the existing personas against cross-round reaction reversals. If chosen, go to **## Calibrate mode**.

Wait for the choice before proceeding.

### 4. Opening discovery (structured)

Use `AskUserQuestion` for the following, one question at a time. These set the frame for everything that follows.

1. **Genre and sub-genre.** Offer 3-4 reasonable options based on `_Index.md`, plus Other.
2. **Comp titles.** 2-3 stories or books this work compares to (in tone, audience, or experience). Free text.
3. **Target reader.** Who do you most want this story to land with? Offer 3-4 archetypes from the genre, plus Other.
4. **Explicit non-audience.** Is there a reader you specifically do NOT want to reach? Free text or "no preference".
5. **Desired reaction.** What should the reader walk away feeling? Options: laughter, melancholy, awe, discomfort, recognition, Other.

Do not turn this into a grilling. Use the answers to inform the conversation that follows. If the author seems unsure, offer your reading of the story from `_Index.md` and ask them to refine.

### 5. Conversational persona drafting

For each persona (aim for 3 to 5 target-audience personas), have a back-and-forth:

- Propose a persona archetype with a specific shape (e.g. "a 45-year-old reader who grew up on Vonnegut and Borges and now reads literary speculative fiction in translation"). Suggest a name. Give a short demographic sketch.
- Ask the author: does this person feel like a real reader for this story? What would you change?
- Refine until the author says yes.
- Capture: name, demographic sketch, reading background, what they want from a story, what they will not tolerate, voice and register cues for impersonation.

Aim for diversity across personas: different ages, different reading backgrounds, different reasons they might pick up this story. Avoid clones.

### 6. The hater

After the target personas are done, draft "the hater": a hostile but grounded critic who reads and knows the genre deeply, holds it to a high bar, and finds specific reasons to dislike THIS book.

**The hater is not someone who hates the genre.** That critique is worthless ("I don't like horror books" tells you nothing about your horror book). The hater is the opposite: a reader who respects the form, has read the best of it, and judges this work against that standard. Their value comes from being right about specific failures, not from being contrarian. No lazy dismissals, no genre-level excuses, no troll energy. The hater's complaints should make the author wince because they land.

Propose the hater archetype with this in mind (e.g. "a horror fan who has read everything by Shirley Jackson and finds modern horror that explains its own monsters tedious"), refine with the author, capture the same fields as the target personas.

### 7. Write the persona files

For each persona, write one file to `_personas/<slug>.md`. Slug is lowercase-kebab, derived from the archetype (e.g. `target-vonnegut-reader.md`, `target-litfic-skeptic.md`, `hater.md`).

Each file uses this structure:

```markdown
---
name: <Persona Name>
type: target | hater
date: <YYYY-MM-DD>
---

# <Persona Name>

## Demographic sketch
<one or two sentences>

## Reading background
<favorite authors, genres they reach for, what they avoid>

## What they want from a story
<the experience they are after>

## What they will not tolerate
<specific dealbreakers>

## Voice and register
<how they would describe a book they loved or hated, in their own register; include 1-2 short example sentences>

## Standing positions
<Optional. Fixed, generalizable aesthetic stances that keep this reader's verdict consistent across drafts. Each is a taste principle, never tied to a specific story or its elements. Omit the section if there are none. Added during discovery when the author names a hard stance, or later by calibrate mode. Example: "Treats name or plot homages as a crutch; docks a story that leans on an outside reference instead of generating the effect itself.">
```

If the folder `_personas/` does not exist, create it.

### 8. Confirm

List the files written, one per line, with their full paths. End with this one-line reminder: "When the draft is complete and self-revised, run `/story-beta-read` to run all personas at once."

## Calibrate mode

Calibration hardens existing personas so the same reader gives the same verdict on unchanged text across rounds. It is analysis, not a cold read: here you may read everything (reactions, snapshots, the manuscript). You are editing persona files, not impersonating anyone.

### C1. Preconditions

Require `_personas/` populated and at least two rounds under `_reviews/_full/beta/`. With fewer than two rounds there are no cross-round reversals to calibrate; say so and stop.

### C2. Gather reactions

For each persona slug, read its reaction in every round (`_reviews/_full/beta/round-*/<slug>.md`).

### C3. Detect reversals

Per persona, find elements the reader praised in one round and panned in another (or the reverse). List them. A persona with no reversals needs no calibration; leave it untouched.

### C4. Attribute each reversal

For each reversal, decide whether the underlying prose actually changed between those rounds. Ask the author (they know what they revised), or diff the frozen snapshots (`round-A/_manuscript` against `round-B/_manuscript`) to confirm.

- **Text changed** then the new reaction is legitimate. Do not harden; note it and move on.
- **Text unchanged** then the reader flipped on something that did not move. This is instability, and the persona is underspecified on that dimension. It is a candidate to harden.

### C5. Drop reversals on locked decisions

A reversal is only worth hardening if the author might still act on the element. Before proposing anything, remove every candidate that concerns a decision the author has finalized: the reader's verdict on a locked element is feedback the author will filter regardless of whether it is consistent, so stabilizing it just schedules noise into every future round.

Find the locked decisions three ways: read the story's `_Index.md` (its Locked decisions section and world rules record finalized choices), read each round's `_decisions.md` under `_reviews/_full/beta/round-*/` if present (the author's per-round decision log; a ticked or "locked" item there is a finalized choice), and ask the author whether any surviving candidate touches something they consider final. Drop the locked ones and say which you dropped and why. What remains is a reversal on something still in play, the only kind worth hardening.

### C6. Propose standing positions

For each remaining unchanged-element reversal, draft one generalizable standing stance that would have made the reader consistent: a fixed taste principle, phrased so it applies to any draft, never naming a story element. Present every proposal to the author alongside the reversal it resolves.

### C7. Approve

The author accepts, edits, or rejects each proposed stance. Only approved stances proceed.

### C8. Write

Add each approved stance to that persona's `## Standing positions` section (create the section if it is absent). This is the only write calibration makes. Change nothing else in the persona file.

### C9. Confirm

List the personas updated and the stances added to each. Remind the author that the next beta-read round will run with the hardened personas.

Also update `_personas/_calibration.md` (create it if missing): set `calibrated_through` in its frontmatter to the latest round whose reactions this calibration analyzed, and append one log line per stance added. The beta-read round preflight reads this marker to avoid re-analyzing rounds that calibration has already covered.

## Critical

A persona file must stay readable by someone who has never seen the story. Never write manuscript content, plot points, character names, or any spoiler into one. Calibration adds only generalizable reader-taste principles; reject any proposed stance that names a story element. And only harden reversals where the underlying prose did **not** change: hardening a reaction that changed because the text changed just overfits the persona to one draft and manufactures the false consistency calibration exists to avoid. Likewise, never harden a reversal about a decision the author has locked; the author filters that complaint either way, so stabilizing it only schedules noise.

## What to avoid

- Generating personas without the author in the loop. The author drives; you propose and refine.
- Generating identical-feeling personas. Diversity is the point of having several.
- Falling back to generic personas if the author is unsure. Stop and ask; do not generate.
- A hater who dislikes the genre, the form, or the author's whole project. The hater must operate from inside the genre's standards, not outside them.
