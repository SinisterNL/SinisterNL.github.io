# SinisterNL — Claude Code Instructions

## Site structure
- Root: `C:\Sites\sinisternl\`
- Images folder: `C:\Sites\sinisternl\images\`
- Main page: `C:\Sites\sinisternl\index.html`
- D&D page: `C:\Sites\sinisternl\dnd.html`
- Deployed via Cloudflare Workers (`wrangler.toml`)

## Photo upload workflow

When the user drops a photo into the chat:

1. **Identify the section** by looking at the image:
   - 🏝️ **Curaçao** — beaches, coastline, food, drinks, island life, outdoor scenes on the island
   - 🎵 **Music** — Linkin Park, concerts, merch, vinyl, CDs, band memorabilia
   - 🖌️ **Miniatures** — Warhammer figures, paints, brushes, Army Painter, hobby desk
   - 💀 **Tattoos** — tattoo photos, ink, blackwork, gothic, sleeve progress
   - 🎲 **D&D** — dice, character sheets, tabletop RPG items

2. **Ask for a caption** if the user hasn't provided one. Keep it short (3–6 words).

3. **Copy the image** to `C:\Sites\sinisternl\images\` with a short descriptive filename (e.g. `amstel.jpg`, `miniatures2.jpg`). Use PowerShell:
   ```powershell
   Copy-Item 'SOURCE_PATH' -Destination 'C:\Sites\sinisternl\images\FILENAME.jpg'
   ```

4. **Edit `index.html`** — replace the next available `photo-placeholder` in the correct section with:
   ```html
   <div class="photo-item">
     <img src="images/FILENAME.jpg" alt="CAPTION" loading="lazy" />
     <div class="photo-caption">CAPTION</div>
   </div>
   ```
   If no placeholder exists in the section, add a new `photo-item` to the grid.

5. **Deploy** automatically after saving index.html:
   ```powershell
   cd C:\Sites\sinisternl; wrangler deploy
   ```
   Wait for the output to confirm deployment. It will show a URL like `sinisternl.USERNAME.workers.dev`.

6. **Confirm** to the user: which section, filename used, caption applied, and that the site is live.

## Section IDs in index.html
- `#curacao` — Curaçao photo grid (currently: beach.jpg wide, coastline.jpg, food.jpg, amstel.jpg)
- `#music` — Music section (1 tall placeholder remaining)
- `#miniatures` — Miniatures grid (miniatures1.jpg filled, 2 placeholders remaining)
- `#tattoos` — NOT in current index.html (exists in backup). Restore from `index_html.backup` if needed.
- `#dnd` — D&D section, links to dnd.html (no photo grid)

## Deployment
Always deploy after any change using:
```powershell
cd C:\Sites\sinisternl; wrangler deploy
```
If wrangler is not found, remind the user to run `npm install -g wrangler` first.

## Design tokens (for any HTML edits)
- Background navy: `#0B1622`
- Gold accent: `#C4A45A`
- Fonts: `Cormorant Garamond` (headings), `DM Sans` (body)
