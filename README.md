# Gravit

A 3D puzzle game built in **Godot 4** for the **Meta Global AI Developer Hackathon** (Oct 26 – Nov 4, 2026).
One invented law of nature; everything else follows from it. Space can be **folded**.

> Status: pre-production. Kickoff Oct 26 12:00 PM ET; code written during the hackathon window
> Oct 27 – Nov 4. Nothing here is copied from a pre-existing product.

## The law

A fold is a pocket of space you can pick up, carry, place, or break. Each fold carries its own gravity,
its own magnetic direction, and its own clock: **time runs faster the deeper the fold is**. Magnets are how
you drag a fold from outside and how you keep two folds from colliding. Because a fold runs fast, a fix made
inside it lands in the parent world a few seconds later — that delay is the puzzle.

## Must-haves (hackathon rules)

- Public repository (this one), all work built within the hackathon window.
- Uses Meta models where they earn their place, and says exactly where: see
  [`docs/attribution-policy.md`](docs/attribution-policy.md).
- 3-minute demo video of what was actually built.
- Submission by **Wed Nov 4, 2026, 9:00 PM ET** via the Cerebral Valley platform.

## Layout

```
game/        Godot project (scenes, scripts, assets)
docs/        rules, API notes, concept, roadmap, research brief, credit guides
scripts/     repo tooling (secret scan)
```

## Read before writing code

| Doc | Why |
| --- | --- |
| [`AGENTS.md`](AGENTS.md) | Working agreement for any agent in this repo |
| [`docs/hackathon-rules.md`](docs/hackathon-rules.md) | Deadlines, judging rubric, disqualifiers |
| [`docs/game-concept.md`](docs/game-concept.md) | Current concept + alternates + open decisions |
| [`ROADMAP.md`](ROADMAP.md) | Phases to Nov 4; filled in from the research report |
| [`docs/meta-model-api.md`](docs/meta-model-api.md) | Model IDs, endpoint, key handling |
| [`docs/attribution-policy.md`](docs/attribution-policy.md) | How Meta-generated code is marked |

## Secrets

No keys in this repo, ever. `MODEL_API_KEY` and every other credential live outside the project
(`~/dev/env`-style files or the host's keychain). `scripts/check-secrets.sh` runs on every commit.

## License

MIT — see [`LICENSE`](LICENSE).
