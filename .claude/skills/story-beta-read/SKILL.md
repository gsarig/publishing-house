---
name: story-beta-read
description: "Orchestrates a full beta-read round: freezes a prose-only manuscript snapshot, then runs every pending reader persona in parallel as isolated sub-agents, one reaction file each under _reviews/_full/beta/round-NN/. Reactions are kept per round, never overwritten. Starting a new round after two or more completed rounds first runs a convergence-and-calibration preflight."
when_to_use: "Use when the author invokes /story-beta-read after self-revising the whole manuscript. No argument runs all not-yet-reviewed personas for the round in parallel; passing one or more persona slugs runs just those. Do NOT run on isolated chapters or a partial draft. Do NOT auto-invoke. Follow all steps in order; do not shortcut based on this description."
argument-hint: "[persona-slug ...]"
effort: high
allowed-tools: Bash(awk:*) Bash(stat:*) Bash(mktemp:*) Bash(mkdir:*) Bash(cp:*) Bash(rm:*) Read Glob Write
disable-model-invocation: true
---

## Steps

### 1. Locate the story, check personas, confirm the draft

- If the working directory is a story folder (contains `_Index.md` and either a `Chapters/` folder or chapter files at the root), use it. Otherwise list the story folders under the vault root and ask which one.
- Verify `_personas/` exists and contains at least one persona file. If it is missing or empty, stop and tell the author: "No personas found. Run /story-personas first to discover beta-reader personas for this story." Do not fall back to generic readers; that defeats the persona discovery step.
- Spoiler-hygiene precondition: read the story's `CLAUDE.md` and confirm it carries no creative-bible content. If it contains any of `World Rules`, `Character Voice`, `Developmental Focus`, `Locked decisions`, `Premise`, `Themes`, `Final Beats`, or `Blurb`, stop and tell the author to move that content into `_Index.md` and reduce `CLAUDE.md` to a spoiler-free stub first. The injected `CLAUDE.md` leaks into every cold reader and the scratch dir cannot compensate. Proceed only once it is a stub.
- The persona sub-agents inherit the session model, so this run should happen on a top-tier model. If the session is on a mid- or low-tier model (e.g. Sonnet or Haiku), tell the author and suggest switching with `/model` before proceeding; wait for their response.
- Ask once: "Is the manuscript complete and self-revised? Beta-read is meaningless on a draft you are still actively rewriting. I will then run the personas in parallel as separate sub-agents." If no, stop. If yes, proceed.

### 2. Resolve the round and freeze the snapshot

Do this once, here, before any persona runs. See **## Rounds** below. The orchestrator, not "the first persona", always creates the round folder and the frozen snapshot and records `draft_modified`. Freezing once, up front, is what makes the parallel fan-out safe.

### 3. Determine which personas to run

- Enumerate persona slugs with Glob on `_personas/*.md`. Enumerate finished reactions with Glob on `_reviews/_full/beta/round-NN/*.md` (ignore `_round.md` and `_manuscript/`).
- If the author passed one or more slugs as arguments, the target set is those slugs; verify each `_personas/<slug>.md` exists. Otherwise the target set is every persona that has no `round-NN/<slug>.md` yet.
- If the target set is empty (all personas already reviewed in this round), say so and ask with `AskUserQuestion` whether to re-run them all in this round (overwrites those files) or start a new round instead. Do not silently re-run.
- You do not need to read persona bodies here. The orchestrator never impersonates anyone, so it cannot contaminate a reaction; each sub-agent reads its own persona file.

### 4. Fan out: one isolated sub-agent per persona

First copy the target-set persona files (from step 3) into the scratch dir, by slug: `cp _personas/<slug>.md "$SCRATCH/_personas/"` for each. Copy only those being run this round, nothing else.

Then spawn the target personas as a single parallel batch. For each persona, make one `Agent` call with `subagent_type: general-purpose` and no `model` override (the sub-agent inherits the session model; never pin a named model, it goes stale and caps quality when stronger tiers ship), passing the brief in **## Per-persona reader brief** with the placeholders filled in, including `<scratch>` (the absolute `$SCRATCH` path from step 2). Every path in the brief points into `$SCRATCH`; no brief may name a path inside the vault, so no sub-agent ever has a `CLAUDE.md` ancestor. Order does not matter; the agents run independently and cannot see each other, which is the isolation the old "fresh session per persona" rule used to provide by hand.

### 5. Collect and report

After the batch returns:

