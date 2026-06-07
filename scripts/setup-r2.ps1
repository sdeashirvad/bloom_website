# Bloom — Cloudflare R2 APK hosting setup
# Run from project root:  .\scripts\setup-r2.ps1

# npm writes warnings to stderr on Windows; avoid terminating on those
$PSNativeCommandUseErrorActionPreference = $false
$ErrorActionPreference = "Continue"

$BucketName = "bloom-downloads"
$ObjectKey  = "Bloom-Preview.apk"
$ApkPath    = "download\Bloom-Preview.apk"
$Redirects  = "_redirects"

Set-Location $PSScriptRoot\..

Write-Host ""
Write-Host "Bloom R2 Setup" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host ""

# --- Check APK exists ---
if (-not (Test-Path $ApkPath)) {
    Write-Host "ERROR: APK not found at $ApkPath" -ForegroundColor Red
    Write-Host "Place Bloom-Preview.apk in the download\ folder and run again."
    exit 1
}

$apkSize = (Get-Item $ApkPath).Length / 1MB
Write-Host "Found APK: $ApkPath ($([math]::Round($apkSize, 1)) MB)"

function Invoke-Wrangler {
    param([string[]]$WranglerArgs)
    $output = & npx wrangler @WranglerArgs 2>&1
    $code = $LASTEXITCODE
    $text = ($output | Out-String).Trim()
    return @{ Output = $text; ExitCode = $code }
}

# --- Check Cloudflare login ---
Write-Host ""
Write-Host "Checking Cloudflare authentication..."
$whoami = Invoke-Wrangler @("whoami")
if ($whoami.ExitCode -ne 0) {
    Write-Host "Not logged in. Opening browser for Cloudflare login..."
    $login = Invoke-Wrangler @("login")
    Write-Host $login.Output
    if ($login.ExitCode -ne 0) { exit 1 }
    $whoami = Invoke-Wrangler @("whoami")
}

Write-Host $whoami.Output
Write-Host ""

# --- Create bucket (ignore if already exists) ---
Write-Host "Creating R2 bucket '$BucketName'..."
$create = Invoke-Wrangler @("r2", "bucket", "create", $BucketName)
Write-Host $create.Output
if ($create.ExitCode -ne 0 -and $create.Output -notmatch "already exists") {
    if ($create.Output -match "10042") {
        Write-Host ""
        Write-Host "R2 is not enabled on your Cloudflare account yet." -ForegroundColor Red
        Write-Host "Enable it first (free, takes ~30 seconds):"
        Write-Host "  https://dash.cloudflare.com/?to=/:account/r2/overview"
        Write-Host "  Click 'Purchase R2' or 'Enable R2' (no payment required for free tier)"
        Write-Host "Then run this script again."
    }
    exit 1
}
Write-Host ""

# --- Upload APK ---
Write-Host "Uploading APK to R2 (this may take a minute for ~70 MB)..."
$upload = Invoke-Wrangler @(
    "r2", "object", "put", "$BucketName/$ObjectKey",
    "--file=$ApkPath",
    "--content-type=application/vnd.android.package-archive"
)
Write-Host $upload.Output
if ($upload.ExitCode -ne 0) { exit 1 }
Write-Host "Upload complete." -ForegroundColor Green
Write-Host ""

# --- Enable public r2.dev URL ---
Write-Host "Enabling public r2.dev URL for bucket..."
$enable = Invoke-Wrangler @("r2", "bucket", "dev-url", "enable", $BucketName, "--force")
Write-Host $enable.Output
if ($enable.ExitCode -ne 0) { exit 1 }
Write-Host ""

# --- Get public URL ---
Write-Host "Fetching public URL..."
$getUrl = Invoke-Wrangler @("r2", "bucket", "dev-url", "get", $BucketName)
$devUrlOutput = $getUrl.Output

# Parse domain from output (e.g. pub-abc123.r2.dev)
$domain = $null
if ($devUrlOutput -match '(pub-[a-z0-9]+\.r2\.dev)') {
    $domain = $Matches[1]
}

if (-not $domain) {
    Write-Host "Could not parse r2.dev domain from wrangler output:" -ForegroundColor Yellow
    Write-Host $devUrlOutput
    Write-Host ""
    Write-Host "Find your Public Development URL in:"
    Write-Host "  Cloudflare Dashboard -> R2 -> $BucketName -> Settings -> Public Development URL"
    Write-Host ""
    $domain = Read-Host "Paste the domain only (e.g. pub-abc123.r2.dev)"
}

$publicUrl = "https://$domain/$ObjectKey"
Write-Host ""
Write-Host "Public APK URL: $publicUrl" -ForegroundColor Green

# --- Update _redirects ---
$redirectLine = "/download   $publicUrl   302"
$redirectsContent = Get-Content $Redirects -Raw

if ($redirectsContent -match '/download\s+https?://[^\s]+\s+302') {
    $redirectsContent = $redirectsContent -replace '/download\s+https?://[^\s]+\s+302', $redirectLine
} else {
    $redirectsContent = $redirectsContent -replace '/download\s+[^\s]+\s+302', $redirectLine
}

Set-Content -Path $Redirects -Value $redirectsContent.TrimEnd() -NoNewline
Add-Content -Path $Redirects -Value ""

Write-Host ""
Write-Host "Updated ${Redirects}:" -ForegroundColor Green
Write-Host "  $redirectLine"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. git add _redirects .gitignore scripts/setup-r2.ps1 README.md"
Write-Host "  2. git commit and push to deploy Pages (APK stays in R2, not in repo)"
Write-Host "  3. Test: https://bloom.ashirvad.work/download"
Write-Host ""
Write-Host "Note: r2.dev URLs are rate-limited - fine for early preview." -ForegroundColor Yellow
Write-Host "      For production, connect a custom domain to the R2 bucket in Cloudflare Dashboard."
Write-Host ""
