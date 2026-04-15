#!/usr/bin/env python3
"""
Photo drop watcher for SinisterNL.github.io
─────────────────────────────────────────────
Drop any image into the incoming/ folder.
This script detects it, moves it to images/,
then calls `claude` (Claude Code CLI) to update
index.html and push the site automatically.

Usage:
  python scripts/watch.py

Requires:
  - Claude Code CLI installed (`claude` command available)
  - Run from the project root
"""

import time
import os
import subprocess
import shutil
from pathlib import Path

INCOMING = Path(__file__).parent.parent / "incoming"
IMAGES   = Path(__file__).parent.parent / "images"
PROJECT  = Path(__file__).parent.parent

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

seen = set()

def process(filepath: Path):
    name = filepath.stem.lower().replace(" ", "-") + filepath.suffix.lower()
    dest = IMAGES / name

    print(f"\n📸  New image detected: {filepath.name}")
    print(f"→   Moving to images/{name} ...")
    shutil.move(str(filepath), str(dest))

    prompt = (
        f"A new photo '{name}' was just added to the images/ folder. "
        f"Follow the Photo Workflow in CLAUDE.md: identify the correct section "
        f"(miniatures, curacao, dnd, or projects) based on the filename, "
        f"add a .photo-item with a fitting caption, replace a placeholder if one exists, "
        f"then commit and push to main."
    )

    print(f"→   Calling claude to update the site...")
    result = subprocess.run(
        ["claude", "-p", prompt],
        cwd=str(PROJECT),
        capture_output=False
    )

    if result.returncode == 0:
        print(f"✅  Done — site will be live at sinisternl.net in ~60s")
    else:
        print(f"⚠️   claude exited with code {result.returncode}")

def watch():
    INCOMING.mkdir(exist_ok=True)
    print(f"👀  Watching {INCOMING} for new images...")
    print(f"    Drop any photo there and it will go live automatically.\n")

    while True:
        for f in INCOMING.iterdir():
            if f.suffix.lower() in IMAGE_EXTS and f not in seen:
                seen.add(f)
                try:
                    process(f)
                except Exception as e:
                    print(f"❌  Error processing {f.name}: {e}")
        time.sleep(2)

if __name__ == "__main__":
    watch()
