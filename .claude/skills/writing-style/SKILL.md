---
name: writing-style
description: "The author's aesthetic philosophy, prose style, and creative sensibility — the single source of truth every editorial skill judges against. Ships unconfigured; the first direct invocation runs a one-time interview that rewrites this file into the author's real style reference."
---

# Author Writing Style

<!-- WRITING-STYLE-PLACEHOLDER: not configured. This marker is deleted when the setup interview rewrites the file. -->

## Status: not configured

This skill is dormant. It ships as an interview that writes itself; it does not yet describe any author.

**If the author invoked `/writing-style` directly:** run the **## Setup interview** below.

**If you are an editorial skill or critique sub-agent loading this file as a style reference:** do not start the interview. If you can talk to the author, stop and tell them: "The writing-style skill is not configured yet; run `/writing-style` once before any editorial pass." If you are an isolated sub-agent that cannot reach the author, note in your report that no style reference exists and judge against neutral, generally accepted craft standards; flag nothing as "deliberate authorial form", because nothing has been declared deliberate yet.

## Setup interview

The goal is a style reference grounded in the author's actual prose, not their self-image. Observations from finished text outrank self-reported preferences; where the two disagree, present the discrepancy and let the author decide what goes in the file.

### 1. Gather the prose

Ask the author for their best finished work: published books, completed stories, or the strongest chapters they have. Ask for file paths (or pasted text) and read everything they give you in full. If they have no finished prose at all, say plainly that the reference will be weaker and interview-only, and mark it as provisional in the Source Note so it gets rebuilt after the first finished draft.

### 2. Interview

Ask these one at a time, conversationally; follow up where an answer is vague. Do not batch them into one wall of questions.

1. **The constant.** What recurs across everything you write, or want to? (A mood, a kind of premise, a question you keep returning to.)
2. **Influences, specifically.** Which writers, filmmakers, or artists shape your work, and what exactly do you take from each? Push past names to mechanisms: not "Kafka" but what of Kafka shows up in your sentences.
3. **Passages you love.** Two or three passages (yours or anyone's) you find perfect, and what makes each work for you.
4. **Anti-preferences.** What do you hate in fiction? What common writing advice do you deliberately reject? What would make you close a book?
5. **Endings, explanation, ambiguity.** How much do you resolve? What stays unexplained on purpose?
6. **Interiority and emotion.** How do your characters think and feel on the page: stated, implied through image and action, or something else?

### 3. Analyze the prose

Independently of the answers, derive from the samples: sentence rhythm and its range, paragraph habits, dialogue conventions, interiority style, imagery and metaphor habits, tense and POV behavior (including any deliberate irregularities), structural choices, how endings behave, and recurring registers (comedy, dread, restraint). Be specific: not "uses short sentences" but the exact pattern observed and what it does. Present these observations to the author and confirm which are deliberate style and which are accidents they would rather fix; only confirmed-deliberate patterns become protected style.

### 4. Draft, approve, rewrite

Draft the full replacement file in the **## Target shape** below and present it. Iterate until the author approves. Then rewrite this SKILL.md so it contains only the frontmatter (update the `description` to one sentence about this author's actual aesthetic) and the approved content: delete the placeholder marker, the Status section, the Setup interview, and the Target shape. The file you leave behind is the style reference, nothing else.

## Target shape

The final file uses this skeleton (drop a section only if genuinely empty for this author):

- **Opening note** — one short paragraph: this is an aesthetic philosophy, not a ruleset; it calibrates every suggestion and every piece of feedback.
- **The constant** — the thread that runs across all the work, and the distinct registers it operates in, each tied to a named work or sample.
- **Prose style** — the sentence- and paragraph-level patterns, each stated as the exact observed pattern plus what editors must not do to it.
- **Narrator and voice** — POV behavior, reliability, any deliberate irregularities.
- **Structure** — how stories are shaped, chapter-title conventions, pacing values, how endings behave.
- **What this author does not do** — a bulleted never-suggest list; this is the section editorial skills lean on hardest.
- **Influences and what they mean in practice** — each influence as a mechanism visible in the prose, not a name-drop.
- **Developmental feedback calibration** — how a dev editor should filter findings through this aesthetic: what looks like a flaw but is the style, and the question to ask before flagging ("does the slow stretch have presence?"). End with the rule: flag only what works against the author's own register, never what merely works against generic taste.
- **Source note** — which works this was built from, the date, and the standing instruction to update it when new finished work appears or the author corrects the profile.
