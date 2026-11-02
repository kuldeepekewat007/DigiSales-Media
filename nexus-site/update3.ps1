# ============================================================
# DigiSales Media - Update #3
# - Logo in header + footer (all pages, responsive)
# - Replace all visible "Nexus" text with "DigiSales Media"
# - "About Nexus" → "About DigiSales Media"
# - Copyright "Nexus" → "DigiSales Media"
# - Testimonials "Nexus" → "DigiSales Media"
# - Add responsive CSS for logo
# ============================================================

$siteRoot = "c:\Users\admin\Downloads\nexus-site"

$pages = @(
    @{ path="$siteRoot\index.html";            isRoot=$true;  homeHref="index.html";       logoPrefix="" },
    @{ path="$siteRoot\about-us\index.html";   isRoot=$false; homeHref="../index.html";    logoPrefix="../" },
    @{ path="$siteRoot\services\index.html";   isRoot=$false; homeHref="../index.html";    logoPrefix="../" },
    @{ path="$siteRoot\contact-us\index.html"; isRoot=$false; homeHref="../index.html";    logoPrefix="../" },
    @{ path="$siteRoot\404-error\index.html";  isRoot=$false; homeHref="../index.html";    logoPrefix="../" }
)

# Responsive CSS to inject into <head> of every page
$responsiveCSS = @'
<style id="digisales-logo-responsive">
/* DigiSales Logo - Fully Responsive */
.digisales-header-logo img,
.digisales-footer-logo img {
    display: block !important;
    width: auto !important;
    max-width: 100% !important;
    height: auto !important;
    max-height: 55px !important;
    object-fit: contain !important;
}
@media (max-width: 767px) {
    .digisales-header-logo img { max-height: 40px !important; }
    .digisales-footer-logo img { max-height: 45px !important; }
}
@media (min-width: 768px) and (max-width: 1024px) {
    .digisales-header-logo img { max-height: 48px !important; }
    .digisales-footer-logo img { max-height: 50px !important; }
}
</style>
'@

$tmpFiles = @{}

foreach ($page in $pages) {
    $fp     = $page.path
    $prefix = $page.logoPrefix
    if (-not (Test-Path $fp)) { Write-Host "SKIP: $fp"; continue }

    Write-Host "Processing: $fp"
    $c = [System.IO.File]::ReadAllText($fp, [System.Text.Encoding]::UTF8)

    # ----------------------------------------------------------
    # 1. INJECT RESPONSIVE CSS into <head> (if not already there)
    # ----------------------------------------------------------
    if ($c -notmatch 'digisales-logo-responsive') {
        $c = $c -replace '</head>', "$responsiveCSS`n</head>"
        Write-Host "  [OK] Responsive CSS injected"
    }

    # ----------------------------------------------------------
    # 2. HEADER LOGO — Replace old img tag with properly wrapped responsive logo
    # ----------------------------------------------------------
    # Pattern: any img tag currently showing logo-dark.png in header area
    $headerLogoNew = "<span class=`"digisales-header-logo`"><img src=`"$($prefix)images/logo-dark.png`" alt=`"DigiSales Media`" /></span>"

    # Replace the existing header logo img (with its style attribute from previous update)
    $c = $c -replace '<img width="415" height="100" src="[^"]*logo-dark\.png" style="[^"]*" />', $headerLogoNew

    # Also catch any remaining CDN logo-dark patterns
    $c = $c -replace '<img[^>]*src="https://preview\.raddito\.net/nexus/wp-content/uploads/sites/281/2026/09/logo-dark\.png"[^>]*/>', $headerLogoNew

    Write-Host "  [OK] Header logo updated"

    # ----------------------------------------------------------
    # 3. FOOTER LOGO — Replace with responsive DigiSales light logo
    # ----------------------------------------------------------
    $footerLogoNew = "<span class=`"digisales-footer-logo`"><img src=`"$($prefix)images/logo-light.png`" alt=`"DigiSales Media`" /></span>"

    $c = $c -replace '<img width="415" height="100" src="[^"]*logo-light\.png" style="[^"]*" />', $footerLogoNew
    $c = $c -replace '<img[^>]*src="https://preview\.raddito\.net/nexus/wp-content/uploads/sites/281/2026/09/logo-light\.png"[^>]*/>', $footerLogoNew

    Write-Host "  [OK] Footer logo updated"

    # ----------------------------------------------------------
    # 4. REPLACE ALL VISIBLE "Nexus" TEXT (not in URLs/attributes)
    # ----------------------------------------------------------

    # Copyright line
    $c = $c -replace 'c 2026 Nexus\. All rights reserved\.', '&copy; 2026 DigiSales Media. All rights reserved.'
    $c = $c -replace '© 2026 Nexus\.', '&copy; 2026 DigiSales Media.'

    # Page headings
    $c = $c -replace '<h1[^>]*>About Nexus</h1>', '<h1 class="elementor-heading-title elementor-size-default">About DigiSales Media</h1>'
    $c = $c -replace '>About Nexus<', '>About DigiSales Media<'

    # Testimonials / body text (case-sensitive "Nexus" word in content)
    $c = $c -replace 'Nexus completely changed', 'DigiSales Media completely changed'
    $c = $c -replace 'Working with Nexus made', 'Working with DigiSales Media made'
    $c = $c -replace 'The Nexus team', 'The DigiSales Media team'
    $c = $c -replace 'Nexus started with a simple belief', 'DigiSales Media started with a simple belief'
    $c = $c -replace 'Nexus started with', 'DigiSales Media started with'
    $c = $c -replace 'helping brands turn ideas', 'helping brands turn digital ideas'

    # Any remaining standalone Nexus in visible text (NOT in URLs/JS/CSS)
    # Replace >Nexus< pattern (between HTML tags)
    $c = $c -replace '>Nexus<', '>DigiSales Media<'
    $c = $c -replace '>Nexus\b', '>DigiSales Media'

    Write-Host "  [OK] Nexus text replaced"

    # ----------------------------------------------------------
    # 5. SAVE TO TEMP
    # ----------------------------------------------------------
    $tmp = [System.IO.Path]::GetTempFileName() + ".html"
    [System.IO.File]::WriteAllText($tmp, $c, [System.Text.Encoding]::UTF8)
    $tmpFiles[$fp] = $tmp
    Write-Host "  -> Temp: $tmp"
}

Write-Host ""
Write-Host "=== All pages processed ==="
foreach ($kv in $tmpFiles.GetEnumerator()) {
    Write-Host "COPY:$($kv.Value)|$($kv.Key)"
}

