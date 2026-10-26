# Research brief — paste into Gemini (web or Android, not an agent harness)

Purpose: turn the seed concept into a roadmap we can implement in 10 days, without spending coding-agent
quota. Gemini does the reading; this repo keeps the decisions.

## Prompt (copy everything in the block)

```text
I have 10 days to build a small 3D puzzle game in Godot 4 for the Meta Global AI Developer Hackathon.
Solo developer, first game, first time using Godot. The demo is a 3-minute video and the judging rubric is:
Impact 30%, Use of Meta AI Tooling 25%, Technical Depth & Execution 20%, Demo 25%.

The one invented law of nature: space can be folded. A "fold" is a pocket universe you can pick up, carry,
place, or break. Each fold has its own gravity direction/strength, its own magnetic direction, and its own
clock — time runs faster the deeper the fold. Magnets let you drag a fold from outside and keep two folds
from colliding. Because a fold runs fast, a fix made inside it lands in the parent world a few seconds later.
Setting: post-collapse world built on this law; folds are infrastructure (storage, smuggling, shortcuts) and
hazard (unstable folds swallow city blocks).

The deliverable: one course of 3-4 rooms, walkable, where you must fold and break to reach an exit that is
otherwise unreachable. Nothing else. No story mode, no menus beyond start/restart.

Please research and report, with sources:

1. GAME DESIGN. For this exact constraint (3-4 rooms, 10 days, one mechanic family), what makes a puzzle
   game read as "fun" in a 3-minute demo? Give concrete design rules: teach-by-doing sequencing, one screen
   one idea, telegraphing, fail states that are cheap to retry, what to cut. Cite puzzle-game design writing
   and postmortems of small 3D puzzle games.
2. PRIOR ART. What already exists with folded/nested space, gravity direction changes and magnetic dragging?
   (Portal, Manifold Garden, Maquette, Superliminal, Gravity Rush, Outer Wilds, The Turing Complete-like
   nested-world indies...) For each: what is the core verb, and which of our ideas would look derivative?
   Name the differentiator we can defend in one sentence.
3. GODOT 4 FEASIBILITY. For a beginner with an AI coding assistant: the cheapest reliable way to implement
   (a) a first/third-person controller, (b) an "object with its own gravity" in Godot 4 3D (Area3D gravity
   override vs. custom gravity in the character body vs. a subviewport scene), (c) picking up and placing a
   container that holds a scene, (d) a magnet drag at range, (e) simple polarity repulsion between two
   bodies. Give the recommended approach per item, with the Godot 4.x class names and the known pitfalls
   (e.g. CharacterBody3D up_direction, gravity vector, RigidBody3D custom gravity, Area3D priority).
4. TIME-DILATION. Compare: real scene time-scale difference (subviewport with Engine.time_scale or a separate
   SceneTree) vs. a "delayed consequence queue" that fakes it. Which one can a beginner ship in 10 days, and
   which reads better on video? Recommend one.
5. AI TOOLING ANGLE. The rubric gives 25% to "use of Meta AI Tooling". What are honest, non-gimmicky ways for
   a game to use an LLM API (Muse Spark) that judges would score well: build-time content generation, runtime
   NPC/mission text, generated puzzle hints, voice narration, texture generation, segmentation for art. Which
   of these are demo-visible in 3 minutes, and which are cheap to implement in Godot 4?
6. 10-DAY PLAN. A day-by-day plan (Oct 27 - Nov 4) with a hard "cut line": what must work by Nov 2 so the
   last two days are demo, polish and submission. Flag the three riskiest items and the fallback for each.
7. DEMO SCRIPT. A 3-minute video script skeleton (0:00-0:20 hook, mechanic reveal, one puzzle solved,
   AI-tooling proof, what is next). Keep it honest about scope.

Format: sections 1-7, each with a short recommendation first, then evidence and links. Mark anything you
could not verify. No filler.
```

## What to bring back

Save the full answer as `docs/research/gemini-<date>.md`, then distil it into:

- `ROADMAP.md` — phases, cut line, risks (delete the placeholder table).
- `docs/game-concept.md` — freeze D1–D6 with one line of reasoning each.
- `tickets/` — one file per tracer-bullet ticket with blocking edges.

## Second pass (optional, still on Gemini)

Ask a follow-up only for the two decisions that stayed open, e.g. "give me the exact Godot 4 node tree and
code skeleton for custom gravity inside an Area3D, minimal working example, with the pitfalls". Do not ask it
to write the whole game — the harness writes the code, Gemini does the reading.
