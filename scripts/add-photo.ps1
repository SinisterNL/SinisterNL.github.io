# ─────────────────────────────────────────────────────────────────
# add-photo.ps1 — Add a photo to the site automatically
#
# Usage:
#   .\scripts\add-photo.ps1 "C:\path\to\photo.jpg"
#   .\scripts\add-photo.ps1 "C:\path\to\photo.jpg" "My custom caption"
#
# Or right-click → Run with PowerShell after dragging image onto it.
# ─────────────────────────────────────────────────────────────────

param(
    [Parameter(Mandatory=$true)]
    [string]$ImagePath,

    [Parameter(Mandatory=$false)]
    [string]$Caption = ""
)

$ProjectRoot = Split-Path $PSScriptRoot -Parent
$FileName    = [System.IO.Path]::GetFileName($ImagePath)
$Dest        = Join-Path $ProjectRoot "images\$FileName"

# Validate input
if (-not (Test-Path $ImagePath)) {
    Write-Host "❌  File not found: $ImagePath" -ForegroundColor Red
    exit 1
}

# Copy image
Write-Host "📸  Copying $FileName to images/..." -ForegroundColor Cyan
Copy-Item $ImagePath $Dest -Force

# Build prompt
$captionPart = if ($Caption) { "Use this caption: '$Caption'." } else { "Choose an appropriate caption based on the filename and context." }
$Prompt = "A new photo '$FileName' was just added to the images/ folder. Follow the Photo Workflow in CLAUDE.md: identify the correct section (miniatures, curacao, dnd, or projects) based on the filename, add a .photo-item, $captionPart Replace a placeholder if one exists. Commit and push to main."

# Call Claude Code CLI
Write-Host "→   Calling Claude to update the site..." -ForegroundColor Cyan
Set-Location $ProjectRoot
claude -p $Prompt

Write-Host ""
Write-Host "✅  Done — sinisternl.net will be live in ~60 seconds." -ForegroundColor Green
