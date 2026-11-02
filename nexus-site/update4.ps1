# update4.ps1 — Remove video+team section, blog section, fix Nexus text, add responsive logo CSS
param()
$ErrorActionPreference = 'Stop'

$pages = @(
    @{ src = "c:\Users\admin\Downloads\nexus-site\index.html"; logoPrefix = "images" },
    @{ src = "c:\Users\admin\Downloads\nexus-site\about-us\index.html"; logoPrefix = "../images" },
    @{ src = "c:\Users\admin\Downloads\nexus-site\services\index.html"; logoPrefix = "../images" },
    @{ src = "c:\Users\admin\Downloads\nexus-site\contact-us\index.html"; logoPrefix = "../images" },
    @{ src = "c:\Users\admin\Downloads\nexus-site\404-error\index.html"; logoPrefix = "../images" }
)

foreach ($page in $pages) {
    Write-Host "Processing: $($page.src)"
    $c = [System.IO.File]::ReadAllText($page.src, [System.Text.Encoding]::UTF8)

    # 1. ADD CSS
    $hideCss = '<style id="digisales-custom">
.elementor-element-e581e28 { display: none !important; }
.elementor-widget-jkit_post_list,.elementor-widget-jkit_post_block,.elementor-widget-jkit_post_featured { display: none !important; }
.digisales-header-logo { display: inline-block; max-width: 100%; line-height: 0; }
.digisales-header-logo img { max-height: 60px; width: auto; max-width: 200px; height: auto; display: block; }
.digisales-footer-logo { display: inline-block; max-width: 100%; line-height: 0; }
.digisales-footer-logo img { max-height: 55px; width: auto; max-width: 180px; height: auto; display: block; }
@media (max-width: 1024px) { .digisales-header-logo img { max-height: 50px; max-width: 170px; } }
@media (max-width: 767px) { .digisales-header-logo img { max-height: 42px; max-width: 145px; } .digisales-footer-logo img { max-height: 38px; max-width: 135px; } }
</style>'

    if ($c -notmatch 'digisales-custom') {
        $c = $c -replace '</head>', ($hideCss + '</head>')
    }

    # 2. FIX NEXUS TEXT
    $c = $c -replace 'c 2026 Nexus\. All rights reserved\.', '&copy; 2026 DigiSales Media. All rights reserved.'
    $c = $c -replace '&copy; 2026 Nexus\.', '&copy; 2026 DigiSales Media.'
    $c = $c -replace '>About Nexus<', '>About DigiSales Media<'
    $c = $c -replace 'Nexus started with a simple belief', 'DigiSales Media started with a simple belief'
    $c = $c -replace 'Nexus was founded', 'DigiSales Media was founded'
    $c = $c -replace 'team at Nexus', 'team at DigiSales Media'
    $c = $c -replace 'chose Nexus', 'chose DigiSales Media'
    $c = $c -replace 'working with Nexus', 'working with DigiSales Media'
    # Safe word-boundary Nexus replace (not in URLs)
    $c = $c -replace '([^a-zA-Z0-9/\-\.])Nexus([^a-zA-Z0-9/\-\.])', '$1DigiSales Media$2'

    # 3. RESTORE CDN URLs
    $c = $c -replace 'raddito\.net/DigiSales Media/', 'raddito.net/nexus/'

    # 4. RESPONSIVE LOGO WRAPPERS using .Replace() (no regex issues)
    $lp = $page.logoPrefix

    $headerLogoWithStyle = '<img width="415" height="100" src="' + $lp + '/logo-dark.png" style="max-height:60px;width:auto;" />'
    $headerLogoNew = '<span class="digisales-header-logo"><img src="' + $lp + '/logo-dark.png" alt="DigiSales Media" /></span>'
    $c = $c.Replace($headerLogoWithStyle, $headerLogoNew)

    $headerLogoPlain = '<img width="415" height="100" src="' + $lp + '/logo-dark.png" />'
    $c = $c.Replace($headerLogoPlain, $headerLogoNew)

    $footerLogoWithStyle = '<img width="415" height="100" src="' + $lp + '/logo-light.png" style="max-height:60px;width:auto;" />'
    $footerLogoNew = '<span class="digisales-footer-logo"><img src="' + $lp + '/logo-light.png" alt="DigiSales Media" /></span>'
    $c = $c.Replace($footerLogoWithStyle, $footerLogoNew)

    $footerLogoPlain = '<img width="415" height="100" src="' + $lp + '/logo-light.png" />'
    $c = $c.Replace($footerLogoPlain, $footerLogoNew)

    # 5. WRITE TEMP FILE
    $tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString() + '.html')
    [System.IO.File]::WriteAllText($tmp, $c, [System.Text.Encoding]::UTF8)
    Write-Host "COPY:$tmp|$($page.src)"
}
Write-Host "ALL_DONE"
