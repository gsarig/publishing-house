---
name: story-listen
description: "Converts one chapter into spoken audio via Microsoft Edge TTS (male voice by default, female via --voice), so the author can listen for flow problems. Writes _listens/<ch-XX>.mp3 in the story folder and prints its path. Never edits the chapter."
when_to_use: "Use when the author invokes /story-listen with a chapter reference (e.g. /story-listen ch-01). This is the human flow-check gate between copy-edit (stage 5) and proofread (stage 6). Do NOT use it to edit prose or as a review pass; it only produces an audio file for the author to listen to. Follow all steps in order."
argument-hint: "ch-XX"
model: haiku
disable-model-invocation: true
---

## Steps

1. Parse the argument for a chapter reference (e.g. "ch-01"). If none is given, ask which chapter and stop until answered.

2. From inside the story folder, run the co-located script, passing the reference and any `--voice` flag:

```
bash ../.claude/skills/story-listen/story-listen.sh <ref> [--voice <voice>]
```

Default voice is `en-US-GuyNeural` (male). The female option is `en-US-AriaNeural`.

edge-tts streams from `speech.platform.bing.com`, which the Bash sandbox blocks at DNS resolution (`Temporary failure in name resolution`). Expect the first attempt to fail, then rerun the identical command with the sandbox disabled.

Run this Bash call with a timeout of 600000 ms: generation runs roughly 10x real-time, so a full chapter takes a couple of minutes and the default 2-minute Bash timeout is too short.

3. The script prints the output MP3 path. Relay that one path to the author, and nothing else.
