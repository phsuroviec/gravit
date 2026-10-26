# Hackathon rules — extracted from the official guide

> **Internal checklist, not part of the pitch.** Kept in-repo so deadlines, the rubric and DQ traps are one
> grep away while working. The README is the judge-facing surface.

Source: Cerebral Valley event page screenshots (Oct 26, 2026). Re-check against the live page if anything
looks stale. Track: **Indie Developer** (solo, no team, no startup entity).

## Dates (all Eastern Time)

| When | What |
| --- | --- |
| Mon Oct 26, 12:00 PM | Kickoff: opening remarks, rules, prizes, judging, Meta speaker |
| Tue Oct 27, 12–1 PM | Agents 101: Build a Multimodal AI Agent (Suraj Subramanian) |
| Wed Oct 28, 12–1 PM | Agents 102: Best Practices for Verifiable Agents (Yash Khare) |
| Fri Oct 30, 12–1 PM | Building Specialized Intelligence on Fireworks: Inference → Training with Muse Open Models (Sinan Ozdemir) |
| Daily, except weekends, 10–11 AM | Discord `#office-hours` (Meta team, text) |
| Tue Nov 3 | Last full day for submission questions / technical troubleshooting |
| **Wed Nov 4, 9:00 PM** | **Submission deadline** (site + $150 credit claim form) |
| Thu Nov 5 – Sun Nov 8 | Judging |
| Mon Nov 9, 12:00 PM | Closing ceremony; top 10 (5 per track), live final round, winners, community vote opens |
| Mon Nov 16 | Community vote winner announced on Discord |

Building period: **Oct 27 – Nov 4**. All times ET.

## Problem statements

1. **Build for Your World** — bring Meta's models into your domain; solve a problem you know firsthand.
2. **Push the Frontier** — use Meta's models on software, robotics, manufacturing, energy, materials and beyond.

Project must incorporate Meta's models: Muse Spark series, Muse Wonder, Muse Image, Muse Voice Transcribe,
SAM 3.1 through the **Meta Model API**, run Meta open-weight models (**Muse Glimmer**, **Muse Spark Open**),
and/or code with **Muse Code**.

## Rules that can disqualify

- **Open source:** repositories must be public.
- **Team size:** max 4; solo allowed.
- **Demo scope:** the demo must only highlight features, code and functionality built during the hackathon.
  Judges must be able to identify what was created during the event. Failure → immediate disqualification at
  judges' discretion.
- **New work only:** what you present must have been built during the event. Startups may build on existing
  products/codebases but must clearly identify what is newly developed.
- **Banned:** projects violating legal/ethical/platform policy, or using code, data or assets you do not have
  the rights to.
- **Anti-projects (avoid):** medical-advice AI, basic RAG apps, simple image analyzers, simple "AI for
  education" chatbots, job-application screeners, nutrition coaches, personality analyzers, sports
  analyzers/coaches, anything political or war-related.

## Submission

- One submission per team/startup, by a designated **Representative**, via the CV platform, by
  **Nov 4, 9:00 PM ET**. Late submissions are not considered.
- Requires a **3-minute demo video** of the specific features/code/functionality built here; judges use the
  video plus code and the live product.
- Double-check: repository public, video link accessible, everyone who worked on it listed.

## Judging

- **Stage 1** — pass/fail viability: fits the theme and reasonably used Meta Model API and/or open-weight
  models.
- **Stage 2** — 0–10 rubric:
  | Category | Weight |
  | --- | --- |
  | Impact | 30% |
  | Use of Meta AI Tooling | 25% |
  | Technical Depth & Execution | 20% |
  | Demo | 25% |
- **Stage 3** — top 5 per track present live; final-round judges watch video demos and rank on the same rubric.

## Bonus prizes (from the Discord FAQ, itemised)

| Award | Amount |
| --- | --- |
| Most Viral Project | $20,000 |
| **Best Build on Meta Open Weight Models** | $10,000 |
| Community Vote | $10,000 |
| Best Agentic Use-Case | $5,000 |
| **Best Creative Build** | $5,000 |

Three of these are reachable for a game built the way we are building it: **Best Creative Build** (a game about an
invented law of physics), **Best Build on Meta Open Weight Models** (if a visible part of the build genuinely runs
on `muse-spark-open-1026`), and **Best Agentic Use-Case** (only if the build has an agent, not a prompt).

## FAQ corrections (Discord, Kai | CV)

- **Building period starts after the kickoff session** (Oct 26, 12:00 PM ET) — not before. Our repo was created
  after the kickoff; anything earlier would not count.
- **Collaborators must be approved participants.** No new approvals (at capacity). Confirms the solo entry.
- **Prior-codebase projects:** the submitted repo must be a **standalone extract / fresh repo** containing only
  work done during the event, and the demo's first line must say what was pre-existing vs built this week.
  Gravit's answer is simple: the repository itself is new, so the opening line is "nothing pre-existing — this
  repo and everything in it was built during the hackathon".
- **Most Viral Project:** post the demo on X and submit the post link through the platform; engagement counts
  through **Nov 8 end of day**. Community voting opens **Nov 9**, one vote per verified account.
- **Card:** a temporary pre-authorisation charge appears when a payment method is added and clears in a few
  business days; a "card restricted" error means Meta's payment check failed and a different card is needed.

## Rubric discrepancy — record both readings

- Guide page (screenshot): Impact 30%, Use of Meta AI Tooling 25%, Technical Depth & Execution 20%, Demo 25%.
- Discord FAQ: projects are "scored equally on Impact, Use of Meta AI tooling, Technical depth and execution,
  Demo quality".

FAQ prose is looser than the rubric table, so we plan against the **weighted** version (Impact and Demo lead)
and treat "equally" as a rounding of the same four axes. Nothing in our plan changes under either reading:
Impact and Demo are the two we invest in, Tooling is made visible, Depth comes from the tested gravity core.

## Prizes

- **Indie Developer track — $400,000:** 1st $150K, 2nd $100K, 3rd $75K, 4th $50K, 5th $25K.
- **Startups track — $550,000:** 1st $250K, 2nd $150K, 3rd $75K, 4th $50K, 5th $25K.
- **Bonus from Meta — $50,000:** standout projects and community achievements.
- Total pool $1,000,000. Community vote winner announced Nov 16.

Gravit competes in the **Indie Developer** track (solo, no company entity).

## Credits (do this early)

- **$150 Meta Model API credits** per accepted participant, one claim per person, no proxy claims.
- Claim via the Google form linked on the event page **by Wed Nov 4, 9:00 PM ET**; credits land in batches
  (check Billing) within ~2 business days.
- A **payment method must be on file** to make API calls even with credits; a temporary pre-authorisation
  charge appears and is released within a few business days. Set a **Spend Limit** on the Billing page, but the
  FAQ is explicit: **do not assume a Spend Limit automatically stops billing**. Monitor Billing; the limit is a
  notification, not a hard cap. Treat `$150` as a hard budget we police ourselves.
- **Baseten:** $100 credits + 2M TPM for up to 2,000 participants (per individual, use-case review). Use
  model id `meta-models/muse-spark-open-1026` (not the docs' `muse-spark-open`).
- **Modal:** $100 credits, first 1,000 participants (open-weight models via Endpoints).
- **Fireworks:** the guide said $25 for shortlisted teams; the FAQ now says **details TBC** — treat as unavailable
  until announced.
- Partner credits are not guaranteed and are at each partner's discretion.
