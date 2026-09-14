#!/usr/bin/env bash
# md2pdf.sh - Render one or more Markdown files into a styled PDF via pandoc + WeasyPrint.
#
# Usage: md2pdf.sh [options] <source>...
#   <source>  .md files and/or directories (a dir contributes its top-level
#             *.md files, sorted). Multiple sources are concatenated in order.
#
# Options:
#   -o, --output FILE   Output PDF. Default: <first-source>.pdf beside the source
#                       (or <dirname>.pdf when the source is a directory).
#   -t, --title TITLE   Title page + PDF metadata. Default: basename of source.
#   -a, --author NAME   Author line on the title page, under the title. Optional.
#       --font NAME     Body font family. Default: "EB Garamond".
#       --page SIZE     Page size: A4 (default), Letter, or A5.
#       --css FILE      Custom CSS (overrides --font/--ragged). Default: built-in.
#       --paragraphs    Treat every non-empty line as its own paragraph
#                       (Obsidian soft-break prose). WARNING: plain prose only,
#                       it will break Markdown lists, tables, and code blocks.
#       --ornament      Insert a centered "* * *" between concatenated sources.
#       --chapter-breaks  Start each top-level heading on its own page and centre
#                       it (one chapter per file). Overrides --ornament.
#       --cover FILE    Full-page cover image as page 1 (fitted to page height,
#                       centred). Hides the text title page; title/author still
#                       set as PDF metadata. Built-in CSS only (not with --css).
#       --ragged        Left-align text with no hyphenation (default: justified).
#       --keep-frontmatter   Keep YAML frontmatter (default: strip it).
#   -h, --help          Show this help.
set -euo pipefail

err() { printf 'error: %s\n' "$1" >&2; exit 1; }

OUTPUT=""; TITLE=""; AUTHOR=""; CSS=""; COVER=""; FONT="EB Garamond"; PAGE="A4"; PARAS=0; ORNAMENT=0; CHAPTERS=0; RAGGED=0; STRIP=1
sources=()
while [ $# -gt 0 ]; do
  case "$1" in
    -o|--output) OUTPUT="$2"; shift 2;;
    -t|--title) TITLE="$2"; shift 2;;
    -a|--author) AUTHOR="$2"; shift 2;;
    --font) FONT="$2"; shift 2;;
    --page) PAGE="$2"; shift 2;;
    --css) CSS="$2"; shift 2;;
    --paragraphs) PARAS=1; shift;;
    --ornament) ORNAMENT=1; shift;;
    --chapter-breaks) CHAPTERS=1; shift;;
    --cover) COVER="$2"; shift 2;;
    --ragged) RAGGED=1; shift;;
    --keep-frontmatter) STRIP=0; shift;;
    -h|--help) sed -n '2,27p' "$0"; exit 0;;
    -*) err "unknown option: $1";;
    *) sources+=("$1"); shift;;
  esac
done
[ "${#sources[@]}" -gt 0 ] || err "no source given (see --help)"
case "$PAGE" in A4|Letter|A5) ;; *) err "invalid --page: $PAGE (use A4, Letter, or A5)";; esac
[ "$CHAPTERS" -eq 1 ] && ORNAMENT=0  # chapter page breaks replace the inter-file ornament
[ -n "$COVER" ] && [ ! -f "$COVER" ] && err "cover not found: $COVER"

