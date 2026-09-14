---
name: story-update-bible
description: "Reconciles a story's creative bible (_Index.md) to the finished manuscript through an author interview, converting the pre-draft forecast into the discovered, now-fixed bible the developmental edit measures against. It rewrites _Index.md only after the author approves."
when_to_use: "Use when the author invokes /story-update-bible on a complete, beta-read manuscript, after the beta read and before the developmental edit (pipeline stage 2.5). Whole-work only, no arguments. Do NOT run on a partial or still-malleable draft (the premise is not fixed until the first final draft is done). Do NOT use for chapter metadata sync (use /update-chapter) or a consistency audit (use /story-audit). Follow all steps in order; do not shortcut based on this description."
effort: high
disable-model-invocation: true
---

## Steps

### 1. Confirm the model and the moment

This pass benefits from a top-tier model. If you are on a mid- or low-tier model (e.g. Sonnet or Haiku), tell the author and suggest switching to the strongest available model with `/model` before proceeding; wait for their response.

Locate the story:
- If the working directory is a story folder (contains `_Index.md` and either a `Chapters/` folder or chapter files at the root), use it. Otherwise list the story folders under the vault root and ask which one.
- Ask once: "Is this the first final draft, complete and beta-read? The bible is only worth fixing once the manuscript is done; while you are still rewriting, the premise is still malleable." If no, stop. If yes, proceed.

### 2. Read the manuscript and the current bible fresh

**This step is not optional. ALWAYS read every file fresh from disk with the Read tool at the start of every run, even if you read the same files moments ago in this conversation.** Never reconstruct the manuscript or the bible from memory or cached context. The author edits between runs, so prior analysis is stale by definition; the files on disk are the only source of truth. If you cannot read the files this turn, stop and say so.

Read, in full:
- The whole manuscript: every `Chapters/*.md` in filename order, or the single root story file for a short story.
- The current `_Index.md` (the bible you are reconciling).
- The writing-style skill at `../.claude/skills/writing-style/SKILL.md`: the author's aesthetic, used to keep Craft & voice accurate and to recognize deliberate form.
- This story's `CLAUDE.md` and the vault-level `CLAUDE.md`.
- Character files under `_Characters/` if present (for Craft & voice accuracy).

### 3. Derive and diff (reconcile, not regenerate)

