---
name: story-cover-check
description: "Simulates how a book cover renders on a grayscale e-ink reader, measures whether every text element clears the readability thresholds, and produces recolor variants when one fails."
when_to_use: "Use when the user wants a cover checked for e-reader/e-ink readability before uploading to KDP (e.g. '/story-cover-check', 'check the cover before upload', 'is the cover readable on kindle/e-ink', 'simulate the cover in grayscale'), or reports that cover text is unreadable on their e-reader. Do NOT use for the book's interior files (use /story-kdp-export) or for print/CMYK color judgement (see the vault-root `_KDP cover pre-flight.md` note). Follow all steps in order; do not shortcut based on this description."
argument-hint: "[path to cover image]"
allowed-tools: Bash(eink-sim *) Bash(ffmpeg *) Bash(convert *) Bash(montage *) Read
---

## Steps

### 1. Locate the cover

Use the argument if given; otherwise look for `_Publish/cover.jpg` in the current story folder. If neither resolves, ask which file to check.

### 2. Run the baseline simulation

```bash
eink-sim <cover> <story>/_Publish/eink-previews/original-eink.png
```

(`eink-sim` is `scripts/eink-sim.sh` inside this skill's folder; run it via that path, `"<vault>/.claude/skills/story-cover-check/scripts/eink-sim.sh"`, or symlink it into `~/.local/bin` once to use the bare command.) It scales to 400px tall, converts to BT.601 grayscale, compresses into e-ink's reflective range (~30-220), and quantizes to 16 gray levels. All previews for this run go in `_Publish/eink-previews/`.

### 3. Measure the gray gaps — never eyeball

Sample the cover's dominant source colors:

```bash
ffmpeg -v error -i <cover> -vf format=rgb24 -frames:v 1 -f rawvideo -pix_fmt rgb24 - \
  | xxd -p -c 3 | sort | uniq -c | sort -rn | head -8
```

Then measure each text element in the *simulated* output: crop a region containing the element and histogram its gray values:

```bash
ffmpeg -v error -i original-eink.png -vf "format=gray,crop=W:H:X:Y" -frames:v 1 -f rawvideo - \
  | xxd -p -c 60 | tr -d '\n' | fold -w2 | sort | uniq -c | sort -rn | head -4
```

The gap is |text gray − background gray|. Verdict: **≤ 35** (two quantize steps) unreadable, **35–90** borderline, **≥ 90** readable.

### 4. If an element fails, generate fixes

Two levers, in order of effect:

**Recolor the text.** Gray value ≈ 0.299R + 0.587G + 0.114B, so pure red caps at ~83/255; "a brighter red" cannot fix it. Add green: shift red toward coral/orange (#FF4433 → gap ~68, #FF6B4A → ~85, #FF8C66 → ~102 on a #252525 background). Recolor without flattening antialiasing via a redness mask (adapt the r−g mask for other hues):

```bash
A='clip((r(X,Y)-g(X,Y))*2,0,255)/255'; V='(r(X,Y)/255)'
ffmpeg -v error -y -i <cover> -vf "format=rgb24,scale=-2:1000,geq=r='r(X,Y)*(1-${A})+TR*${A}*${V}':g='g(X,Y)*(1-${A})+TG*${A}*${V}':b='b(X,Y)*(1-${A})+TB*${A}*${V}'" -frames:v 1 variant-color.png
```

**Darken the background.** `convert <cover> -gamma 0.625 darkbg-color.png` approximates it (darkens shadows, keeps white and saturated text). Alone it raises a red-on-#252525 gap only to ~51 (ceiling ~68 even on pure black), so treat it as a way to keep a redder red: a modest lift like #FF4433 on a ~#0D0D0D background clears ~85.

Name every variant file by its measured background and font hex (lowercase, no `#`): `bg-<bghex>_font-<fonthex>-color.png` and `-eink.png`; prefix the baseline `original_`. Measure the hexes from the variant file itself (step 3 sampler), never assume them, e.g. a gamma-darkened background must be re-sampled for its actual value.

Run every candidate through `eink-sim`, re-measure (step 3), and build a labeled side-by-side montage: current cover always first, one panel per variant, each label carrying a number, both hex codes, the measured gap, and a verdict word:

```bash
montage -font DejaVu-Sans-Bold -pointsize 16 -background white -fill black \
  -label "1. CURRENT COVER\nbg 252525 / font FF090E\ngap 34 - UNREADABLE" original_bg-252525_font-ff090e-eink.png \
  -label "2. bg 252525 / font FF4433\ngap 68\nborderline" bg-252525_font-ff4433-eink.png \
  -tile <N>x1 -geometry +6+6 montage-eink.png
```

### 5. Present, recommend, stop

Show the montage and per-variant measured gaps, view the color versions too (the fix must still look right in color), and recommend one. The author applies the change in their design tool and re-exports; never edit the cover source file. Remind them: any color change also shifts CMYK, so re-check the print cover via a soft proof before re-exporting the paperback (see the vault-root `_KDP cover pre-flight.md` note).

## Important

Judge readability only from measured gray values, never from how a preview renders in chat: the chat image pipeline brightens dark images, and a cover that looks legible inline can sit two quantize steps from its background on the device.