# Expand sources into an ordered file list
files=()
for s in "${sources[@]}"; do
  if [ -d "$s" ]; then
    while IFS= read -r f; do files+=("$f"); done < <(ls -1 "$s"/*.md 2>/dev/null | sort)
  elif [ -f "$s" ]; then files+=("$s")
  else err "not found: $s"; fi
done
[ "${#files[@]}" -gt 0 ] || err "no .md files resolved from sources"

# Defaults for output + title
first="${sources[0]}"
if [ -z "$OUTPUT" ]; then
  if [ -d "$first" ]; then OUTPUT="$(cd "$first" && pwd)/$(basename "$first").pdf"
  else OUTPUT="$(cd "$(dirname "$first")" && pwd)/$(basename "${first%.md}").pdf"; fi
fi
[ -n "$TITLE" ] || TITLE="$(basename "${OUTPUT%.pdf}")"
mkdir -p "$(dirname "$OUTPUT")"

command -v pandoc >/dev/null || err "pandoc not installed"

# Persistent WeasyPrint venv
VENV="$HOME/.local/share/md2pdf/venv"
if [ ! -x "$VENV/bin/weasyprint" ]; then
  # ldconfig exists only on Linux; elsewhere (macOS), WeasyPrint reports missing libraries itself when it loads.
  if command -v ldconfig >/dev/null; then
    ldconfig -p 2>/dev/null | grep -q "libpango-1.0" \
      || err "missing system libs; install: sudo apt install libpango-1.0-0 libpangocairo-1.0-0 libcairo2 libgdk-pixbuf-2.0-0"
  fi
  echo "Setting up WeasyPrint venv at $VENV ..." >&2
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --quiet --upgrade pip weasyprint
fi

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
: > "$tmp/body.md"

# In --paragraphs mode a blank source line is a deliberate beat break (Obsidian
# prose); emit a spacer div so it survives, collapsing runs and skipping
# leading/trailing blanks. Blanks adjacent to headings or */*** scene-break
# lines are structural spacing, not beats, so no spacer there.
PARA_AWK='{
  if($0 ~ /[^[:space:]]/){
    sp = ($0 ~ /^#/ || $0 ~ /^[[:space:]]*\*([[:space:]]*\*){2}[[:space:]]*$/)
    if(blank && started && !psp && !sp){print "<div class=\"gap\"></div>"; print ""}
    blank=0; started=1; psp=sp
    print; print ""
  } else blank=1
}'

emit() { # $1 = file
  if [ "$STRIP" -eq 1 ] && [ "$PARAS" -eq 1 ]; then
    awk "BEGIN{fm=0; blank=0; started=0} NR==1&&/^---\$/{fm=1;next} fm==1&&/^---\$/{fm=0;next}
         fm==0$PARA_AWK" "$1"
  elif [ "$STRIP" -eq 1 ]; then
    awk 'BEGIN{fm=0} NR==1&&/^---$/{fm=1;next} fm==1&&/^---$/{fm=0;next} fm==0{print}' "$1"
  elif [ "$PARAS" -eq 1 ]; then
    awk "BEGIN{blank=0; started=0} $PARA_AWK" "$1"
  else cat "$1"; fi
}

# Cover image as the first page (copied into tmp so a path with spaces is safe)
if [ -n "$COVER" ]; then
  cext="${COVER##*.}"
  cp "$COVER" "$tmp/cover.$cext"
  printf '<div class="cover-page"><img src="file://%s/cover.%s" alt=""></div>\n\n' "$tmp" "$cext" >> "$tmp/body.md"
fi

n=0; total="${#files[@]}"
for f in "${files[@]}"; do
  n=$((n+1))
  emit "$f" >> "$tmp/body.md"
  printf '\n' >> "$tmp/body.md"
  if [ "$ORNAMENT" -eq 1 ] && [ "$n" -lt "$total" ]; then printf '\n***\n\n' >> "$tmp/body.md"; fi
done

if [ -n "$CSS" ]; then STYLE="$CSS"; else
  STYLE="$tmp/style.css"
  ALIGN="justify"; HYPH="auto"
  [ "$RAGGED" -eq 1 ] && { ALIGN="left"; HYPH="none"; }
  cat > "$STYLE" <<CSS
@page { size: $PAGE; margin: 2.5cm 2.8cm;
  @bottom-center { content: counter(page); font-family: "$FONT", serif; font-size: 9pt; color: #555; } }
body { font-family: "$FONT", "Liberation Serif", serif; font-size: 13pt; line-height: 1.5; text-align: $ALIGN; hyphens: $HYPH; color: #1a1a1a; }
#title-block-header { text-align: center; margin-top: 30%; page-break-after: always; display: flex; flex-direction: column; }
h1.title { font-size: 24pt; margin: 0; }
p.author { order: -1; font-size: 14pt; font-style: italic; color: #444; margin: 0 0 0.5em 0; }
p { margin: 0; text-indent: 1.4em; }
p:first-of-type, hr + p { text-indent: 0; }
hr { border: 0; margin: 1.6em 0; text-align: center; }
hr::after { content: "* * *"; letter-spacing: 0.4em; color: #555; font-size: 13pt; }
div.gap { height: 1.5em; }
div.gap + p { text-indent: 0; }
CSS
  if [ "$CHAPTERS" -eq 1 ]; then
    cat >> "$STYLE" <<'CSS'
h1:not(.title) { page-break-before: always; text-align: center; font-weight: normal; font-size: 18pt; margin: 0 0 2em 0; }
h1:not(.title) + p { text-indent: 0; }
CSS
  fi
  if [ -n "$COVER" ]; then
    cat >> "$STYLE" <<'CSS'
@page cover { margin: 0; }
div.cover-page { page: cover; page-break-after: always; }
div.cover-page img { display: block; height: 100vh; width: auto; max-width: 100%; margin: 0 auto; }
#title-block-header { display: none; }
CSS
  fi
fi

author_args=()
[ -n "$AUTHOR" ] && author_args=(--metadata author="$AUTHOR")
PATH="$VENV/bin:$PATH" pandoc "$tmp/body.md" \
  --metadata title="$TITLE" "${author_args[@]}" --pdf-engine=weasyprint --css="$STYLE" -o "$OUTPUT"

echo "Wrote: $OUTPUT"
command -v pdfinfo >/dev/null && pdfinfo "$OUTPUT" | grep Pages || true