Work out what the finished book actually is, then compare it to the bible. Do not regenerate the bible from scratch: a blind rewrite would discard intent the prose cannot show (see **## Scope**, Preserve).

For the in-scope sections (Premise, Themes, Craft & voice, World rules), build three lists against the current `_Index.md`:
- **Orphans:** claims in the bible the prose does not support (e.g. a motif or riff named in the bible but never written). Candidates for removal.
- **Gaps:** things the prose establishes that the bible omits (e.g. a running character-naming motif). Candidates for addition.
- **Drift:** the bible says X but the prose shows X'. Candidates for correction.

Verify orphans before trusting them: confirm the claim is genuinely absent from the prose, not merely phrased differently. Apply the writing-style skill so deliberate form (ambiguity, perspective bleed, contradiction, dark comedy) is never mistaken for drift.

Do not change anything yet. Carry these three lists into the interview.

### 4. Interview the author (the validation step)

This is the core of the skill and its only validation; there is no critique loop. The author is the validator. Walk the deltas from step 3 with the author, following **## The interview**. Resolve one item at a time, each with a recommended answer. Bound it: ask only about genuine deltas and genuinely ambiguous or load-bearing intent; never march through every line or re-confirm what the prose establishes uncontroversially.

Apply the **## Circularity guard** throughout: capture not just what the prose achieves but what it is reaching for, and record aspirations as aspirations.

### 5. Propose the rewritten _Index.md and get approval

Assemble the full proposed `_Index.md`:
- Reconcile Premise, Themes, Craft & voice, World rules per the resolved interview.
- Preserve Locked decisions and every out-of-scope section (Blurb, the Stats `dataviewjs` block, frontmatter) byte-for-byte.
- Remove the pruned sections (Resolved from the original draft, Final beats, Key lines).

Present the complete proposed file to the author. **`_Index.md` is a story file; do not write it until the author explicitly approves.** If they want changes, revise and re-present.

### 6. Write and confirm

On approval, write `_Index.md` in place with the Write tool; quoted prose may carry em-dashes and they must be preserved verbatim.

Print one line to the terminal: the saved path and a brief change summary (sections reconciled, orphans removed, gaps added, sections pruned). Then tell the author the bible is locked and they can run `/story-dev-edit` next.

---

## Scope

**Reconcile to the prose.** Re-derive each from the finished manuscript, then resolve every delta with the author in the interview:
- **Premise:** what the book actually is now, tight (a few sentences). The forecast in the old bible may describe a different story, even a different genre.
- **Themes:** the themes the prose actually carries. These are deliberately implicit (the author shows, never declares), so they cannot be read off the surface; the interview confirms which are intended and which the prose is only reaching for (see **## Circularity guard**).
- **Craft & voice:** the story-specific voice and technique the prose establishes (each character's register, structural devices). Keep only what is specific to this book; let the writing-style skill own the general aesthetic. Drop fragments from earlier sessions the prose no longer supports.
- **World rules:** the rules the finished prose actually operates by, including any mechanic the prose introduced that the bible never recorded.

**Preserve, copy byte-for-byte.**
- **Locked decisions:** settled authorial choices the prose cannot reveal on its own (e.g. a name's deliberate echo, an intentionally ambiguous ending). Never re-derive or drop these.
- Any section not named under Reconcile or Prune, including the Blurb, the Stats `dataviewjs` block, and the frontmatter.

**Prune, remove entirely.**
- **Resolved from the original draft:** a log of roads not taken in a draft nobody has; nothing in the finished text to act on.
- **Final beats:** a beat sheet redundant with the prose that drifts the moment chapters change.
- **Key lines:** verbatim quotes that already live in the chapters.

If a story's `_Index.md` does not contain one of these sections, skip it; do not invent it.

## The interview

Resolve the deltas from step 3 one at a time, each as a single question carrying a recommended answer, in the manner of `/grill-me`. Do not batch.

For each orphan, gap, or drift, have the author classify it:
- **Intended:** keep it, stated accurately in the bible.
- **Accidental but keep:** the prose did something unplanned the author endorses; record it as intent.
- **A miss to fix later:** the prose falls short of the intent; do not delete the intent, record it (as an aspiration, see the guard) so the dev-edit can target the gap.
- **Drop:** an orphan the author does not want; remove it from the bible.

Recommend a classification for each, based on the prose and the writing-style skill, but the author decides. Keep the interview bounded: skip anything the prose establishes uncontroversially that the bible already states correctly. If a section has no deltas, say so and move on.

## Circularity guard

**This step is not optional.** A bible copied from what the prose achieves can never show a gap between intent and execution, which is exactly what the developmental edit exists to find. A bible reconciled only to achievements is useless to the edit.

When capturing Themes and intent, separate two things and record both:
- **Achieved:** what the prose already delivers.
- **Reaching for:** what a scene, arc, or theme is trying to do but may not fully land.

Ask "what is this reaching for?" wherever intent outruns execution, and write aspirations into the bible explicitly (marked as such), not as if already achieved. This is what gives the dev-edit a real target.

## What to avoid

- **Regenerating the bible from scratch.** This skill reconciles: it diffs and preserves. A blind rewrite discards Locked decisions and other intent the prose cannot show.
- **Skipping the interview.** The author is the only validator; there is no critique loop. Never assert intent from the page alone.
- **Recording only achievements.** Without aspirations (the circularity guard), the bible cannot serve the dev-edit.
- **Writing `_Index.md` without explicit approval.** It is a story file; present the full proposed file and wait.
- **Touching out-of-scope sections.** Blurb, Stats block, frontmatter, and Locked decisions are preserved byte-for-byte.
- **Running on a partial or still-malleable draft.** The premise is not fixed until the first final draft is complete; before that there is nothing stable to lock.
- **Mistaking deliberate form for drift.** Ambiguity, perspective bleed, contradiction, and dark comedy are this author's register (writing-style is the authority), not orphaned claims to prune.
- **Marching through every line.** Bound the interview to real deltas and load-bearing intent.
