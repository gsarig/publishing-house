#!/usr/bin/env bash
# build-print-pdf.sh - Build a KDP-ready 6x9 paperback interior PDF from
# Markdown sources via pandoc + WeasyPrint (B&W, no bleed).
#
# Usage: build-print-pdf.sh [options] <source>...
#   <source>  .md files and/or directories (a dir contributes its top-level
#             *.md files, sorted). Sources are concatenated in order; every
#             H1 starts a new chapter on a fresh page.
#
# Options:
#   -o, --output FILE   Output PDF. Default: <first-source>-paperback.pdf.
#   -t, --title TITLE   Book title (title page, running heads, metadata).
#   -a, --author NAME   Author (title page, running heads, copyright page).
#   -s, --subtitle TEXT Subtitle (title page). Optional.
#   -l, --lang LANG     Language code (hyphenation dict). Default: en-US.
#   --back FILE         Back-matter .md appended after the chapters
#                       (repeatable; e.g. about-the-author.md, books-by.md).
#   --isbn NUM          Print this ISBN on the copyright page. Optional.
#   --year YYYY         Copyright year. Default: current year.
#   --css FILE          Stylesheet. Default: print-6x9.css in ../assets.
#   --paragraphs        Treat every non-empty line as its own paragraph
#                       (Obsidian soft-break prose). Plain prose only.
#   --keep-frontmatter  Keep YAML frontmatter (default: strip it per file).
#   -h, --help          Show this help.
#
# The inside (gutter) margin is sized automatically from the rendered page
# count per KDP's no-bleed gutter table, re-rendering until stable.
set -euo pipefail

err() { printf 'error: %s\n' "$1" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT=""; TITLE=""; AUTHOR=""; SUBTITLE=""; LANG_CODE="en-US"; CSS=""; ISBN=""; YEAR=""; PARAS=0; STRIP=1
backs=(); sources=()
while [ $# -gt 0 ]; do
  case "$1" in
    -o|--output) OUTPUT="$2"; shift 2;;
    -t|--title) TITLE="$2"; shift 2;;
    -a|--author) AUTHOR="$2"; shift 2;;
    -s|--subtitle) SUBTITLE="$2"; shift 2;;
    -l|--lang) LANG_CODE="$2"; shift 2;;
    --back) backs+=("$2"); shift 2;;
    --isbn) ISBN="$2"; shift 2;;
    --year) YEAR="$2"; shift 2;;
    --css) CSS="$2"; shift 2;;
    --paragraphs) PARAS=1; shift;;
    --keep-frontmatter) STRIP=0; shift;;
    -h|--help) sed -n '2,30p' "$0"; exit 0;;
    -*) err "unknown option: $1";;
    *) sources+=("$1"); shift;;
  esac
done
[ "${#sources[@]}" -gt 0 ] || err "no source given (see --help)"
[ -n "$TITLE" ] || err "--title is required (title page and running heads)"
[ -n "$AUTHOR" ] || err "--author is required (title page and running heads)"
for b in "${backs[@]:-}"; do [ -z "$b" ] || [ -f "$b" ] || err "back-matter file not found: $b"; done
command -v pandoc >/dev/null || err "pandoc not installed"
[ -n "$YEAR" ] || YEAR="$(date +%Y)"

[ -n "$CSS" ] || CSS="$SCRIPT_DIR/../assets/print-6x9.css"
[ -f "$CSS" ] || err "stylesheet not found: $CSS"

# Persistent WeasyPrint venv, shared with the pdf-convert skill's md2pdf.sh
# and created automatically on first run.
VENV="$HOME/.local/share/md2pdf/venv"
if [ ! -x "$VENV/bin/python" ]; then
  command -v python3 >/dev/null || err "python3 not installed (needed for WeasyPrint)"
  # ldconfig exists only on Linux; elsewhere (macOS), WeasyPrint reports missing libraries itself when it loads.
  if command -v ldconfig >/dev/null; then
    ldconfig -p 2>/dev/null | grep -q "libpango-1.0" \
      || err "missing system libs; install: sudo apt install libpango-1.0-0 libpangocairo-1.0-0 libcairo2 libgdk-pixbuf-2.0-0"
  fi
  echo "Setting up WeasyPrint venv at $VENV ..." >&2
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet --upgrade pip weasyprint
fi

