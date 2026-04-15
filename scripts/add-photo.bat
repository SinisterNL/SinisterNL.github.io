@echo off
:: ─────────────────────────────────────────────────────────────────
:: add-photo.bat — Drag any image onto this file to add it to the site
::
:: What it does:
::   1. Copies the image to incoming/
::   2. Claude Code (watch.py) picks it up automatically
::
:: Requirements:
::   - watch.py must be running (python scripts\watch.py)
::   - OR run this script which also triggers claude directly
:: ─────────────────────────────────────────────────────────────────

setlocal
set IMAGE=%~1
set PROJECT=%~dp0..
set FILENAME=%~nx1
set NAME=%~n1
set EXT=%~x1

if "%IMAGE%"=="" (
  echo ❌  Drag an image onto this file to use it.
  pause
  exit /b 1
)

echo 📸  Processing: %FILENAME%
echo →   Copying to images\...

copy "%IMAGE%" "%PROJECT%\images\%FILENAME%" >nul

echo →   Calling Claude to update the site...

cd /d "%PROJECT%"
claude -p "A new photo '%FILENAME%' was just added to the images/ folder. Follow the Photo Workflow in CLAUDE.md: identify the correct section (miniatures, curacao, dnd, or projects) based on the filename, add a .photo-item with a fitting caption, replace a placeholder if one exists, then commit and push to main."

echo.
echo ✅  Done — sinisternl.net will update in ~60 seconds.
pause
