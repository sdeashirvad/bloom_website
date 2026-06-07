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
├── 404.html                # Custom 404 page
├── robots.txt              # Crawler directives
├── sitemap.xml             # Search engine sitemap
├── _redirects              # Optional APK redirect only
├── styles/
│   └── main.css
├── assets/
│   └── images/
│       └── icon.png
├── scripts/
│   └── main.js
└── README.md
```

---

## Local Development (Windows)

No dependencies or build tools needed.

### Option 1 — Python (recommended)

```powershell
cd c:\Users\aashirvad\Documents\bloom_website
python -m http.server 8080
```

Open [http://localhost:8080](http://localhost:8080).

> **Note:** Folder-based routes work natively on Cloudflare Pages and with `python -m http.server`. Visit `/privacy/` or `/privacy` locally.

### Option 2 — npx serve (if Node.js is installed)

```powershell
npx serve .
```

---

## Deploy to Cloudflare Pages

### Prerequisites

- A [Cloudflare](https://dash.cloudflare.com) account
- Repository pushed to GitHub (`github.com/sdeashirvad/bloom_website`)

### Steps

1. Push code to GitHub
2. Cloudflare Dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
3. Select the `bloom_website` repository
4. Build settings:
   - **Framework preset:** None
   - **Build command:** *(leave empty)*
   - **Build output directory:** `/`
5. Deploy, then add custom domain `bloom.ashirvad.work`

### Routing

Pages are served via folder-based routes — no rewrite rules needed:

| URL | File |
|-----|------|
| `/` | `index.html` |
| `/privacy` | `privacy/index.html` |
| `/support` | `support/index.html` |
| `/download` | GitHub Release asset (302 via `_redirects`) |

### APK hosting (GitHub Releases)

`Bloom-Preview.apk` (~70 MB) is too large for Cloudflare Pages (25 MB limit). It is hosted as a [GitHub Release asset](https://github.com/sdeashirvad/bloom_website/releases). Users tap **Try Bloom Early** → `bloom.ashirvad.work/download` → silent 302 → direct file download. No GitHub UI, no redirect loops.

Current `_redirects` entries (covers `/download`, `/download/`, and any subpath):

```
/download      https://github.com/.../Bloom-Preview.apk   302
/download/     https://github.com/.../Bloom-Preview.apk   302
/download/*    https://github.com/.../Bloom-Preview.apk   302
```

`download/index.html` is a local-dev fallback only — Cloudflare `_redirects` takes priority and triggers an immediate file download. **Do not** place `Bloom-Preview.apk` in `download/` (causes directory listings).

#### Updating the APK later

1. Create a new GitHub Release (or replace the asset on `v1.bloom_preview`)
2. Update the URL in `_redirects` if the tag changes
3. Push — the public link `bloom.ashirvad.work/download` stays the same for users

---

## Early Preview APK

- **Hosted on:** GitHub Releases (`v1.bloom_preview`)
- **User-facing URL:** `https://bloom.ashirvad.work/download`
- **Homepage CTA:** "Try Bloom Early"

---

## Replacing the Play Store CTA

When Bloom is live on Google Play, update `index.html`:

```html
<!-- Replace: -->
<span class="btn-pill btn-pill--disabled btn-play-store" role="status">Coming soon to Google Play</span>

<!-- With: -->
<a href="https://play.google.com/store/apps/details?id=YOUR_APP_ID" class="btn-pill btn-play-store">
  Get it on Google Play
</a>
```

---

## SEO

- Canonical URLs, OpenGraph, and Twitter cards on all main pages
- JSON-LD `SoftwareApplication` schema on homepage (associates Bloom with SDEAshirvad Labs and Ashirvad Kumar Pandey)
- `robots.txt` and `sitemap.xml` at project root
- OG image: `assets/images/icon.png`

---

## Design Notes

- **Fonts:** Cormorant Garamond (headings) and Inter (body) via Google Fonts
- **Colors:** Warm cream background, dusty rose accents, muted sage trust indicators
- **Motion:** Subtle fade-in on scroll; disabled when `prefers-reduced-motion` is set
- **No analytics:** The website contains no tracking scripts
