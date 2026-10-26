# Meta Model API — facts we rely on

From `dev.meta.ai/docs` (models, overview) and `meta-models/meta-model-cookbook` (READMEs), Oct 26 2026.
Re-verify model IDs before the demo; they carry version numbers.

## Client setup

| Setting | Value |
| --- | --- |
| Base URL | `https://api.meta.ai/v1` |
| SDK | OpenAI Python SDK (`from openai import OpenAI`) — the official Model API client package is out of date, do not use it |
| Model | `muse-spark-1.3` (docs' default) |
| Key env var | `MODEL_API_KEY`, format `LLM\|{numeric_id}\|{secret}` |

```python
import os
from openai import OpenAI
client = OpenAI(base_url="https://api.meta.ai/v1", api_key=os.environ["MODEL_API_KEY"])
```

The key never enters this repo. It lives in the host env file (`~/.ccgram/.env` on the reference node) and is
read through the environment, never hard-coded.

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
