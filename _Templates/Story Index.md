---
title:
genre:
form:
status: active
started:
target_wordcount:
# cover: _Assets/cover.png (set once a cover is chosen; used by /pdf-convert manuscripts and /story-kdp-export sideload copies)
# subtitle: (optional; passed to /story-kdp-export and shown as "Title: Subtitle" on the store listing)
tags:
  - story-index
cssclasses:
  - story-index
---

# {{title}}

## Stats

```dataviewjs
const WPP = 280, WPM = 200;
const dir = dv.current().file.folder + "/Chapters";
const chapters = dv.pages(`"${dir}"`)
  .where(p => p.file.name.startsWith("ch-"))
  .sort(p => p.file.name, "asc");

let rows = [], total = 0;
for (const p of chapters) {
  const raw = await dv.io.load(p.file.path);
  const body = raw.replace(/^---\r?\n[\s\S]*?\r?\n---\r?\n?/, "");
  const words = body.trim().split(/\s+/).filter(Boolean).length;
  total += words;
  rows.push([p.file.link, p.status ?? "", p.edit_pass ?? "", words.toLocaleString(), Math.ceil(words / WPP)]);
}

const classify = w =>
  w < 1000 ? "Flash fiction" :
  w < 7500 ? "Short story" :
  w < 17500 ? "Novelette" :
  w < 40000 ? "Novella" : "Novel";

dv.table(["Chapter", "Status", "Pass", "Words", "~Pages"], rows);
dv.paragraph(`**Total:** ${total.toLocaleString()} words · ~${Math.ceil(total / WPP)} pages (${WPP} w/page) · ~${Math.ceil(total / WPM)} min read (${WPM} wpm) · class: **${classify(total)}** ([[_Story-length classes|brackets]])`);
```

## Premise


## Lore & World Rules


## Themes


## Structure Notes


## Open Questions

