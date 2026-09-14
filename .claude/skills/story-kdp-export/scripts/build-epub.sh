#!/usr/bin/env bash
# build-epub.sh - Build a KDP-ready reflowable EPUB from Markdown sources via pandoc.
#
# Usage: build-epub.sh [options] <source>...
#   <source>  .md files and/or directories (a dir contributes its top-level
#             *.md files, sorted). Sources are concatenated in order; every
#             H1 starts a new chapter (its own XHTML file + TOC entry).
#
# Options:
#   -o, --output FILE   Output EPUB. Default: <first-source>.epub beside it.
#   -t, --title TITLE   Book title (EPUB metadata + generated title page).
#   -a, --author NAME   Author (dc:creator + title page). Optional.
#   -s, --subtitle TEXT Subtitle (title page + EPUB metadata). Optional.
#   -l, --lang LANG     Language code. Default: en-US.
#   --back FILE         Back-matter .md appended after the chapters
#                       (repeatable; e.g. about-the-author.md, books-by.md).
#   --css FILE          Stylesheet. Default: kindle-classic.css in ../assets.
#   --cover FILE        Embed a cover image. LEAVE OFF for KDP uploads: KDP
#                       adds the separately uploaded cover, so embedding one
#                       risks a double cover. Use only for sideload copies.
#   --paragraphs        Treat every non-empty line as its own paragraph
#                       (Obsidian soft-break prose). Plain prose only.
#   --keep-frontmatter  Keep YAML frontmatter (default: strip it per file).
#   -h, --help          Show this help.
set -euo pipefail

err() { printf 'error: %s\n' "$1" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT=""; TITLE=""; AUTHOR=""; SUBTITLE=""; LANG_CODE="en-US"; CSS=""; COVER=""; PARAS=0; STRIP=1
backs=(); sources=()
while [ $# -gt 0 ]; do
  case "$1" in
    -o|--output) OUTPUT="$2"; shift 2;;
    -t|--title) TITLE="$2"; shift 2;;
    -a|--author) AUTHOR="$2"; shift 2;;
    -s|--subtitle) SUBTITLE="$2"; shift 2;;
    -l|--lang) LANG_CODE="$2"; shift 2;;
    --back) backs+=("$2"); shift 2;;
    --css) CSS="$2"; shift 2;;
    --cover) COVER="$2"; shift 2;;
    --paragraphs) PARAS=1; shift;;
    --keep-frontmatter) STRIP=0; shift;;
    -h|--help) sed -n '2,27p' "$0"; exit 0;;
    -*) err "unknown option: $1";;
    *) sources+=("$1"); shift;;
  esac
done
[ "${#sources[@]}" -gt 0 ] || err "no source given (see --help)"
[ -n "$COVER" ] && [ ! -f "$COVER" ] && err "cover not found: $COVER"
for b in "${backs[@]:-}"; do [ -z "$b" ] || [ -f "$b" ] || err "back-matter file not found: $b"; done
command -v pandoc >/dev/null || err "pandoc not installed"

[ -n "$CSS" ] || CSS="$SCRIPT_DIR/../assets/kindle-classic.css"
[ -f "$CSS" ] || err "stylesheet not found: $CSS"

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
  if [ -d "$first" ]; then OUTPUT="$(cd "$first" && pwd)/$(basename "$first").epub"
  else OUTPUT="$(cd "$(dirname "$first")" && pwd)/$(basename "${first%.md}").epub"; fi
fi
[ -n "$TITLE" ] || TITLE="$(basename "${OUTPUT%.epub}")"
mkdir -p "$(dirname "$OUTPUT")"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
: > "$tmp/body.md"

# Emit one file: strip frontmatter, optionally paragraph-ize soft-break prose,
# and turn *** / * * * scene-break lines into a styled centered paragraph.
# In --paragraphs mode a blank source line is a deliberate beat break; emit a
# spacer paragraph (an nbsp one, not an empty div, which Kindle's enhanced
# typesetting may drop), collapsing runs and skipping leading/trailing blanks.
# Blanks adjacent to headings or */*** scene-break lines are structural
# spacing, not beats, so no spacer there.
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
# Back-matter H1s get a .backmatter class (drop-cap exclusion in the CSS),
# so source notes stay plain markdown.
for b in "${backs[@]:-}"; do
  [ -z "$b" ] && continue
  emit "$b" | scenebreaks | sed -E 's/^# ([^{]+)$/# \1 {.backmatter}/' >> "$tmp/body.md"
  printf '\n\n' >> "$tmp/body.md"
done

args=( "$tmp/body.md" -t epub3 -o "$OUTPUT"
  --metadata title="$TITLE" --metadata lang="$LANG_CODE"
  --metadata toc-title="Contents"
  --toc --toc-depth=1 --split-level=1 --css "$CSS" )
[ -n "$AUTHOR" ] && args+=( --metadata author="$AUTHOR" )
[ -n "$SUBTITLE" ] && args+=( --metadata subtitle="$SUBTITLE" )
[ -n "$COVER" ] && args+=( --epub-cover-image="$COVER" )
pandoc "${args[@]}"

echo "Wrote: $OUTPUT"
# Report section count (chapter files in the spine) and check well-formedness.
unzip -o -q "$OUTPUT" -d "$tmp/check"
sections=$(ls "$tmp/check/EPUB/text/"ch*.xhtml 2>/dev/null | wc -l)
echo "Sections (chapters + back matter): $sections"
if command -v xmllint >/dev/null; then
  find "$tmp/check" -name '*.xhtml' -print0 | xargs -0 xmllint --noout && echo "XHTML check: all files well-formed"
else
  echo "XHTML check: skipped (xmllint not installed)"
fi
