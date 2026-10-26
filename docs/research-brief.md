# Gemini prompt — research + roadmap for Gravit

Paste the block below into **Gemini web or the Android app** (not an agent harness: this is the cheap,
unmetered reading pass). Use **Deep Research** — the report is the point. Bring the output back here; I distil
it into `ROADMAP.md`, `tickets/`, and the concept freeze.

## Prompt (copy everything between the lines)

```text
You are helping a solo developer ship a small 3D puzzle game in 10 days. Give me a research report with a
concrete plan, not encouragement.

FIXED FACTS — do not renegotiate these
- Event: Meta Global AI Developer Hackathon, Oct 26 12:00 PM ET kickoff, submission Nov 4 9:00 PM ET.
- Solo, first game ever, first time using Godot 4 (4.3+). I code with an AI assistant, so scenes/scripts must
  stay plain text (.tscn/.gd).
- Judging: Impact 30%, Use of Meta AI Tooling 25%, Technical Depth & Execution 20%, Demo 25%. Rules forbid
  political or war themes, and the demo may show only what I built during the event.
- Deliverable: ONE course of 3-4 rooms in 3D, playable, where the exit is reachable only by using the invented
  law. No story mode, no menus beyond start/restart, no saving. A 3-minute demo video is mandatory.
- Meta models are available through the Meta Model API (OpenAI-compatible base URL https://api.meta.ai/v1):
  muse-spark-1.3 (text/image/video/PDF in, 1M context, reasoning_effort), muse-image-1.0, sam-3.1,
  muse-voice-transcribe-1.0, muse-wonder-1.0. Build-time use is fine; runtime use is optional.

THE FROZEN CONCEPT
Law: gravity and time are properties of the scope you are in. Space can be folded: a fold is a bounded region
you can carry, place and break. Inside a fold you fall toward the fold's own down, and your clock runs at the
fold's rate. Anything set going inside a fold arrives in the parent world late — the deeper the fold, the later.
A fold is NOT a separate world/scene — it is a region that overrides gravity and a time factor for whatever is
inside it (no nested viewports). Two parameters per fold: gravity direction, clock factor.
Mechanics to build: walk/ look/ jump; place a fold; carry it; break it; fall the fold's way inside; one delayed
consequence applied to the parent world; a final door that opens only from an event queued through a fold.
Deliberately cut: magnets, polarity, mass-nesting, visible gravity echoes, speedrun score (a Replay timer unlocks
after first completion), runtime LLM calls in gameplay.

QUESTIONS I NEED ANSWERED
1. GODOT 4.3 IMPLEMENTATION, with exact node types and minimal code shapes:
   a) One pure function applied_gravity(body, t) shared by the player (CharacterBody3D, manual gravity) and
      RigidBody3D objects. How do I make an Area3D region override gravity for both without fighting Godot's
      built-in gravity, and what are the known pitfalls (Area3D priority, gravity_point, up_direction,
      move_and_slide, physics interpolation in 4.3)?
   b) A per-region "clock factor": what is the cheapest honest way to make objects inside a fold move faster
      without a separate SceneTree or Engine.time_scale (which would speed the whole game)? Compare
      (i) scaling delta for bodies in the region, (ii) a delayed-consequence queue, (iii) a subviewport.
      Recommend one for a beginner and say what breaks.
   c) Carrying and placing a fold that contains physics objects: keep them as children of the fold
      Area3D/Node3D, or reparent on pickup? Which causes the fewest transform and physics bugs in Godot 4.3?
   d) A delayed consequence: queue (body, impulse, due_time) and apply it later, with a visible countdown.
      Show the minimal GDScript and the failure modes (paused physics, freed bodies, double-apply).
2. HEADLESS TESTS in Godot 4.3 for these invariants: (i) fold scopes form a tree, (ii) gravity inside a fold
   equals the fold's, (iii) a queued consequence fires exactly once at the expected time, (iv) breaking a fold
   moves its contents to the parent scope without loss. Give the CLI invocation and a minimal test harness.
3. PRIOR ART and defensible differentiation: Portal, Manifold Garden, Maquette, Superliminal, Gravity Rush,
   Outer Wilds, The Sojourn, and indie nested-world games. For each, the core verb. Then the ONE sentence I can
   say that is both true and distinctive for this concept, plus the two comparisons a judge will make and how I
   pre-empt them in the demo video.
4. PSYCHOLOGY OF THE FIRST THREE MINUTES: what concretely makes a puzzle room read as fair, teachable and
   rewarding (competence, curiosity gap, predictable failure cost, telegraphing, one-idea-per-room), with
   sources. Then a specific teach-by-doing sequence for rooms 1-3 (what the player sees, does, and learns in each),
   designed so a first-time player cannot get permanently stuck.
5. META MODEL API USE THAT JUDGES WOULD SCORE: with the constraint that a puzzle game must not have LLM latency
   in the loop, which uses are defensible — build-time hint ladders and room briefings as JSON, texture
   generation, narration/transcription, an in-game "fold log" narrator that summarises the last change, or
   something better I have not thought of? For each: implementation cost in days, demo visibility, and the
   failure mode. Recommend two.
6. 10-DAY PLAN with a hard CUT LINE on Nov 2: day-by-day tasks, an explicit "if this is not working by Oct 28,
   fall back to X" checkpoint, the three riskiest items with fallbacks, and the last-two-days demo plan (record,
   edit, submit).
7. DEMO SCRIPT for exactly 3:00: second-by-second beats, what is on screen, what the voice-over says (max ~45
   seconds of speech total), and which rubric axis each beat targets.

FORMAT: sections 1-7, each starting with a one-paragraph recommendation, then evidence with links. Mark anything
you could not verify as UNVERIFIED. No filler, no encouragement, no restating my constraints back to me.
```

## What to bring back

1. Save the full report as `docs/research/gemini-<date>.md` (verbatim, with links).
2. I distil it into `ROADMAP.md` (phases + cut line), `tickets/` (tracer bullets with blocking edges), and the
   frozen mechanics in `docs/game-concept.md`.
3. Only ask Gemini a follow-up for a decision that is still open — e.g. "show me the minimal working GDScript for
   `applied_gravity()` with an Area3D region and a CharacterBody3D, with the pitfalls". Never ask it to write the
   whole game: the harness writes code, Gemini does the reading.
