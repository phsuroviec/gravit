# Meta Model API — facts we rely on

From `dev.meta.ai/docs` (models, overview) and `meta-models/meta-model-cookbook` (READMEs), Oct 26 2026.
Re-verify model IDs before the demo; they carry version numbers.

## Client setup

| Setting | Value |
| --- | --- |
| Base URL | `https://api.meta.ai/v1` |
| SDK | OpenAI Python SDK (`from openai import OpenAI`) — the official Model API client package is out of date, do not use it |
| Model | `muse-spark-1.3` (docs' default) |
| Key env var | `MODEL_API_KEY` — the value shipped as a single `LLM_...` string (the cookbook's `LLM\|{id}\|{secret}` shape is the older form; both are just an opaque Bearer token) |

```python
import os
from openai import OpenAI
client = OpenAI(base_url="https://api.meta.ai/v1", api_key=os.environ["MODEL_API_KEY"])
```

The key never enters this repo. It lives in the host env file (`~/.ccgram/.env` on the reference node) and is
read through the environment, never hard-coded.

## Rate card we plan against

Read from the pi model catalog (`muse-spark-*` entries) on 2026-10-26. Cross-check the Billing page before trusting
it; the event guide's own pricing page is client-rendered and I could not read a table from it.

| Model | Input /M | Output /M | Cache read /M |
| --- | --- | --- | --- |
| `muse-spark-1.3` (and 1.1 / 1.2) | $1.25 | **$4.25** | $0.15 |
| `muse-spark-1.3-contributor` | $0.10 | $0.20 | $0.002 |
| `muse-spark-1.3-contributor-free` | $0 | $0 | $0 |

Consequence for budgeting: **$150 buys roughly 35M output tokens** of `muse-spark-1.3` (or far more with cache
reads and short prompts). Our build-time generation is a few million tokens at most, so the $150 is not the
constraint — wall-clock time is. Do not buy a subscription plan to "save credits"; the plan does not spend
against Model API usage.

## Models

| Model ID | Input → output | Notes |
| --- | --- | --- |
| `muse-spark-1.3` | text, image, video, audio, PDF → text | 1,048,576-token context; agentic tuning; supports every `reasoning_effort` incl. `max`. Audio understanding degraded — use 1.2 or Transcribe for audio. Default for code-agent style work. |
| `muse-spark-1.2` / `muse-spark-1.1` | same | earlier versions |
| `muse-spark-1.3-contributor` | same | contributor tier; **no** `max` reasoning |
| `muse-wonder-1.0` | text → text | long-running agentic work; docs' coding-agent/agent-framework guides use it; Standard mode only, pay-as-you-go and every plan ("Muse Wonder Full" not available) |
| `muse-image-1.0` | text/image → image | generate and edit |
| `muse-voice-transcribe-1.0` | audio → text | live streams and files; real-time speech |
| `sam-3.1` | image + prompts → masks | segmentation with point/box/text prompts |
| Muse Code | agent harness | coding agent with `/plan`, `/grilling`, `/grill-with-docs`, `/taste` skills, audit log, staged approvals |

## API surface worth using

Chat Completions (streaming, tool calling, structured output/JSON mode, prompt caching, reasoning tokens via
`reasoning_effort` + `reasoning_content`), Responses (`web_search` grounding with `url_citation`
annotations), vision input, 1M context, images, voice, SAM.

Recipes that matter for us: `01_chat_completions`, `03_tool_calling`, `04_structured_output`,
`06_reasoning_tokens`, `07_vision_input`, `08_long_context`, `10_search_grounding`
(`meta-models/meta-model-cookbook/01_api_fundamentals`).

## Where Meta models plug into Gravit

| Job | Model | Why |
| --- | --- | --- |
| In-game dialogue / grimoire text generation at build time | `muse-spark-1.3` structured output | schema-guaranteed JSON of lines, no runtime cost |
| Art: fold textures, icons, loading art | `muse-image-1.0` | no artist on a 10-day solo build |
| Voice-over / narration for the demo | `muse-voice-transcribe-1.0` | transcribe voice notes → docs; also captions |
| Cut-out masks for assets | `sam-3.1` | segment art for alpha channel |
| Long agent sessions (asset pipeline, refactors) | `muse-wonder-1.0` | built for long-horizon runs |
| Code authoring | Muse Code or this harness | log which model wrote what |

## Verified against the live API (2026-10-26)

- Chat completion on `muse-spark-1.3` → HTTP 200, `chatcmpl-…` id, usage block present.
- **Tool calling works**: a request declaring one function returned `tool_calls` with arguments, plus reasoning tokens.
- **Reasoning eats the output budget**: `max_tokens: 8` returned `completion_tokens: 8` of which 6 were reasoning —
  `content` was empty. Set `max_tokens` ≥ 800 for real generation, or read `reasoning_content` if you only want thinking.
- Prompt caching is live (`cached_tokens` in `prompt_tokens_details`).

## Which wallet pays for which call

Two independent balances. Neither is a discount on the other.

| Wallet | Where it is spent | What it can run | State |
| --- | --- | --- | --- |
| **Meta Model API credits** ($150, applied) | `api.meta.ai` | every Meta model: `muse-spark-1.3`, `muse-wonder-1.0`, `muse-image-1.0`, `muse-voice-transcribe-1.0`, `sam-3.1` | **confirmed on the account** |
| Baseten credits ($100 + 2M TPM, applied for) | Baseten's servers | only **open-weight** Meta models they host: `meta-models/muse-spark-open-1026` | pending approval |
| Modal credits ($100, optional) | Modal GPUs / sandboxes | open-weight weights you host **yourself** (vLLM etc.) — same models, your own inference server | not needed for this build |
| Fireworks (TBC) | Fireworks | open-weight inference | ignore until announced |

Meta's API key routes to Meta's own hosted models and cannot spend a Baseten or Modal dollar: there is no
"routing" between wallets. Conversely Baseten cannot run `muse-spark-1.3` (a hosted, non-open model) — it only
serves the open-weight family.

## Open-weight route (optional, separate credits)

Baseten `meta-models/muse-spark-open-1026` ($100 credits, 2M TPM); Modal $100 credits for Meta open-weight
models via Endpoints/GPUs. Only worth wiring if the game needs self-hosted inference; the Model API path
covers everything above.

## Wiring the pi harness to Meta (when the key exists)

The harness is provider-agnostic; a Meta provider entry points at the OpenAI-compatible base URL. Draft
config (add the key **outside** the repo, then reload):

```jsonc
// ~/.pi/agent/models.json (host file, not in this repo)
{
  "providers": {
    "meta": {
      "baseUrl": "https://api.meta.ai/v1",
      "apiKeyEnv": "MODEL_API_KEY",
      "models": ["muse-spark-1.3", "muse-wonder-1.0"]
    }
  }
}
```

Then `/model meta/muse-spark-1.3` inside the session, or launch with
`pi --provider meta --model muse-spark-1.3 --thinking medium`. Confirm the exact schema with
`pi auth --help` / `pi --help` before trusting this block — the harness may use a different key name.
