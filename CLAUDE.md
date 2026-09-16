# Fiction Writing Rules (Global)

These rules apply to all stories in this vault. Story-specific rules in each story's own `CLAUDE.md` override these where they conflict.

## First-time setup

The `writing-style` skill ships unconfigured: it is a one-time interview that writes itself into the author's real style reference. Run `/writing-style` once before the first editorial pass. Until then, editorial skills that load it must stop and point the author at that setup (isolated sub-agents judge against neutral craft standards instead). Likewise, `_Author.md` at the vault root ships as a placeholder; fill it before the first KDP export.

## Language Rules

Applied during the `/story-line-edit` and `/story-copy-edit` passes.

- The target is natural, idiomatic English prose, not formal or translated-sounding. If the author writes in English as a non-native speaker, flag phrasing that reads as calqued from their native language: unnatural article use, literal preposition choices, calqued idioms, awkward word order.
- Prefer simple, direct sentence structure. Flag run-on sentences built on stacked subordinate clauses.
- Watch for: excessive passive voice, adjective order errors, misplaced adverbs, and plural/singular agreement errors.
- Do not auto-apply corrections. Present findings with the original text, the issue, and a suggested fix. Let the author decide.

## Developmental Editing Defaults

Applied during the informal per-chapter `/dev-edit` pass (drafting-time) unless the story's `_Index.md` overrides them. The whole-manuscript `/story-dev-edit` (stage 3) uses its own axes and stays at developmental altitude; these chapter-level defaults do not bind it.

- Flag telling instead of showing in emotional beats.
- Flag pacing issues: scenes that stall without narrative purpose, and transitions that rush significant moments.
- Flag on-the-nose dialogue or dialogue that exists only to deliver exposition.
- Flag repetition of words, phrases, or ideas within a chapter.

## Editing Rules

Never modify the content of a chapter or story file unless explicitly instructed to do so. When reviewing a chapter, present suggestions only; the author applies changes manually. The only exception is batch operations (e.g. renaming a character across all files) when explicitly requested.

`/update-chapter` may only modify frontmatter and tracking files (Timeline.md, Character files, Location files). It must never alter chapter prose.

## Consistency Rules

- Use character names exactly as they appear in their Character file. Flag any variation.
- Use location names exactly as they appear in their Location file. Flag any variation.
- Flag any contradiction with the story's `Timeline.md`.
- When uncertain about a world detail, check `_Index.md` before suggesting.
- If a Character file says a character is dead, do not write them as alive.

## Folder Icons (Iconize)

The vault uses the Iconize plugin. Live assignments live in `.obsidian/plugins/obsidian-icon-folder/data.json` as a flat top-level map of vault-relative path → icon (native emoji or `Li…` Lucide names).

The canonical folder→icon convention is `_Templates/folder-icons.json` (bare folder name → icon). It is the single source of truth; edit it to change the convention. When creating any standard story subfolder, look up its name there and add the matching `"{Story}/{Folder}": "<icon>"` entry to `data.json`. Only `Chapters` uses a colored icon (📗); every other folder uses a black-and-white Lucide icon. Current mapping: `Chapters` 📗, `_Characters` `LiUsers`, `_Locations` `LiMapPinPen`, `_Assets` `LiImages`, `_Notes` `LiNotebookPen`, `_Research` `LiMicroscope`, `_listens` `LiHeadphones`, `_personas` `LiDrama`, `_reviews` `LiStarHalf`, `_Publish` `LiBookUp`, `_Promo` `LiMegaphone`.

New entries take effect after Obsidian reloads the plugin (reload or restart), not while the app is open.

## Story Context

Whenever the user references a specific story by name, check whether a folder for that story exists in the vault before responding. If it does, read the story's `CLAUDE.md` and `_Index.md` in full, plus `_Lore.md` where one exists (only some stories have it), before engaging with any question about that story. Do not rely on memory or prior context alone.

## Spoiler hygiene: keep story CLAUDE.md files reader-clean

