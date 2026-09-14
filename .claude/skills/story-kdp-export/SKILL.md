---
name: story-kdp-export
description: "Builds KDP-ready book files from a story's chapters: a reflowable EPUB and/or a 6x9 paperback interior PDF, with title page, table of contents, and the author's standard back matter, styled to match the Kindle Create Classic theme."
when_to_use: "Use when the user wants to export a story for KDP/Amazon publishing in any format: ebook, paperback, or both (e.g. '/story-kdp-export', 'build the epub', 'make the kpf', 'make the kindle file', 'make the paperback', 'build the print interior', 'prepare this story for KDP'). The author may say 'kpf' out of old habit: no KPF is produced anymore; the EPUB this skill builds is what gets uploaded to KDP instead. Do NOT use for beta-read manuscripts or other non-KDP PDFs (use /pdf-convert). Follow all steps in order; do not shortcut based on this description."
argument-hint: "[story folder name]"
model: sonnet
allowed-tools: Bash
---

## Steps

### 1. Resolve the story and its metadata

Identify the story folder from the argument or session context; if ambiguous, ask. All book metadata comes from the frontmatter of the story's `_Index.md`; never retype it from memory or from prose:

- `title:` — required. If empty or missing, stop and ask; do not guess.
- `subtitle:` — optional; pass it to the build with `-s` when present.
- `cover:` — story-root-relative image path; used only for a sideload copy (step 3).
- `status:` — if not `final`, warn that the story may not be ready to publish and get explicit confirmation before continuing.

The author name comes from `<vault>/_Author.md`: the bolded name line directly under `# About The Author`. If it still reads as the placeholder, stop and ask the author to fill in `_Author.md` first. Use that name as `<Author>` everywhere below.

### 2. Preflight checks

**This step is not optional.** Verify, and stop with a report if any check fails:

- Every file in `<story>/Chapters/` matches `ch-*.md`, and `ls | sort` puts them in reading order.
- Every chapter contains exactly one H1 (`grep -c '^# ' file` = 1), positioned right after the YAML frontmatter. The H1 is the chapter title that appears in the book and its TOC.
- `<vault>/_Author.md` is structurally sound: it contains exactly one `# About The Author` line and one `# Books By This Author` line, and inside the Books section every `## ` heading is followed by at least one non-empty, non-heading line before the next heading. A malformed note must fail here, loudly, not ship a broken back-matter page.
- Report the chapter count to the user before building.

### 3. Gather the settings as a wizard

One `AskUserQuestion` call, recommended default first and labeled "(Recommended)":

- **Format**: 1. *Both* (Recommended): EPUB + paperback interior PDF. 2. *Ebook only*. 3. *Paperback only*. Skip questions that only apply to a format not being built.
- **Filename**: 1. *Slug* (Recommended): `<slug>.epub` / `<slug>-paperback.pdf`, lowercased, spaces to dashes, punctuation stripped. 2. *Title as-is*: `<Title>.epub` / `<Title>-paperback.pdf`.
- **Sideload copy** (ebook only): 1. *No* (Recommended): build only the KDP upload file. 2. *Yes*: also build `<name>-sideload.epub` with the `cover:` image embedded, for reading on the author's own e-reader.
- **Back matter**: 1. *Both pages* (Recommended): About The Author + Books By This Author. 2. *About The Author only*. 3. *None*.

The paperback's print spec is fixed and not a wizard question: 6 x 9 in trim, black-and-white on white paper, no bleed, matte cover. If KDP has already assigned the book an ISBN and the user wants it printed on the copyright page, they can say so; there is no wizard prompt for it (`--isbn` flag, optional, KDP does not require it).

If the user already said to use defaults or skip the wizard, accept all recommended defaults without asking.

### 4. Prepare the back matter

The source of truth is the vault-root `_Author.md`. Per the wizard choice, extract its two exported sections into a temp dir (use the session scratchpad, never the story folder), each section from its H1 up to the next H1 (exclusive):

```bash
awk '/^# /{f=($0=="# About The Author")} f' "<vault>/_Author.md" > "<tmp>/about-the-author.md"
awk '/^# /{f=($0=="# Books By This Author")} f' "<vault>/_Author.md" > "<tmp>/books-by.md"
```

Then delete from `<tmp>/books-by.md` the entry for the book being built (its `## ` heading plus the lines under it, up to the next `##` or end of file) if present; note the headings have the form `## [Title](store link)`, so match on the title text inside the brackets. A book never lists itself. Copy everything else verbatim, including the title links; never rewrite, reorder, or "improve" the author's copy.

If the extracted text still contains a `TODO` comment for a listed book, warn the user that the entry has no description but proceed.

### 5. Confirm before building

Present this table and wait for a go-ahead (skip the wait only if the user already said to proceed):

