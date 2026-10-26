# Baseten credits — application answers

Submitted 2026-10-26 via the hackathon form (Google Forms). Kept here so the claim, the use case and the
demo claims cannot drift apart.

| Field | Answer |
| --- | --- |
| Full name | Preston Suroviec |
| Email on Cerebral Valley application | phsuroviec@gmail.com |
| Team name | Gravit Works |
| Teammate emails | *(blank — solo entry; the rules only allow approved participants)* |
| Track | Indie |
| GitHub | https://github.com/phsuroviec/gravit |
| Expected request volume | **Heavy (agents, batch)** |

## Project one-liner

> Gravit — a 3D puzzle game where a fold of space carries its own gravity and clock, so what you set going
> inside arrives in the outside world later.

## What are you building and how will you use Baseten? (2-4 sentences)

> I'm building Gravit, a solo-built 3D puzzle game in Godot for the Meta hackathon: the player carries and
> breaks folds of space, each with its own gravity direction and clock rate, and must reach an exit that is only
> reachable by using that law. Baseten's Muse Spark Open (`meta-models/muse-spark-open-1026`) will run the bulk
> generation pass — hint ladders, room briefings and variant room layouts as JSON, generated in batches of short
> prompts and checked into the repo. The 2M TPM limit lets me fan out 20-50 concurrent batch jobs instead of a
> serial queue, and that open-weight pass also backs my "built on Meta open-weight models" demo segment. Nothing
> runs in production: all inference is build-time, with no server and no runtime dependency for players.

## Notes

- The form collects the same e-mail that Cerebral Valley approved; the Google account used to fill the form can
  differ (it did here).
- Credits are personal use only per the acknowledgement; approval is discretionary and not guaranteed.
- After selection: claim in the Baseten dashboard, check the credit expiry there (not stated on the form),
  and record the win in `docs/meta-usage-log.md` when the first batch runs.
- Fallback if not selected: `meta-spark-open` via Modal, or run the generation pass on the Meta Model API and
  spend the $150 credits there instead.
