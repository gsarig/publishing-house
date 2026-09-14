---
name: pdf-convert
description: "Renders one or more Markdown files into a styled serif PDF via pandoc + WeasyPrint."
when_to_use: "Use when the user asks to convert, export, or render Markdown to PDF (e.g. 'make a PDF of this note', 'export these chapters to PDF', 'build a manuscript PDF'). Follow all steps in order; do not shortcut based on this description."
argument-hint: "[source files/dir and/or options]"
allowed-tools: Bash
---

## Steps

### 1. Resolve the source
Determine what to convert: an explicit file/folder argument, the file in current context, or the relevant files in the working directory. If the source is ambiguous (nothing specified and several candidates exist), ask before proceeding. Do not guess.

### 2. Gather the settings as a wizard
Walk the user through the settings with `AskUserQuestion` prompts. In every prompt, put the **recommended default first** and label it "(Recommended)" so it can be accepted with one pick; offer "Other" only where free text makes sense (author, custom paths). Batch the questions (max 4 per `AskUserQuestion` call), so two calls cover everything:

**Call 1 (source & content):**
- **Source**: the detected folder/files vs Other (free path). Default: the resolved source from step 1.
- **Destination filename**: the folder stays the resolved output location (`<source>` dir, or for a story in this vault `<story>/_reviews/_full/beta/round-NN/_manuscript/`); offer three filename styles plus Other (full custom path):
  1. **Title as-is** (Recommended): `<Title>.pdf`, e.g. `The Lighthouse.pdf`.
  2. **Slug**: lowercased, spaces to dashes, punctuation stripped, e.g. `the-lighthouse.pdf`.
  3. **Slug + copy tag**: style 2 plus a version or round identifier, e.g. `the-lighthouse-v01.pdf` or `the-lighthouse-beta-round-01.pdf`. In a beta-round folder, derive the number from `round-NN`.
- **Paragraph handling**: *Obsidian prose* (`--paragraphs`: single newlines become paragraphs; recommended for vault prose) vs *Standard Markdown* (leave as-is; required if the source has lists, tables, or code).
- **Section separator** (only when concatenating more than one file): how to divide the joined files.
  1. **Chapter page breaks** (`--chapter-breaks`; recommended for story manuscripts and e-reader exports): each file's top-level heading starts on its own page and is centered. Assumes each chapter file opens with a single `# Title` heading.
  2. **Ornament** (`--ornament`): a centered "* * *" between files, continuous flow.
  3. **None**: files run together with no separator.

**Call 2 (styling):**
- **Author** (`-a`): the author's name from the vault-root `_Author.md` (recommended for their own fiction/prose), No author line, or Other. Never assume a name for prose that is not the author's own.
- **Font** (`--font`): EB Garamond (recommended), Bitstream Charter, Liberation Serif, or Other (must be installed; verify with `fc-list | grep -i <name>`).
- **Page size** (`--page`): A4 (recommended), Letter, or A5.
- **Alignment** (`--ragged`): Justified + hyphenation (recommended) vs Ragged-left. Alignment is a render choice not present in the source, so it must be chosen here.

If the user says to use defaults or to skip the wizard, accept all recommended defaults without asking. The title page is always a dedicated page with the title (and author line if set); it is not a wizard option.

### 3. Confirm before rendering
Show the resolved command plus the settings table, then wait for go-ahead. Rendering overwrites any existing PDF at the output path, so do not run it unannounced.

| Row | Content |
|---|---|
| Source | The folder (or files) read from, and how many files |
| Destination | Full output path; note if it overwrites an existing file |
| Author | The author line, or "none" |
| Font | Family and size |
| Page | Size and alignment |
| Title page | Title text (dedicated title page) |

Skip the wait only if the user already told you to proceed.

### 4. Run the script
```
"<vault>/.claude/skills/pdf-convert/scripts/md2pdf.sh" [options] <source>...
```
First run creates a persistent WeasyPrint venv at `~/.local/share/md2pdf/venv`. If it reports a missing system library, relay its `apt` command and stop; do not sudo-install without approval.

### 5. Report
Give the output path and page count from the script.

## Story manuscript preset
For a story in this vault, the beta-read manuscript PDF is:
```
md2pdf.sh --paragraphs --chapter-breaks [--cover "<story>/<cover>"] \
  -o "<story>/_reviews/_full/beta/round-NN/_manuscript/<Story Title>.pdf" \
  "<story>/Chapters"
```
The vault's chapter prose uses single-newline paragraph breaks, so `--paragraphs` is required there; without it every chapter collapses into one block. Each chapter file opens with a `# Title` heading, so `--chapter-breaks` puts every chapter on its own page with a centered title. Swap in `--ornament` instead for a continuous-flow manuscript with "* * *" between chapters.

**Cover (convention, no prompt):** read the `cover:` field from the story's `_Index.md` frontmatter. If set, it holds a story-root-relative image path (e.g. `_Assets/cover-minimal-2.png`); pass it as `--cover "<story>/<cover>"` so the image becomes page 1. If there is no `cover:` field, render without a cover. Never ask about the cover for a story; the field's presence is the switch.

## Important
Do not call pandoc directly as a shortcut. The script's frontmatter stripping and line-to-paragraph conversion are what keep Obsidian prose from collapsing into one block, and going through it avoids the ad-hoc shell errors that motivated this skill.