The beta-read orchestrator runs each persona as an isolated sub-agent, and the harness injects every ancestor `CLAUDE.md` (this global file and the story's own) into that sub-agent before it reads a word. Anything in a `CLAUDE.md` therefore reaches the cold readers verbatim. So:

- A story's `CLAUDE.md` carries no creative-bible or spoiler content: no blurb, premise, themes, world rules, character voice, developmental focus, locked decisions, or final beats.
- All of that lives in the story's `_Index.md`, which is the bible. It is auto-read for authoring (see Story Context above) but never copied into a beta reader's read-set.
- Keep this global file spoiler-free too: no story-specific reveals belong in it.

`/new-story` scaffolds new stories this way by default. If you find an existing story whose `CLAUDE.md` still holds bible content, move it into `_Index.md` and reduce the `CLAUDE.md` to a spoiler-free stub before running a beta read.

## Session Start

If the author's first message in a new session is a greeting, vague, or does not specify a task, respond with a brief welcome and present the available commands as options. Do not do this if the first message is already specific about what they want to work on.

## Editorial Workflow Stages

The canonical editorial pipeline, modeled on professional fiction publishing. Big-to-small is the load-bearing principle: each stage assumes the previous one is settled. Working out of order wastes effort and anchors the author to prose that should be cut.

| # | Stage | Owner | Scope | What it does | Command |
| --- | --- | --- | --- | --- | --- |
| 1 | Self-revision | Author (human only) | Whatever the author chooses | Author reads own draft, fixes what they see, kills darlings. Never delegated to AI. | (human only, no command) |
| 1.5 | Quick clean | AI | Full work | Whole-manuscript triage of obvious language errors (broken grammar, typos, blatantly non-idiomatic phrasing, name inconsistencies, glaring repetition) before the beta read, so cold readers react to the story, not to surface mistakes. Present-only; not a line edit. | `/story-quick-clean` |
| 2 | Beta read | AI (personas) | Full completed draft only | Reader-reaction signal across the whole story arc. One orchestrator run fans out all personas in parallel as isolated sub-agents. Not craft analysis. | `/story-beta-read` (run `/story-personas` once first to create the personas) |
| 2.5 | Bible reconcile | AI + author | Full work only | Reconcile `_Index.md` (premise, themes, craft & voice, world rules) to the finished manuscript via author interview, so the dev-edit measures against accurate intent rather than the pre-draft forecast. | `/story-update-bible` |
| 3 | Developmental edit | AI | Full work only | Structure, pacing, character arcs, plot logic, theme. | `/story-dev-edit` |
| 4 | Line edit | AI | Per-chapter | Sentence-level craft: voice, rhythm, redundancy, weak verbs. Assumes grammar is correct. | `/story-line-edit ch-XX` |
| 5 | Copy edit | AI | Per-chapter | Grammar, CMOS, punctuation, syntax, idiom, continuity. Assumes voice is settled. | `/story-copy-edit ch-XX` |
| 5.5 | Listen (flow check) | Author (human, TTS) | Per-chapter | Listen to the chapter read aloud (Edge TTS) and fix flow potholes by hand; a substantive rewrite goes back through `/story-copy-edit`. | `/story-listen ch-XX` |
| 6 | Proofread | AI | Per-chapter | Final fresh-eye sweep. Typos and formatting errors only. | `/story-proof ch-XX` |
| Cross | Continuity audit | AI | Full work | Standalone consistency check. Runnable any time. | `/story-audit` |
| Cross | Persona calibration | AI | Personas | Harden personas against cross-round reaction reversals, but only where the underlying prose did not change. Runs between rounds. | `/story-personas calibrate` |

Second-pass critique is built into each editorial skill as an internal critique loop, not a manual step: after writing its review the skill spawns an independent critic sub-agent, adjudicates the findings against the writing-style skill and the story's locked decisions, and hardens the review in place (see `story-copy-edit` and `story-dev-edit`). Beta read is the exception: it runs no second pass because its multiple personas already supply independent signal.

Skill outputs live in `_personas/` and `_reviews/` at the story root. Whole-work reviews under `_reviews/_full/<stage>/`, per-chapter reviews under `_reviews/<chapter>/<stage>/`. Progress is tracked by folder presence, not by a separate state file: a stage folder existing means that review was generated. Whether the author has applied a per-chapter pass is tracked separately, by hand, in the chapter's `edit_pass` frontmatter field.

## Commands

| Command | Purpose |
|---------|---------|
| `/writing-style` | One-time setup interview that writes the author's style reference (run before the first editorial pass) |
| `/new-story` | Build a story blueprint from an idea in `_Ideas.md`, or scaffold an empty novel/novella/short story |
| `/continue-story` | Re-entry brief for returning to a story after time away |
| `/update-chapter ch-XX` | Post-chapter state sync, updates Timeline, Characters, Locations, checks Quicknotes |
| `/dev-edit ch-XX` | Informal drafting-time developmental pass on a chapter (the pipeline's stage 3 is `/story-dev-edit`) |
| `/story-quick-clean` | Whole-manuscript triage of obvious language errors before a beta read (stage 1.5) |
| `/story-personas` | Create beta-reader personas (once, before the first beta read); `calibrate` hardens them between rounds |
| `/story-beta-read` | Run a full beta-read round: all pending personas in parallel as isolated sub-agents (stage 2) |
| `/story-update-bible` | Reconcile `_Index.md` to the finished manuscript before the dev-edit (stage 2.5) |
| `/story-dev-edit` | Whole-manuscript developmental edit (stage 3) |
| `/story-line-edit ch-XX` | Line edit: sentence-level craft on a chapter (stage 4) |
| `/story-copy-edit ch-XX` | Copy edit: grammar, CMOS, idiom, continuity on a chapter (stage 5) |
| `/story-listen ch-XX` | Listen pass: chapter prose read aloud for a human flow check (between stage 5 and 6) |
| `/story-proof ch-XX` | Proofread: typos and formatting on a chapter (stage 6) |
| `/story-audit` | Full consistency audit across all chapters |
| `/story-manual-revise` | Validate a single author-decided wording change (grammar, idiom, repetition, continuity) before applying it by hand |
| `/pdf-convert` | Render chapters into a styled manuscript PDF, for reading a draft as a book (general Markdown-to-PDF skill) |
| `/story-kdp-export` | Build the KDP-ready files of a story (title page, TOC, standard back matter): the ebook EPUB and/or the 6x9 paperback interior PDF. The EPUB and print PDF are uploaded to KDP directly; no KPF is produced |
| `/story-cover-check` | Simulate a cover on a grayscale e-ink reader and measure text readability before uploading to KDP |
| `/publish-prep` | Create promo files and publication record when ready to publish |
| `/archive-story` | Move a completed or abandoned story to the archive |

## Paperback cover pre-flight

The interior PDF comes from `/story-kdp-export`; the wrap-around cover is designed by the author in their own tool. Before uploading a cover to KDP, follow the checklist in the vault-root note `_KDP cover pre-flight.md` (spine width formula, PDF/X-1a export, color soft-proofing, previewer checks). For e-ink readability of the cover text, run `/story-cover-check`.

## Author profile note

`_Author.md` at the vault root is the evergreen author record: the bio and the list of published books with their store links and blurbs. `/story-kdp-export` embeds its two exported sections verbatim as the back matter of every ebook and paperback, so when a new book publishes or the bio changes, update `_Author.md` (respecting the format contract in its header comment) rather than editing any skill or template. It ships as a placeholder; fill it before the first export.
