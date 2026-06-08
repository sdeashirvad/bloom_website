# Bloom Website

A calm, minimal static website for [Bloom](https://bloom.ashirvad.work) — a quiet pregnancy companion.

Built with plain HTML, CSS, and a tiny bit of vanilla JavaScript. No build step required.

Created by [SDEAshirvad Labs](https://ashirvad.work).

---

## Project Structure

```
bloom_website/
├── index.html              # Homepage (/)
├── privacy/
│   └── index.html          # Privacy policy (/privacy)
├── support/
│   └── index.html          # Support + FAQ (/support)
├── download/
│   └── index.html          # Early APK download UX (/download)
├── 404.html                # Custom 404 page
├── robots.txt              # Crawler directives
├── sitemap.xml             # Search engine sitemap
├── styles/
│   └── main.css
├── assets/
│   └── images/             # Screenshots, icon, feature-graphic
├── scripts/
│   ├── main.js             # Scroll fade-in
│   └── carousel.js         # Screenshot carousel + lightbox
└── README.md
```

---

## Local Development (Windows)

```powershell
cd c:\Users\aashirvad\Documents\bloom_website
python -m http.server 8080
```

Open [http://localhost:8080](http://localhost:8080).

---

## Deploy to Cloudflare Pages

1. Push code to GitHub (`github.com/sdeashirvad/bloom_website`)
2. Cloudflare Dashboard → **Workers & Pages** → Connect to Git
3. Build settings: **None**, output directory `/`
4. Add custom domain `bloom.ashirvad.work`

### Routing

| URL | File |
|-----|------|
| `/` | `index.html` |
| `/privacy` | `privacy/index.html` |
| `/support` | `support/index.html` |
| `/download` | `download/index.html` |

No `_redirects` file needed for page routes.

---

## Screenshot Carousel

The homepage hero displays 7 app screenshots in a device-frame carousel with prev/next controls and dot indicators. Click any screenshot to view it larger; click away or press Escape to close.

Images live in `assets/images/`: `homepage.png`, `journal.png`, `this_week.png`, `memories.png`, `memory_book.png`, `book.png`, `privacy.png`.

---

## Early Preview APK

APK is hosted on [GitHub Releases](https://github.com/sdeashirvad/bloom_website/releases) (`v1.bloom_preview`).

**Flow:** User taps **Try Bloom Early** → `/download` → calm confirmation page → APK download triggered → auto-return to homepage after 2 seconds.

To update the APK URL, edit `download/index.html` (search for `v1.bloom_preview`).

**Do not** place `Bloom-Preview.apk` in the `download/` folder — it causes directory listings and bypasses the download UX.

---

## SEO and Google Search Console

- `sitemap.xml` and `robots.txt` at project root
- Canonical domain: `https://bloom.ashirvad.work`
- Social previews use `assets/images/feature-graphic.png`
- Favicon uses `assets/images/icon.png`

### Submit sitemap to Google Search Console

1. Add property: `https://bloom.ashirvad.work` (URL prefix, not `http://`)
2. Verify ownership (DNS or HTML tag)
3. Submit: `https://bloom.ashirvad.work/sitemap.xml`

### If GSC says "Sitemap could not be read"

Verify the file is live:

```powershell
curl -I https://bloom.ashirvad.work/sitemap.xml
```

Expected: `HTTP 200` and XML content starting with `<?xml`.

Common fixes:
- Ensure `sitemap.xml` is committed at repo root and deployed
- GSC property URL must match exactly (`https://bloom.ashirvad.work`)
- Wait for Cloudflare SSL to be Active before resubmitting
- Do not add `_redirects` rules that catch `sitemap.xml`

---

## Design Notes

- **Fonts:** Cormorant Garamond (headings) and Inter (body) via Google Fonts
- **Colors:** Warm cream background, dusty rose accents, muted sage trust indicators
- **Motion:** Subtle fade-in on scroll; carousel has no autoplay
- **No analytics:** The website contains no tracking scripts
