# SinisterNL.github.io — Claude Code Instructions

## Deployment
- **Host**: GitHub Pages → live at `sinisternl.net` (CNAME)
- **Branch**: push to `main` to deploy. No build step needed — static HTML.
- **Deploy command**: `git add <files> && git commit -m "..." && git push -u origin main`
- GitHub Pages auto-deploys within ~60 seconds of push.
- Do NOT use `wrangler`, `npm run build`, or any other build tool — this is plain HTML/CSS/JS.

## Stack
- Pure HTML + CSS + JS. No framework, no bundler.
- `index.html` — main personal site
- `boodschappen.html` — grocery price tracker (Chart.js)
- `images/` — all photos (jpg/png)
- `CNAME` — contains `sinisternl.net`

## Design System
Fonts (loaded from Google Fonts):
- **Fraunces** — display/headings, always italic for titles
- **Syne** — body, nav, labels, UI text

CSS variables (defined in `:root` of each file):
- `--ink: #07101c` — page background
- `--deep: #0d1e30` — card/section background
- `--layer: #162a40` — raised elements
- `--terra: #c8733a` — primary accent (terracotta)
- `--terra2: #e08d50` — lighter terracotta
- `--teal: #17b8ac` — secondary accent (Caribbean teal)
- `--cream: #ede8de` — primary text
- `--fog: #7d94ab` — muted text
- `--border: rgba(200,115,58,0.14)` — subtle borders

Rules:
- Section labels/tags: `--teal`
- Buttons, hover accents, dividers: `--terra`
- Body text: `--fog`; headings: `--cream`
- CSS grain overlay on `body::after` (SVG feTurbulence, opacity 0.04)
- Reveal animations: `cubic-bezier(0.16,1,0.3,1)` spring easing

## Photo Workflow (drop a photo → site updated)
When the user shares/drops a photo and says to add it to the site:

1. **Save the file** to `images/` with a short descriptive name (e.g. `paints.jpg`)
2. **Identify the section** from context (miniatures, curacao, dnd, etc.)
3. **Add a `.photo-item`** in the correct section of `index.html`:
   ```html
   <div class="photo-item">
     <img src="images/filename.jpg" alt="Description" loading="lazy" />
     <div class="photo-caption">Caption text</div>
   </div>
   ```
4. **Remove a placeholder** `<div class="photo-placeholder">` if replacing one
5. **Commit and push** to main — site is live in ~60 seconds

The photo hover background effect is active: hovering any `.photo-item img`
shows that image full-screen at 50% opacity. Grid photos stay at z-index: 1
(foreground); `#photo-bg` sits at z-index: 0 (background).

## Automated Photo Workflow
Two ways to trigger this automatically (no manual HTML editing needed):

### Option A — Drag & drop onto script (Windows, one-time setup)
1. Open `C:\Sites\sinisternl\` in Explorer
2. Drag any photo onto `scripts\add-photo.bat`
3. Claude Code runs headlessly, updates the site, and pushes — done.

Optional caption: `.\scripts\add-photo.ps1 "photo.jpg" "My caption here"`

### Option B — File watcher (always-on)
Run once in a terminal, then leave it running:
```
cd C:\Sites\sinisternl
python scripts\watch.py
```
Drop any image into the `incoming/` folder — watcher detects it,
moves it to `images/`, calls Claude, site is live in ~60 seconds.

### Section detection logic (used by both options)
Infer section from filename keywords:
- `paint`, `mini`, `warhammer`, `model` → `#miniatures`
- `beach`, `curacao`, `coast`, `food`, `island` → `#curacao`
- `dnd`, `dungeon`, `dragon` → `#dnd`
- Default / unclear → ask or use `#miniatures`

## Sections in index.html
- `#hero` — full-screen beach photo header
- `#curacao` — island life photos (beach.jpg, coastline.jpg, food.jpg)
- `#miniatures` — miniature painting photos (currently placeholders)
- `#projects` — project cards (Boodschappen Prijsgrafiek, etc.)
- `#dnd` — D&D text adventure link

## Git Branch Convention
- `main` → production (GitHub Pages serves this)
- Feature branches: `claude/<description>` — merge to main when done

## Don'ts
- Don't add frameworks, bundlers, or build steps
- Don't use Inter, Roboto, Arial, or system fonts
- Don't change the color system without updating both `index.html` and `boodschappen.html`
- Don't push to branches other than `main` without asking
