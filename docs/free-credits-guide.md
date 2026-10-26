# Free credits — step-by-step

Goal: $150 Meta Model API credits in hand **before** the build days, plus the partner credits worth claiming
(Baseten $100, Modal $100, Fireworks $25 shortlist). Total possible ≈ $375, all of it free.

Deadline for the Meta form and the submission: **Wed Nov 4, 2026, 9:00 PM ET**. Claim on day 1 — credits land
in batches within ~2 business days.

## 1. Meta Model API account + $150

1. Open <https://dev.meta.ai/> and sign in / create the developer account (use the **same identity** you used
   to register for the hackathon, since the form asks for your accepted-participant details).
2. **Billing → add a payment method.** Required: no API call succeeds on credits alone. A temporary
   pre-authorisation charge appears and is released within a few business days.
3. **Billing → set a Spend Limit** to the credit amount ($150). **The FAQ warns a Spend Limit notification does
   not necessarily stop billing** — it is an alert, not a hard cap. The real guard is our own per-run budget
   check in `scripts/meta_generate.py --check` plus the ledger rows; never launch an unbounded generation loop.
4. Create an API key. It looks like `LLM|{numeric_id}|{secret}`. Store it **outside** this repo: append
   `MODEL_API_KEY=...` to the host env file (`~/.ccgram/.env` on this node) and never echo it.
5. Submit the **Model API Credit Claims** Google form linked on the event page (also in the event Details
   page under "5. Meta Provided Resources"). Fields: full name + accepted-participant e-mail; one claim per
   person, no claims on someone else's behalf.
6. Check **Billing** after ~2 business days; the free credit line must appear before you rely on it.

Verification (safe, no key printed):

```bash
python3 - <<'PY'
import os
k = os.environ.get("MODEL_API_KEY", "")
print("MODEL_API_KEY present:", bool(k), "| segments:", len(k.split("|")))
PY
curl -s -o /dev/null -w '%{http_code}\n' https://api.meta.ai/v1/models \
  -H "Authorization: Bearer $MODEL_API_KEY"
```

## 2. Baseten — $100 + 2M TPM

1. <https://www.baseten.co/> account, then the hackathon request form (linked on the event page; the Google
   Forms URLs on the resource page).
2. Per individual, not per team; up to 2,000 participants; reviewed on use case — say "3D puzzle game asset
   and narration generation, plus Muse Spark Open inference".
3. When approved: use model id **`meta-models/muse-spark-open-1026`** (the docs say `muse-spark-open`; the
   hackathon build is the `-1026` one).
4. Baseten channel in the hackathon Discord for problems.

## 3. Modal — $100

1. <https://modal.com/> account (GitHub sign-in is fastest), then the hackathon credit form.
2. First 1,000 participants; for Meta open-weight models via Endpoints, plus serverless GPUs and sandboxes.
3. Useful if we want to host SAM 3.1 or a Muse open model instead of paying per call.

## 4. Fireworks — $25 (shortlist)

1. The FAQ lists Fireworks as **details TBC** (the guide had $25 for shortlisted teams).
2. Treat it as unavailable until announced; design nothing around it.

## 4b. What we actually claim, and why

| Partner | Claim it? | Use it for | Why |
| --- | --- | --- | --- |
| Meta Model API ($150) | **Yes, first** | `muse-spark-1.3` hint ladders + room briefings, `muse-image-1.0` textures, `muse-voice-transcribe-1.0` narration | Only these count for the "Meta Model API" clause of the rules and the 25% tooling axis |
| Baseten ($100 + 2M TPM) | **Yes** | bulk text generation on `meta-models/muse-spark-open-1026`: draft hint variants, flavour text, naming, rewrites | Saves the $150 Meta credits for demo-critical calls; also satisfies "run Meta open-weight models" |
| Modal ($100) | Only if needed | nothing planned | A Godot game needs no GPU hosting or sandboxes; claiming it without using it is noise |
| Fireworks (TBC) | No | — | FAQ says details TBC; ignore until announced |

Rule of thumb: **Meta credits buy the parts judges see; Baseten free credits buy the bulk drafts.** Both are
logged in `docs/meta-usage.jsonl`, so the split is visible rather than implied.

## 5. Spend discipline

- Model API credits are **per person**; the $20/month plan question is separate — the hackathon path is
  pay-as-you-go credits, so a plan is optional and not needed to keep building.
- Generation runs go in batch scripts under `scripts/`, not in interactive chat, so a loop cannot burn credit
  unnoticed. Every script prints `usage` from the response.
- Keep the Spend Limit at $150 until submission; raise only after the demo is recorded.
- Track spend against `docs/meta-usage-log.md` — one row per job, so cost per artefact is visible.

## 6. What is still unknown (answer via Discord `#questions` / office hours)

- Whether the $20/month Meta plan covers Model API usage or only the consumer apps (assume **API = credits**).
- Whether prize eligibility requires the Model API specifically (fine either way — we use it) or accepts only
  open-weight inference for the "Push the Frontier" statement.
- Whether free-tier rate limits apply on top of credits, and the TPM ceiling for `muse-spark-1.3`.
