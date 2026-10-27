#!/usr/bin/env python3
"""Validate generated game data against the hand-written schemas (stdlib only).

Usage: python3 scripts/validate_data.py
Exit 0 when every artefact in game/data/*.json parses and satisfies its
schema; exit 1 listing every violation. Run after any meta_generate.py pass.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "game" / "data"

ERRORS: list[str] = []


def fail(msg: str) -> None:
    ERRORS.append(msg)


def check(cond: bool, msg: str) -> None:
    if not cond:
        fail(msg)


def is_num(x) -> bool:
    return isinstance(x, (int, float)) and not isinstance(x, bool)


def is_vec3(x) -> bool:
    return isinstance(x, list) and len(x) == 3 and all(is_num(v) for v in x)


def check_marker(doc: dict, path: Path) -> None:
    m = doc.get("meta_model", "")
    check(isinstance(m, str) and m.startswith("meta-model: "),
          f"{path.name}: meta_model marker missing (attribution-policy)")


def check_hints(path: Path) -> None:
    try:
        doc = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"{path.name}: unreadable: {exc}")
        return
    check(isinstance(doc, dict), f"{path.name}: top level must be an object")
    if not isinstance(doc, dict):
        return
    check_marker(doc, path)
    rooms = doc.get("rooms")
    check(isinstance(rooms, list) and len(rooms) == 3, f"{path.name}: rooms must list exactly 3 rooms")
    for i, r in enumerate(rooms or []):
        tag = f"{path.name}: rooms[{i}]"
        check(isinstance(r, dict), f"{tag}: must be an object")
        if not isinstance(r, dict):
            continue
        check(isinstance(r.get("id"), str) and r["id"], f"{tag}: id missing")
        check(isinstance(r.get("briefing"), str) and len(r["briefing"]) >= 20, f"{tag}: briefing too short")
        hints = r.get("hints")
        check(isinstance(hints, list) and 3 <= len(hints) <= 5, f"{tag}: need 3-5 hints")
        for h in hints or []:
            check(isinstance(h, str) and len(h) >= 10, f"{tag}: hint too short")
        check(isinstance(r.get("fold_log"), str) and len(r["fold_log"]) >= 10, f"{tag}: fold_log too short")


def check_layout(path: Path) -> None:
    try:
        doc = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        fail(f"{path.name}: unreadable: {exc}")
        return
    check(isinstance(doc, dict), f"{path.name}: top level must be an object")
    if not isinstance(doc, dict):
        return
    check_marker(doc, path)
    check(isinstance(doc.get("name"), str) and doc["name"], f"{path.name}: name missing")
    folds = doc.get("folds")
    check(isinstance(folds, list) and 1 <= len(folds) <= 3, f"{path.name}: need 1-3 folds")
    for i, f in enumerate(folds or []):
        tag = f"{path.name}: folds[{i}]"
        check(isinstance(f, dict), f"{tag}: must be an object")
        if not isinstance(f, dict):
            continue
        check(is_vec3(f.get("pos")), f"{tag}: pos must be vec3")
        g = f.get("gravity_dir")
        check(is_vec3(g) and any(v != 0 for v in g), f"{tag}: gravity_dir must be nonzero vec3")
        check(is_num(f.get("clock_factor")) and f["clock_factor"] > 0, f"{tag}: clock_factor must be > 0")
        check(isinstance(f.get("holds_cube"), bool), f"{tag}: holds_cube must be bool")
    for key in ("cube", "pad", "door", "player_spawn"):
        check(is_vec3(doc.get(key)), f"{path.name}: {key} must be vec3")


def main() -> int:
    hints = DATA / "hints.json"
    if hints.exists():
        check_hints(hints)
    else:
        fail("hints.json: missing (run the generation pass)")
    for path in sorted(DATA.glob("variant_*.json")) + ([DATA / "room_variant_baseten.json"] if (DATA / "room_variant_baseten.json").exists() else []):
        check_layout(path)
    if ERRORS:
        print(f"{len(ERRORS)} data error(s):")
        for e in ERRORS:
            print("  -", e)
        return 1
    print(f"data OK: {hints.name}" + (" + variants" if list(DATA.glob("variant_*.json")) else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
