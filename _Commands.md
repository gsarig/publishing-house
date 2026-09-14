# Claude Code Commands

Run these from inside a story folder.

> Derived reference for reading inside Obsidian. The canonical list is the Commands table in this vault's `CLAUDE.md`; when commands change, update that table first, then regenerate this file and the commands table in `README.md`. (Last synced: 2026-09-14.)

| Command | Purpose |
|---------|---------|
| `/writing-style` | One-time setup interview that writes the author's style reference (run before the first editorial pass) |
| `/new-story` | Build a story blueprint from an idea in `_Ideas.md` |
| `/continue-story` | Re-entry brief for returning to a story after time away |
| `/update-chapter ch-XX` | Post-chapter state sync: updates Timeline, Characters, Locations, checks Quicknotes |
| `/dev-edit ch-XX` | Informal drafting-time developmental pass on a chapter |
| `/story-quick-clean` | Whole-manuscript triage of obvious language errors before a beta read (stage 1.5) |
| `/story-personas` | Create beta-reader personas; `calibrate` hardens them between rounds |
| `/story-beta-read` | Run a full beta-read round, all pending personas in parallel (stage 2) |
| `/story-update-bible` | Reconcile `_Index.md` to the finished manuscript (stage 2.5) |
| `/story-dev-edit` | Whole-manuscript developmental edit (stage 3) |
| `/story-line-edit ch-XX` | Line edit: sentence-level craft (stage 4) |
| `/story-copy-edit ch-XX` | Copy edit: grammar, CMOS, idiom, continuity (stage 5) |
| `/story-listen ch-XX` | Listen pass: chapter prose read aloud for a human flow check (between stages 5 and 6) |
| `/story-proof ch-XX` | Proofread: typos and formatting (stage 6) |
| `/story-audit` | Full consistency audit across all chapters |
| `/story-manual-revise` | Validate a single author-decided wording change before applying it by hand |
| `/pdf-convert` | Render chapters into a styled manuscript PDF (general Markdown-to-PDF skill) |
| `/story-kdp-export` | Build the KDP-ready ebook EPUB and/or 6x9 paperback interior PDF |
| `/story-cover-check` | Check a cover's text readability on a grayscale e-ink reader before uploading to KDP |
| `/publish-prep` | Create promo files and publication record when ready to publish |
| `/archive-story` | Move a completed or abandoned story to the archive |

---

## Lifecycle

### `/new-story`

Builds a story scaffold: from an idea in `_Ideas.md`, as an empty novel/novella, or as a lean short story. Creates `_Index.md` (the bible), a spoiler-free `CLAUDE.md` stub, `Timeline.md`, `Chapters/`, `_Characters/`, `_Locations/`, and assigns folder icons. Asks about form before building.

### `/continue-story`

Re-entry brief: where the story stands, last chapter recap, open threads, Quicknotes to action, what to write next. Reads the last two chapters plus the bible and tracking files.

### `/update-chapter ch-XX`

Post-chapter sync. Proposes (and applies only after confirmation): timeline entries, character and location file updates, chapter frontmatter, addressed Quicknotes, and any inconsistencies found. Works on single-file short stories too; pass the story filename.

### `/publish-prep`

Creates `_Promo/` (Blurb, Tags, Campaign) and `_Publication.md`, pre-filled from `_Index.md` where possible.

### `/archive-story`

Moves the story to `_Archive/Completed/` or `_Archive/Abandoned/` and updates its status. Asks before applying.

---

## Editorial pipeline

Stages run big-to-small; each assumes the previous one is settled. All editorial passes are present-only: no skill ever edits chapter prose. Outputs land under `_reviews/` (whole-work under `_full/<stage>/`, per-chapter under `<chapter>/<stage>/`).

### `/story-quick-clean` (stage 1.5)

Whole-manuscript triage of obvious errors only (broken grammar, typos, blatantly non-idiomatic phrasing, name inconsistencies, glaring repetition) before the beta read, so cold readers react to the story rather than surface mistakes. Output: `_reviews/_full/quick-clean/quick-clean-YYYY-MM-DD.md`.

### `/story-personas`

Interactive discovery of 3-5 target-audience personas plus one grounded hater, saved to `_personas/`. Run once before the first beta read. `/story-personas calibrate` runs between rounds: it hardens personas against reaction reversals on unchanged prose by adding approved Standing positions.

### `/story-beta-read` (stage 2)

Freezes a prose-only manuscript snapshot, then runs every pending persona in parallel as isolated cold-read sub-agents. Reactions are kept per round under `_reviews/_full/beta/round-NN/`, never overwritten across rounds. Whole completed draft only.

### `/story-update-bible` (stage 2.5)

Reconciles `_Index.md` to the finished manuscript via author interview (orphans, gaps, drift), recording aspirations as aspirations so the dev-edit has a real target. Writes only after explicit approval.

### `/story-dev-edit` (stage 3)

Whole-manuscript developmental edit: structure, pacing, plot logic, character arcs, theme, opening and ending, strengths. Severity-ranked editorial letter, hardened by an internal critique loop. Output: `_reviews/_full/dev/dev-edit-YYYY-MM-DD.md`.

### `/story-line-edit ch-XX` (stage 4)

Sentence-level craft: voice, rhythm, weak verbs, redundancy, filtering. Assumes grammar is correct. Inline markup (~~old~~ / **new**) with sequential Polish Notes, hardened by a critique loop. Output: `_reviews/<chapter>/line-edit/suggestions.md`; re-runs overwrite.

### `/story-copy-edit ch-XX` (stage 5)

Grammar, CMOS, punctuation, syntax, idiom, tense, intra-chapter continuity. Assumes voice is settled. Same format and critique loop. Output: `_reviews/<chapter>/copy-edit/suggestions.md`; re-runs overwrite.

### `/story-listen ch-XX` (between stages 5 and 6)

Human flow-check, not an AI pass. Turns the chapter into spoken audio via Edge TTS (male voice default, female via `--voice`), so the author can listen for flow potholes after copy-edit and before proofread. Writes `_listens/<ch-XX>.mp3` and prints its path; never edits the chapter. Post-listen fixes should be word-level; a substantive rewrite goes back through `/story-copy-edit`.

### `/story-proof ch-XX` (stage 6)

Final fresh-eye sweep: typos and formatting errors only. Signals when copy-edit needs another pass. Output: `_reviews/<chapter>/proof/suggestions.md`; re-runs overwrite.

---

## Cross-cutting

### `/story-audit`

Full consistency audit: timeline, characters, locations, world rules, orphaned notes, frontmatter gaps. Never touches story files. Output: `_reviews/_full/audit/audit-YYYY-MM-DD.md`.

### `/story-manual-revise`

Stress-tests one author-decided wording change (grammar, idiom, CMOS, repetition, continuity, fit) and returns a clean/problem verdict in chat. Never edits files; the author applies by hand.

### `/dev-edit ch-XX`

Informal drafting-time developmental pass on a single chapter, wider-ranging than the pipeline's stage 3 (it may descend to showing-vs-telling and repetition). Findings in chat, nothing persisted. Use it while drafting; use `/story-dev-edit` for the formal whole-work pass.