- Each sub-agent wrote its reaction into `$SCRATCH/reactions/<slug>.md`. Copy every reaction back into the durable round folder: `cp "$SCRATCH/reactions/"*.md round-NN/`. This copy-back is the orchestrator's job; the orchestrator may touch the vault freely because it never impersonates a reader.
- Glob `round-NN/*.md` and confirm one reaction exists for every targeted slug. For any missing (a sub-agent that failed, so no scratch reaction to copy), name it and offer to re-run just that one; do not abort the whole round over a single failure.
- Once all expected reactions are copied back, remove the scratch dir: `rm -rf "$SCRATCH"`. (Leave it in place if you are about to re-run a failed persona, then clean up after.)
- Print one line per persona with its overall sentiment, from each sub-agent's returned summary.
- End with a one-line reminder: after reading the reactions, record what you decide (changes and locked-as-is calls) in `round-NN/_decisions.md`; the next round's preflight reads it.
- Do not offer calibration here. It runs automatically as the **## Round preflight** the next time a round starts; a post-round offer competes with reading the reactions and gets skipped.

Do not emit a second-pass prompt. Beta-read gets no second-pass critique; the multiple personas already provide built-in diversity.

---

## Rounds

Beta reactions are kept per revision and never overwritten across rounds, so you can compare reader reactions on successive drafts. Each round is a self-contained folder under `_reviews/_full/beta/`:

```
_reviews/_full/beta/
  round-01/
    _manuscript/       frozen copy of the draft this round read
    _round.md          round number, date, draft mtime reviewed
    _decisions.md      the author's decision log for the round (author-written)
    <slug>.md          one reaction per persona
  round-02/
    ...
```

**`_decisions.md` is the author's per-round decision log.** After reading the reactions, the author records what they decided: items to change (as a task list) and items they considered and locked as-is. It is author-maintained; no skill writes it. It is consumed downstream: calibrate mode (`/story-personas calibrate`, step C5) reads each round's `_decisions.md` to identify locked decisions, so recurring complaints about settled choices stop being hardened into personas.

**Resolve the target round before freezing anything.**

1. With the Glob tool, list the `round-NN` folders under `_reviews/_full/beta/`. The highest NN is the current round.
2. If none exist, the target is `round-01`. (If reaction files exist directly under `beta/` from before rounds existed, treat them as `round-01`.)
3. If rounds exist, ask once with `AskUserQuestion`: continue the current round, or start a new one (next NN)? Continue while still gathering personas for the same draft; start a new round when the draft has been revised since the last round. If the author chooses a new round and two or more completed rounds exist, run the **## Round preflight** before creating the round folder or freezing anything.
4. "Already reviewed" is scoped to the chosen round: a persona is done only if `round-NN/<slug>.md` exists in that round. A new round re-offers every persona.

**Freezing the round** (the orchestrator does this once, in step 2, before spawning any sub-agent). If the target round folder has no `_manuscript/` yet: create `round-NN/`, then snapshot the manuscript **prose only** into `round-NN/_manuscript/`, stripping the YAML frontmatter from every file (the chapter files, or the single root story file). The frontmatter (`timeline_events`, `characters`, `locations`, and the like) is authorial metadata that spoils the story; a real reader never sees it, so it must not reach the snapshot. Strip it with a stream transform that drops the leading `---`-delimited block and writes the body verbatim, one file at a time:

```
for f in Chapters/ch-*.md; do
  awk 'NR==1 && $0=="---"{fm=1; next} fm && $0=="---"{fm=0; next} !fm{print}' "$f" > "round-NN/_manuscript/$(basename "$f")"
done
```

