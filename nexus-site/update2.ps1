# ============================================================
# DigiSales Media - Website Update #2
# Changes: Remove Stay Update, fix Services menu, reorder footer,
#          remove footer description, fix Services Details in sub-pages
# ============================================================

$siteRoot = "c:\Users\admin\Downloads\nexus-site"
$pages = @(
    @{ path = "$siteRoot\index.html";               isRoot = $true  },
    @{ path = "$siteRoot\about-us\index.html";      isRoot = $false },
    @{ path = "$siteRoot\services\index.html";      isRoot = $false },
    @{ path = "$siteRoot\contact-us\index.html";    isRoot = $false },
    @{ path = "$siteRoot\404-error\index.html";     isRoot = $false }
)

$tmpFiles = @{}

foreach ($page in $pages) {
    $fp = $page.path
    if (-not (Test-Path $fp)) { Write-Host "SKIP: $fp"; continue }

    Write-Host "Processing: $fp"
    $c = [System.IO.File]::ReadAllText($fp, [System.Text.Encoding]::UTF8)
    $isRoot = $page.isRoot

    # -------------------------------------------------------
    # 1. REMOVE "Stay Update" newsletter section (5b1a12a container)
    #    It ends just before </div></div></div></div> before footer or next e-parent
    # -------------------------------------------------------
    $newsMarker = '		<div class="elementor-element elementor-element-5b1a12a'
    $newsIdx = $c.IndexOf($newsMarker)
    if ($newsIdx -ge 0) {
        # Find the closing </div> that closes this e-child container
        # The 5b1a12a div is an e-child, it ends with </div>\n\t\t</div>\n then sibling or parent closes
        # We need to find the matching closing tag - count depth
        $depth = 0
        $i = $newsIdx
        $endIdx = -1
        while ($i -lt $c.Length - 4) {
            if ($c.Substring($i, [Math]::Min(4, $c.Length - $i)) -eq '<div') {
                $depth++
                $i += 4
            } elseif ($c.Substring($i, [Math]::Min(6, $c.Length - $i)) -eq '</div>') {
                $depth--
                if ($depth -eq 0) {
                    $endIdx = $i + 6
                    break
                }
                $i += 6
            } else {
                $i++
            }
        }
        if ($endIdx -gt 0) {
            $c = $c.Substring(0, $newsIdx) + $c.Substring($endIdx)
            Write-Host "  [OK] Stay Update section removed"
        } else {
            Write-Host "  [WARN] Could not find Stay Update closing tag"
        }
    } else {
        Write-Host "  [--] Stay Update section not found (already removed?)"
    }

    # -------------------------------------------------------
    # 2. REMOVE footer description text "Helping brands grow..."
    # -------------------------------------------------------
    # Remove the entire text-editor widget div that contains this text
    $helpingPattern = 'Helping brands grow through 360'
    $helpingIdx = $c.IndexOf($helpingPattern)
    if ($helpingIdx -ge 0) {
        # Find the parent widget div start
        $widgetStart = $c.LastIndexOf('		<div class="elementor-element', $helpingIdx)
        # Find its closing </div>
        $depth = 0
        $i = $widgetStart
        $endIdx = -1
        while ($i -lt $c.Length - 4) {
            if ($c.Substring($i, [Math]::Min(4, $c.Length - $i)) -eq '<div') {
                $depth++
                $i += 4
            } elseif ($c.Substring($i, [Math]::Min(6, $c.Length - $i)) -eq '</div>') {
                $depth--
                if ($depth -eq 0) {
                    $endIdx = $i + 6
                    break
                }
                $i += 6
            } else {
                $i++
            }
        }
        if ($endIdx -gt 0) {
            $c = $c.Substring(0, $widgetStart) + $c.Substring($endIdx)
            Write-Host "  [OK] Footer description removed"
        }
    } else {
        Write-Host "  [--] Footer description not found"
    }

    # Also handle the older version of this text
    $c = $c -replace '\s*Helping brands grow through creative social media strategies and digital experiences\.\s*', ' '

    # -------------------------------------------------------
    # 3. REORDER FOOTER: Move Contact Us block ABOVE social icons
    #    Contact block has class containing "digisalesindia" or "e-con-full e-flex e-con e-child" with contact info
    #    Social icons widget id = 5487468
    # -------------------------------------------------------
    $socialMarker = '		<div class="elementor-element elementor-element-5487468'
    $contactMarker = '		<div class="elementor-element e-con-full e-flex e-con e-child" style="flex-direction:column'

    $socialIdx  = $c.IndexOf($socialMarker)
    $contactIdx = $c.IndexOf($contactMarker)

    if ($socialIdx -ge 0 -and $contactIdx -ge 0 -and $contactIdx -gt $socialIdx) {
        # Contact block is AFTER social icons — move it BEFORE social icons
        # Extract contact block
        $depth = 0
        $i = $contactIdx
        $contactEnd = -1
        while ($i -lt $c.Length - 4) {
            if ($c.Substring($i, [Math]::Min(4, $c.Length - $i)) -eq '<div') {
                $depth++
                $i += 4
            } elseif ($c.Substring($i, [Math]::Min(6, $c.Length - $i)) -eq '</div>') {
                $depth--
                if ($depth -eq 0) {
                    $contactEnd = $i + 6
                    break
                }
                $i += 6
            } else {
                $i++
            }
        }
        if ($contactEnd -gt 0) {
            $contactBlock = $c.Substring($contactIdx, $contactEnd - $contactIdx)
            # Remove from original position
            $cWithout = $c.Substring(0, $contactIdx) + $c.Substring($contactEnd)
            # Find social icons position again (it may have shifted)
            $newSocialIdx = $cWithout.IndexOf($socialMarker)
            if ($newSocialIdx -ge 0) {
                $c = $cWithout.Substring(0, $newSocialIdx) + $contactBlock + "`n" + $cWithout.Substring($newSocialIdx)
                Write-Host "  [OK] Contact block moved above social icons"
            }
        }
    } elseif ($socialIdx -ge 0 -and $contactIdx -ge 0 -and $contactIdx -lt $socialIdx) {
        Write-Host "  [--] Contact block already above social icons"
    } else {
        Write-Host "  [--] Contact block or social icons not found on this page"
    }

    # -------------------------------------------------------
    # 4. FIX SERVICES MENU — All pages (root & sub-pages)
    #    Remove dropdown submenu, make Services a single direct link
    # -------------------------------------------------------

    # ROOT page pattern (index.html)
    $c = $c -replace '(?s)<li id="menu-item-45" class="menu-item[^"]*menu-item-45"><a href="#">Services</a>\s*<ul class="sub-menu">\s*<li[^>]*><a href="services/index\.html">Services</a></li>\s*<li[^>]*><a href="[^"]*services-details[^"]*">Services Details</a></li>\s*</ul>\s*</li>', '<li id="menu-item-45" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-45"><a href="services/index.html">Services</a></li>'

    # SUB-PAGE pattern (about-us, services, contact-us have ../services/)
    $c = $c -replace '(?s)<li id="menu-item-45" class="menu-item[^"]*menu-item-45"><a href="#">Services</a>\s*<ul class="sub-menu">\s*<li[^>]*><a href="[^"]*services[^"]*">Services</a></li>\s*<li[^>]*><a href="[^"]*services-details[^"]*">Services Details</a></li>\s*</ul>\s*</li>', '<li id="menu-item-45" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-45"><a href="../services/index.html">Services</a></li>'

    Write-Host "  [OK] Services menu fixed"

    # -------------------------------------------------------
    # 5. SAVE TO TEMP
    # -------------------------------------------------------
    $tmp = [System.IO.Path]::GetTempFileName() + ".html"
    [System.IO.File]::WriteAllText($tmp, $c, [System.Text.Encoding]::UTF8)
    $tmpFiles[$fp] = $tmp
    Write-Host "  -> Temp: $tmp"
}

Write-Host ""
Write-Host "=== Processing complete ==="
foreach ($kv in $tmpFiles.GetEnumerator()) {
    Write-Host "COPY:$($kv.Value)|$($kv.Key)"
}

