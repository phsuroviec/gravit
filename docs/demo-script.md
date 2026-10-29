# Demo script — PARKED (superseded 2026-10-28)

> The shot plan below describes rooms 1–3, crates, and the break verb — none
> of which exist anymore. The game is now one stunt room (see
> [`levels.md`](levels.md)). This file is kept as reference for shot
> structure only (opening line, lossless capture, captions pipeline). It will
> be rewritten from the as-built room when video work starts.

# Demo script — 3:00, lossless capture, phone voice-over (ARCHIVAL)

Target: submitted before **Nov 4, 9:00 PM ET** with a working video + repo link.
Record Nov 3 (after the Nov 2 `v1.0-freeze`): the game must not change under the footage.

## Rules for the first five seconds

Say on screen and in voice: **"Nothing pre-existing — this repository and everything in it was
built during the hackathon."** Then show the effect, never the premise.

## Shot plan

| Time | Shot | Audio |
| --- | --- | --- |
| 0:00–0:05 | Required opening line, title card | VO line 1 |
| 0:05–0:15 | Crate dropped into Room 1 fold, falls sideways; break; crate lands behind the wall; door blasts open | game sound only |
| 0:15–0:45 | Room 1 full clear, uncut: walk in, watch the fall, countdown ticks, door opens, walk through | VO line 2 under it |
| 0:45–1:15 | Room 2: E pickup, carry the frozen fold, X break over the plate, door opens | game sound only |
| 1:15–1:45 | Room 3: nested folds, E grabs inner, break, cube bends left, exit opens | VO line 3 under it |
| 1:45–2:10 | Airlock terminal: fold log, T narration, H hints, replay timer after completion | game sound only |
| 2:10–2:40 | Meta segment (screen capture, not gameplay): `meta_generate.py` call → `hints.json` loads in game; decals on walls; `meta-proof.md` table. Open-weight variant only if the Baseten key landed — never promise it otherwise | VO line 4 |
| 2:40–3:00 | Full-course speedrun tail, repo link + commit graph on screen, closing line | VO line 5 |

## Voice-over (~43 s, ~110 words — record on the phone, transcribe for captions)

1. "Nothing pre-existing — this repository and everything in it was built during the hackathon."
2. "Gravity here isn't global. Every fold of space has its own down, and its own clock."
3. "Break a fold and its contents drop into your world — late, and somewhere else."
4. "The words, hints and signs were generated with Meta models at build time; the receipts are in the repo."
5. "Three rooms, one law. Gravit."

## Captions

Transcribe the phone recording with `muse-voice-transcribe-1.0`, time the lines to the shots
above, burn in or ship `.srt` alongside. Keep the build-time fallback text if the service is
slow — captions ship either way.

## Capture specs

- 60 FPS lossless (GPU screen capture, not a camera), 1920×1080.
- Cut to **at most** 3:00 — aim 2:55 for platform slop.
- No letterboxing, no generative B-roll, no music that needs a license (game sound only).

## Owner checklist (Nov 3–4)

- [ ] Fresh-eyes playtest: unassisted clear of rooms 1–3 under 3 minutes (T8 exit)
- [ ] Record gameplay per the shot plan; record the 5 VO lines on the phone
- [ ] Transcribe + time captions; assemble; verify duration ≤ 3:00
- [ ] Paste the video link into README.md (Demo section) and the submission form
- [ ] Re-run `sh scripts/meta-proof.sh`, confirm the table matches the log
- [ ] Submit before Nov 4, 9:00 PM ET
