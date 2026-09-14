---
tags:
  - reference
---

# KDP Paperback Cover Pre-flight

Hard-won settings from a published 6x9 paperback. Follow closely; deviations produced KDP rejections or visible print artifacts. The interior PDF comes from `/story-kdp-export`; the wrap-around cover is designed by the author in a design tool, and this checklist governs its export and pre-flight. Most of it applies to any tool; the export preset section is Affinity-specific (Affinity is a free, cross-platform design suite, and the settings translate to other tools that can export PDF/X-1a).

## Canvas size (any tool)

For a 6x9 trim: width = 0.125" + 6" + spine + 6" + 0.125", height = 9.25". Spine = interior page count x 0.002252" (B&W, white paper) or x 0.0025" (cream). Recompute whenever the interior page count changes; `/story-kdp-export` reports the final page count.

## Export settings (Affinity)

- Use the **PDF (press ready)** preset, i.e. PDF/X-1a:2003, with **Rasterize: Everything**, Raster DPI **600**, Downsample images **off**, Area: Whole document.
- **Why Rasterize Everything:** with partial rasterization, PDF/X-1a flattening converts the rasterized patches and the vector background through slightly different sRGB-to-CMYK paths, leaving visible grey boxes around every transparent element on dark covers. One flat image means one uniform conversion. 600 DPI keeps rasterized text crisp; at 300 it prints soft.

## Color reality check (any tool)

The design canvas (sRGB, backlit) always looks richer than print. Judge colours only via a soft proof (profile: U.S. Web Coated SWOP v2) while designing, and via the KDP Print Previewer after upload; hide or delete any soft-proof adjustment layer before exporting. Dark grey backgrounds convert to thin ink and print washed: darken the source (e.g. a #252525 background needed to drop toward #151515) until the proof view looks right. Saturated reds dull slightly in CMYK; that shift is physics, not a file error.

## Pre-flight checks (any tool)

- `pdfinfo` must show the formula size from the canvas section and subtype PDF/X-1a.
- Judge visuals in the **KDP Print Previewer**, not a local render (the previewer exposed patch seams a local render hid).
- Spine text only if the interior is 79+ pages.
- KDP places its barcode bottom-right of the back cover; keep that zone clear.
- For e-ink readability of the cover text (the store thumbnail on e-readers), run `/story-cover-check` before uploading.

## At upload

Prefer the glossy cover finish for dark covers (matte lifts them toward washed), and order a printed proof copy before publishing; ink density and banding on large dark areas can only be judged on paper.