**Never use the Write tool** for the snapshot: the prose must stay byte-identical, and Write both risks altering it and is blocked by the em-dash guard on any chapter containing U+2014. `awk` (or `sed`) streams the bytes through untouched, so it is safe; allowlisting `Bash(awk:*)` silences its prompt. Record `draft_modified` once, from the **live source** files, not the snapshot (the strip rewrites each file, so the copies' mtimes are just the copy time): take the latest mtime across the source glob with a single `stat -c '%y %n' Chapters/ch-*.md` command. Keep this value; you will pass it to every sub-agent so none of them needs to run `stat`. Then write `round-NN/_round.md`:

```
---
round: NN
date: <YYYY-MM-DD>
draft_modified: <ISO mtime, latest across the live source files>
---

Round NN beta read. Manuscript frozen prose-only in `_manuscript/` (frontmatter stripped).
```

**Every sub-agent reads from the snapshot, never the live `Chapters/`.** This guarantees a round's reactions are all to the same text, regardless of later edits to the working draft. If `round-NN/_manuscript/` already exists (a re-run or a continued round), reuse it; do not re-copy.

---

## Round preflight (new rounds only)

Runs when the author starts a new round and two or more completed rounds already exist. With only one prior round there is nothing to compare; skip silently. This is orchestrator work: reading reactions, decisions, and the bible here is safe because the orchestrator never impersonates a reader and passes none of its own context into the persona briefs.

Read first: every persona reaction in the completed rounds, each round's `_decisions.md` (if present), the Locked decisions in the story's `_Index.md`, and `_personas/_calibration.md` (if present; its `calibrated_through` field says which rounds calibration has already analyzed).

**1. Convergence readout (automatic, read-only).** Compare each persona's last two reactions: overall sentiment and major complaints. Classify every complaint that persists into the latest round as one of: still-open signal (worth acting on), locked (the author already decided it, per `_decisions.md` or `_Index.md`), or fixed taste (a standing position, or the hater re-litigating premise-level choices). Print the per-persona trajectory in a few lines, with each surviving complaint tagged. Weigh the hater correctly: he is hostile by mandate and cannot converge, so his early-round craft findings count heavily while his late-round premise re-litigation counts lightly. If the targets have converged and everything left is locked or taste, say plainly that the beta signal looks exhausted, and ask with `AskUserQuestion` whether to run the round anyway or stop here and move to `/story-update-bible` (stage 2.5). Respect the answer.

**2. Calibration check (automatic analysis, interactive approval).** Consider only rounds after `calibrated_through` (all rounds if there is no marker), plus the last already-analyzed round for comparison. Find reversals: an element a persona praised in one round and panned in another. Attribute each by diffing the frozen `_manuscript/` snapshots of the two rounds; a reversal on prose that changed is a legitimate reaction, drop it. Drop reversals on locked decisions (`_decisions.md`, `_Index.md`). If nothing remains, say so in one line and move on. Otherwise follow **## Calibrate mode** steps C6 to C9 from the `story-personas` skill: propose one generalizable standing stance per surviving reversal, get per-stance approval, and write only what is approved, never a story-specific detail. Never edit a persona file without approval; the analysis is automatic, the write is not.

**3. Record and proceed.** Write `_personas/_calibration.md` with `calibrated_through: round-NN` (the latest completed round) in frontmatter and one log line per stance added, or a "no candidates" line for this pass. Then return to **## Rounds** and freeze the new round; the fan-out runs with the hardened personas.

### Assemble the scratch read-set OUTSIDE the vault (mandatory isolation step)

This scratch dir is **secondary** defense (it stops a sub-agent from *reading* spoiler files); the **primary** defense lives outside this skill and is described in the warning below. A cold-read sub-agent inherits the orchestrator's working directory (the vault), and the harness auto-injects every ancestor `CLAUDE.md` into that sub-agent's startup context before it runs a single tool. Verified empirically: a sub-agent that reads nothing still has the full story `CLAUDE.md` (World Rules, Developmental Focus, Locked decisions) in context. The `Agent` tool exposes no way to set a sub-agent's cwd, so the snapshot-in-`/tmp` trick does **not** prevent this injection; it only prevents file reads. **The injection is stopped only by keeping story content out of `CLAUDE.md` itself** (see the warning at the end of this section). Both defenses together: spoiler-free `CLAUDE.md` (stops injection) plus `/tmp` scratch (stops reads).

Create the scratch dir under `/tmp` and copy the prose in. The persona files are copied later, in step 4, once the target set is known:

```
SCRATCH=$(mktemp -d /tmp/beta-read.XXXXXX)
mkdir -p "$SCRATCH/_manuscript" "$SCRATCH/_personas" "$SCRATCH/reactions"
cp round-NN/_manuscript/*.md "$SCRATCH/_manuscript/"
```

Keep `$SCRATCH` for the whole run; you pass its absolute path to every sub-agent. The in-vault `_manuscript/` archive stays put for cross-round diffing (calibration reads it); scratch is throwaway. Never copy anything but prose and the target persona sheets into it: no `_Index.md`, no `_Notes/`, no `CLAUDE.md`, no non-target persona.

> **CLAUDE.md must contain no story content.** Because the harness auto-injects `CLAUDE.md` into every sub-agent, any creative-bible material in a story's `CLAUDE.md` (Story Identity, World Rules, Character Voice, Developmental Focus, Locked decisions, Open Rules) leaks into every cold reader and is reviewed as if it were the prose. Keep all of that in a separate, non-injected file (e.g. `_Notes/story-bible.md`) that authoring skills read explicitly and beta-read never copies into scratch. A story's `CLAUDE.md` should hold only process/operational notes that would not spoil a first read. If this skill is run against a story whose `CLAUDE.md` still carries creative-bible content, stop and tell the author to move it first; the scratch dir cannot compensate for injected `CLAUDE.md`.

---

## Per-persona reader brief

The orchestrator passes this as the prompt of each `Agent` call (`subagent_type: general-purpose`, no `model` override), with `<slug>`, `<title>`, `<draft_modified>`, and `<scratch>` (the absolute `$SCRATCH` path) filled in. Pass nothing else from your own context.

---

You are impersonating exactly one beta reader giving a cold, first-read reaction to a finished book. Output only that reader's reaction.

Everything you may read lives under one directory: `<scratch>`. **Read ONLY files inside `<scratch>`. Never read, list, or `cd` to any path outside it, for any reason.**
- The persona you are: `<scratch>/_personas/<slug>.md`
- The manuscript: every file in `<scratch>/_manuscript/`, read in filename order.

`<scratch>` deliberately contains nothing but the prose and your own persona sheet. There is no `CLAUDE.md`, `_Index.md`, `_Lore.md`, `Timeline.md`, `_Characters/`, `_Locations/`, `_Notes/`, `writing-style` skill, or other persona anywhere in it or above it. Those hold authorial intent, planned beats, world rules, and locked decisions that may never have reached the prose; a real reader has no access to them, and letting them leak in produces reactions to things that are not in the book. Do not go looking for them outside `<scratch>`; if you cannot find something, it is not part of the book and you do without it. The story's title is "<title>"; take it as given, do not look it up.

Read the manuscript end-to-end as this persona. Stay inside their voice, taste, and standards the whole way. Never break frame to give "the AI's view"; the reaction is the persona's, not yours. Focus on reader experience, not craft analysis:

- Where did I lose interest? (specific chapter, specific scene)
- What did I not believe? (characters, plot beats, world details that broke me out of the story)
- Did the protagonist hold me across the whole arc?
- Did the ending land?
- What did I love? (specific moments)
- Would I recommend this? Would I read it again? What would I tell a friend?

"Nowhere" and "nothing" are valid answers if the book genuinely held. If the persona file has a `## Standing positions` section, those are fixed tastes this reader always applies; honor them.

For a target persona, the reaction is honest and in voice, positive, negative, or mixed. For the hater, it is hostile but grounded: from inside the genre's standards, with specific reasons to dislike THIS book, no lazy genre-level dismissals, no troll energy, and if something grudgingly works, say so; that signal matters.

Write your reaction to `<scratch>/reactions/<slug>.md` (the only file you write; the orchestrator moves it into the round folder afterward) using exactly this structure:

```markdown
---
persona: <slug>
persona_name: <Persona Name, from the persona file>
type: target | hater
date: <today, YYYY-MM-DD>
draft_modified: <draft_modified>
---

# <Persona Name> on "<title>"

## Overall reaction
<one or two paragraphs in the persona's voice, written immediately after finishing>

## What landed
<specific scenes, moments, lines that worked, with brief why>

## Where I lost interest
<specific chapter or scene + why, in the persona's voice; "nowhere" is valid if it genuinely held>

## What I didn't believe
<characters, plot beats, world details that broke immersion; "nothing" is valid>

## Did the protagonist hold me?
<yes / no / mixed, with specifics>

## Did the ending land?
<yes / no / mixed, with specifics>

## The bottom line
<in the persona's own register: would I recommend this? would I read it again? what would I tell a friend?>
```

Then return one line only: "<slug>: <overall sentiment; where you lost interest; did the ending land>".

---

## What to avoid

- Running beta-read on an isolated chapter or a partial draft. It is whole-manuscript or it is nothing.
- Letting the orchestrator impersonate a reader itself, or reading persona bodies into the orchestrator context. The orchestrator only sets up, fans out, and reports; every reaction happens inside an isolated sub-agent.
- Passing your own accumulated context into a sub-agent's brief. Each brief is self-contained: persona file plus snapshot, nothing else.
- Pointing a cold-read sub-agent at any path inside the vault, even just to read the manuscript or to write its reaction. The vault's `CLAUDE.md` (World Rules, Locked decisions, Developmental Focus) is auto-injected into any agent with a vault-tree working surface, so it contaminates the cold read regardless of "do not read it" wording. Every sub-agent path must be under the `/tmp` scratch dir. The in-vault round folder is written only by the orchestrator, on copy-back.
- Copying anything beyond the prose and the target persona sheets into the scratch dir. No `_Index.md`, no `_Lore.md`, no notes, no extra personas. Scratch is exactly what a real reader sees.
- Merging multiple personas into one consensus reaction. Each persona gets its own file, in its own voice.
- Re-copying or re-freezing the snapshot once `_manuscript/` exists for the round. A round's text is frozen exactly once.
- A hater reaction that disparages the genre as a whole or makes lazy excuses ("this kind of book is always bad"). The hater hates from inside the form, not outside it.
- Starting a new round without the preflight when two or more completed rounds exist. The convergence readout and calibration check are what keep late rounds meaningful; skipping them re-serves noise the author has already ruled on.
- Editing a persona file during the preflight without per-stance approval. The analysis is automatic; the write never is.
