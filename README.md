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

Optional `_redirects` entry for APK download only (when hosting is configured).

### APK hosting (Cloudflare R2)

`Bloom-Preview.apk` is ~70 MB — too large for Cloudflare Pages (25 MB limit). The APK is hosted on **Cloudflare R2** instead. Pages redirects `/download` to the R2 public URL via `_redirects`.

#### One-time R2 setup

**Step 0 — Enable R2 on your Cloudflare account** (required once):

1. Open [Cloudflare R2 Overview](https://dash.cloudflare.com/?to=/:account/r2/overview)
2. Click **Purchase R2** or **Enable R2** (free tier, no card required for basic usage)
3. Wait until the R2 dashboard loads

**Step 1 — Run the setup script** from the project root in PowerShell:

```powershell
.\scripts\setup-r2.ps1
```

The script will:

1. Log you into Cloudflare (browser opens on first run)
2. Create R2 bucket `bloom-downloads`
3. Upload `download/Bloom-Preview.apk`
4. Enable the public `r2.dev` URL
5. Update `_redirects` with the real R2 URL

Then commit and push `_redirects` (the APK itself is **not** in git):

```powershell
git add _redirects .gitignore scripts/setup-r2.ps1
git commit -m "Point /download to R2-hosted APK"
git push origin main
```

#### Updating the APK later

```powershell
# Replace the local file, then re-upload only:
npx wrangler r2 object put bloom-downloads/Bloom-Preview.apk --file=download/Bloom-Preview.apk --content-type=application/vnd.android.package-archive
```

No Pages redeploy needed — the `/download` redirect URL stays the same.

#### Production note

`r2.dev` URLs are rate-limited (fine for early preview). For heavy traffic, connect a custom domain (e.g. `download.bloom.ashirvad.work`) to the R2 bucket in **Cloudflare Dashboard → R2 → bloom-downloads → Settings → Custom Domains**, then update `_redirects` accordingly.

---

## Early Preview APK

- **Local file:** `download/Bloom-Preview.apk` (gitignored, used for R2 upload)
- **Public URL:** `https://bloom.ashirvad.work/download` → redirects to R2
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
