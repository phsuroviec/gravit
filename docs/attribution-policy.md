# Attribution policy — marking Meta-generated code

Judges score **Use of Meta AI Tooling (25%)** and may disqualify a project whose original contributions are
unclear. So every artefact says which model produced it, in the artefact itself, and the log says why.

## Markers

Code written or substantially edited by a Meta model is wrapped in **header + footer** comments naming the
model, the date and the purpose. The markers survive formatting and are visible in the diff.

GDScript:

```gdscript
# --- meta-model: muse-spark-1.3 | 2026-10-29 | fold gravity solver scaffolding ---

func fold_gravity_strength(depth: int) -> float:
    ...

# --- end meta-model ---
```

Python (tooling, generation scripts):

```python
# --- meta-model: muse-wonder-1.0 | 2026-10-30 | asset pipeline: fold textures ---
...
# --- end meta-model ---
```

Markdown / docs:

```markdown
<!-- meta-model: muse-spark-1.3 | 2026-10-28 | first draft of the fold tutorial text -->
```

Assets (`.png`, `.wav`, `.ogg`): record the model, prompt and date in
[`meta-usage-log.md`](meta-usage-log.md) **and** put the same line in the asset's `.import`-adjacent
`.meta.md` sidecar (e.g. `assets/fold-wall.png.meta.md`).

## Rules of thumb

- **Do** mark generated functions, generated docs, generated art/audio, and whole files a model wrote.
- **Don't** wrap hand-written code. The demo video must show human work too; over-marking is as misleading as
  under-marking.
- A file that is half-human, half-model gets two blocks, each labelled.
- Regenerating a marked block: update the date, keep the model name honest.
- The log line is the source of truth; markers point at it.

## What this buys us

- Honest story in the 3-minute video: "these systems are model-assisted, this is what I designed".
- A mechanical answer to "what was built during the hackathon" — every marked block is dated inside the
  window, and `git log` backs it.
- Cheap audit before submission: `grep -rn "meta-model:" game/ docs/` must match the log's counts.

## Pre-submission check

```bash
scripts/check-attribution.sh   # counts markers per model, flags unmarked generated dirs
```

Keep `docs/meta-usage-log.md` and the markers in sync; the judge-facing README summarises both.