# Expand sources into an ordered file list
files=()
for s in "${sources[@]}"; do
  if [ -d "$s" ]; then
    while IFS= read -r f; do files+=("$f"); done < <(ls -1 "$s"/*.md 2>/dev/null | sort)
  elif [ -f "$s" ]; then files+=("$s")
  else err "not found: $s"; fi
done
[ "${#files[@]}" -gt 0 ] || err "no .md files resolved from sources"

first="${sources[0]}"
if [ -z "$OUTPUT" ]; then
  if [ -d "$first" ]; then OUTPUT="$(cd "$first" && pwd)/$(basename "$first")-paperback.pdf"
  else OUTPUT="$(cd "$(dirname "$first")" && pwd)/$(basename "${first%.md}")-paperback.pdf"; fi
fi
mkdir -p "$(dirname "$OUTPUT")"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
: > "$tmp/body.md"

# Same source preprocessing as build-epub.sh, so print and ebook render the
# identical text: strip frontmatter, optionally paragraph-ize soft-break
# prose, style *** scene breaks, keep blank-line beat breaks as nbsp
# spacer paragraphs.
PARA_AWK='{
  if($0 ~ /[^[:space:]]/){
    sp = ($0 ~ /^#/ || $0 ~ /^[[:space:]]*\*([[:space:]]*\*){2}[[:space:]]*$/)
    if(blank && started && !psp && !sp){print "<p class=\"gap\">&#160;</p>"; print ""}
    blank=0; started=1; psp=sp
    print; print ""
  } else blank=1
}'

emit() { # $1 = file
  if [ "$STRIP" -eq 1 ] && [ "$PARAS" -eq 1 ]; then
    awk "BEGIN{fm=0; blank=0; started=0; psp=0} NR==1&&/^---\$/{fm=1;next} fm==1&&/^---\$/{fm=0;next}
         fm==0$PARA_AWK" "$1"
  elif [ "$STRIP" -eq 1 ]; then
    awk 'BEGIN{fm=0} NR==1&&/^---$/{fm=1;next} fm==1&&/^---$/{fm=0;next} fm==0{print}' "$1"
  elif [ "$PARAS" -eq 1 ]; then
    awk "BEGIN{blank=0; started=0; psp=0} $PARA_AWK" "$1"
  else cat "$1"; fi
}
# Scene break: emit the styled paragraph blank-line-separated (so pandoc treats
# it as a raw HTML block) with entity-encoded asterisks (so pandoc does not
# reparse "* * *" as a bullet list inside the block). Both are required.
scenebreaks() { sed -E -e '/^[[:space:]]*<!--.*-->[[:space:]]*$/d' -e 's|^[[:space:]]*(\*[[:space:]]?){3}[[:space:]]*$|\n<p class="scene-break">\&#42; \&#42; \&#42;</p>\n|'; }

for f in "${files[@]}"; do
  emit "$f" | scenebreaks >> "$tmp/body.md"
  printf '\n\n' >> "$tmp/body.md"
done
# Back-matter H1s get a .backmatter class (block paragraphs, no drop cap).
for b in "${backs[@]:-}"; do
  [ -z "$b" ] && continue
  emit "$b" | scenebreaks | sed -E 's/^# ([^{]+)$/# \1 {.backmatter}/' >> "$tmp/body.md"
  printf '\n\n' >> "$tmp/body.md"
done

args=( "$tmp/body.md" -t html5 -s --section-divs -o "$tmp/doc.html"
  --metadata title="$TITLE" --metadata author="$AUTHOR" --metadata lang="$LANG_CODE"
  --metadata toc-title="Contents" --toc --toc-depth=1 )
[ -n "$SUBTITLE" ] && args+=( --metadata subtitle="$SUBTITLE" )
pandoc "${args[@]}" 2> >(grep -v 'Custom styles' >&2 || true)

# Render: inject the copyright page, then size the gutter to the page count
# per KDP's no-bleed table and re-render until stable.
"$VENV/bin/python" - "$tmp/doc.html" "$CSS" "$OUTPUT" "$TITLE" "$AUTHOR" "$YEAR" "$ISBN" <<'PY'
import html as H
import re
import sys

doc_path, css_path, out_path, title, author, year, isbn = sys.argv[1:8]

from weasyprint import CSS, HTML  # noqa: E402 (venv import after argv parse)

lines = [
    f"{H.escape(title)}",
    f"Copyright © {H.escape(year)} {H.escape(author)}",
    "All rights reserved.",
    ("This is a work of fiction. Names, characters, places, and incidents are either "
     "products of the author’s imagination or used fictitiously. Any resemblance to "
     "actual persons, living or dead, or actual events is purely coincidental."),
    ("No part of this book may be reproduced in any form without written permission "
     "from the author, except for brief quotations in a book review."),
]
if isbn:
    lines.append(f"ISBN: {H.escape(isbn)}")
lines.append("Independently published.")
block = '<div class="copyright-page">\n' + "\n".join(f"<p>{ln}</p>" for ln in lines) + "\n</div>"

src = open(doc_path, encoding="utf-8").read()

# Pandoc's standalone template embeds its own default CSS (1em paragraph
# margins, max-width body, heading styles), which would fight print-6x9.css:
# body paragraphs must be flush, book-style. All styling comes from the
# stylesheet files, so drop every embedded style block.
src = re.sub(r"<style>.*?</style>", "", src, flags=re.S)

# A printed page cannot follow a link, and KDP flags PDF link annotations
# as "non-printable markup". Convert every anchor to a span: TOC entries
# keep their target in data-dest so target-counter() can still resolve the
# Contents page numbers; external links keep only their visible text.
src = re.sub(r'<a\s+href="(#[^"]*)"[^>]*>', r'<span data-dest="\1">', src)
src = re.sub(r"<a\s[^>]*>", "<span>", src)
src = src.replace("</a>", "</span>")

src, n = re.subn(r"</header>", "</header>\n" + block, src, count=1)
if n != 1:
    sys.exit("error: pandoc title-block header not found; copyright page not inserted")

# Drop cap: wrap each chapter's opening letter (plus a leading quote, as
# ::first-letter would include) in span.dropcap. Done here because a floated
# ::first-letter crashes WeasyPrint 68. Back matter and openers that start
# with anything but a letter are left alone.
def dropcap(m):
    if "backmatter" in m.group(1):
        return m.group(0)
    return f'{m.group(1)}<span class="dropcap">{m.group(2)}</span>'

src = re.sub(
    r'(<section[^>]*class="[^"]*\blevel1\b[^"]*"[^>]*>\s*<h1[^>]*>.*?</h1>\s*<p>)([“‘"\']?[A-Za-z])',
    dropcap, src, flags=re.S)

# Section ids double as anchors in the rendered document; their pages are
# the chapter openers, where the running head must be suppressed.
section_ids = re.findall(r'<section id="([^"]+)"[^>]*class="[^"]*\blevel1\b', src)

# KDP no-bleed gutter minimums by page count; inside margin = gutter + 0.375in
# of breathing room (0.75in inside / 0.5in outside for a typical short book).
def min_gutter(pages):
    for limit, g in ((150, 0.375), (300, 0.5), (500, 0.625), (700, 0.75)):
        if pages <= limit:
            return g
    return 0.875

base = CSS(filename=css_path)
doc = HTML(string=src, base_url=doc_path)
gutter = 0.375
while True:
    inside = gutter + 0.375
    mirror = CSS(string=(
        f"@page:right {{ margin-left: {inside}in; }}"
        f"@page:left {{ margin-right: {inside}in; }}"
    ))
    rendered = doc.render(stylesheets=[base, mirror])
    pages = len(rendered.pages)
    need = min_gutter(pages)
    if need <= gutter:
        break
    gutter = need

# WeasyPrint has no page groups, so @page main:first cannot catch chapter
# openers. Instead, find the physical page of every section anchor and
# re-render with the running head blanked on exactly those pages. Margin
# boxes do not affect layout, so the pagination cannot shift.
openers = set()
for sid in section_ids:
    # a section's anchor is listed on every page it spans; the opener is
    # the first one
    for i, page in enumerate(rendered.pages):
        if sid in page.anchors:
            openers.add(i + 1)
            break
openers = sorted(openers)
if openers:
    # The page name must be part of the selector: a named selector like
    # main:left otherwise outranks a bare :nth() in the page cascade.
    suppress = CSS(string="".join(
        f"@page main:nth({n}) {{ @top-center {{ content: none; }} }}" for n in openers
    ))
    rendered = doc.render(stylesheets=[base, mirror, suppress])
    if len(rendered.pages) != pages:
        sys.exit("error: page count changed while suppressing running heads")
rendered.write_pdf(out_path)

print(f"Pages: {pages} | trim 6x9in, no bleed | gutter {gutter}in (inside margin {inside}in)")
if pages < 24:
    print("WARNING: below KDP's 24-page minimum for paperbacks")
if pages < 79:
    print("Note: under 79 pages, so the KDP cover cannot carry spine text")
PY

echo "Wrote: $OUTPUT"