| Setting | Value |
|---|---|
| Title | from `_Index.md` frontmatter, verbatim (plus subtitle if set) |
| Author | `<Author>` from `_Author.md` |
| Chapters | count and range found |
| Format | ebook / paperback / both, per wizard choice |
| Back matter | per wizard choice |
| Output | `<story>/_Publish/<name>.epub` and/or `<story>/_Publish/<name>-paperback.pdf` |
| Sideload copy | yes/no per wizard choice (ebook only) |

### 6. Build

Ebook (when the format includes it):

```bash
"<vault>/.claude/skills/story-kdp-export/scripts/build-epub.sh" --paragraphs \
  -t "<Title>" -a "<Author>" \
  --back "<tmp>/about-the-author.md" --back "<tmp>/books-by.md" \
  -o "<story>/_Publish/<name>.epub" "<story>/Chapters"
```

Paperback interior (when the format includes it), same flags plus the PDF output:

```bash
"<vault>/.claude/skills/story-kdp-export/scripts/build-print-pdf.sh" --paragraphs \
  -t "<Title>" -a "<Author>" \
  --back "<tmp>/about-the-author.md" --back "<tmp>/books-by.md" \
  -o "<story>/_Publish/<name>-paperback.pdf" "<story>/Chapters"
```

- Add `-s "<Subtitle>"` when the frontmatter has one; drop `--back` flags per the wizard choice. For the paperback, add `--isbn "<ISBN>"` only if the user asked for it on the copyright page.
- `--paragraphs` is required for vault chapters: their prose uses single-newline paragraph breaks, and without it every chapter collapses into one block.
- Never pass `--cover` on the KDP upload EPUB; KDP adds the separately uploaded cover, and an embedded one risks a double cover. The print script has no cover option at all: a paperback interior never contains the cover.
- If a sideload copy was requested, run the EPUB script a second time with the same arguments plus `--cover "<story>/<cover>"` and `-o "<story>/_Publish/<name>-sideload.epub"`.
- The print script sizes the mirrored inside margin automatically from the rendered page count per KDP's no-bleed gutter table and reports pages + gutter; it also generates the title page, copyright page, and Contents page with print page numbers.

### 7. Register the folder icon

If `_Publish/` did not exist before this run: per the vault CLAUDE.md icon convention, add `"<Story>/_Publish": "<icon>"` to `.obsidian/plugins/obsidian-icon-folder/data.json`, using the `_Publish` icon from `_Templates/folder-icons.json`.

### 8. Verify

**Ebook:** the script prints the section count and an XHTML well-formedness check. Confirm sections = chapter count + the number of back-matter pages included. If `xmllint` was skipped or any check failed, say so plainly; do not report success.

**Paperback:** the script prints the page count and chosen gutter. Relay its warnings: under 24 pages KDP rejects the book; under 79 pages the cover cannot carry spine text. Spot-check the PDF (render a page or two with `pdftoppm`): Contents page numbers must not all read the same, chapter openers must have a drop cap and no running head, and body pages must alternate author (verso) / title (recto) heads.

### 9. Report and hand off

Report the output path(s) and section/page count, then remind the author of the manual steps:

1. Open the EPUB in **Kindle Previewer** (or the online previewer during KDP upload) and check the title page, TOC, one chapter opening, and the back matter before publishing.
2. On the KDP ebook form, upload the EPUB as the manuscript and the cover image separately, as usual.
3. On the KDP paperback form, pick the matching print options (6 x 9, black-and-white on white, no bleed, matte), upload the paperback PDF as the manuscript, and check it in KDP's Print Previewer. The wrap-around cover is separate: build it with KDP's Cover Calculator template (needs the final page count) or Cover Creator from the ebook cover art.
4. If a sideload copy was built, remind the author to transfer it to their e-reader.

## Important

- Do not call pandoc directly as a shortcut. The scripts' preprocessing (frontmatter stripping, soft-break paragraph conversion, scene-break markup, comment stripping) is the reason this skill exists.
- Never modify chapter prose, in the vault or in the temp copies. The build must be byte-faithful to the chapters.
- The ebook styling contract lives in `assets/kindle-classic.css`, calibrated side-by-side in Kindle Previewer against a book built with Kindle Create's Classic theme (body font intentionally unset so Kindle uses Bookerly). The print styling contract lives in `assets/print-6x9.css`, its print companion (EB Garamond, same chapter-title/drop-cap/scene-break language). Change either only when the user asks for a styling change, and never inline styles into the build command.
- `build-print-pdf.sh` carries deliberate workarounds for WeasyPrint 68: the drop cap is a real `span.dropcap` injected into the HTML (a floated `::first-letter` crashes the layout engine), and running heads on chapter openers are suppressed by post-render `@page main:nth(N)` overrides (WeasyPrint has no page groups). Do not "simplify" these back to the standard CSS idioms.
