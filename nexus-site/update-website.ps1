# ============================================================
# DigiSales Media - Full Website Update Script
# Updates all pages: index, about-us, contact-us, services, 404
# ============================================================

$siteRoot = "c:\Users\admin\Downloads\nexus-site"

# --- Company Details ---
$companyName     = "DigiSales Media"
$agencyType      = "360° Digital Marketing Agency"
$founded         = "2020"
$phone1          = "+91 99775 04949"
$phone1Raw       = "9977504949"
$phone2          = "+91 91834 91843"
$phone2Raw       = "9183491843"
$email           = "digisalesindia@gmail.com"
$address         = "CW-294, near Shalimar Bungalow Parks, Sukhliya, Indore, MP 452010"
$addressFull     = "CW-294, near Shalimar Bungalow Parks, Sukhliya, Indore, Madhya Pradesh 452010"
$whatsapp        = "https://wa.me/919977504949"
$mapLink         = "https://www.google.com/maps/@22.763333,75.8770042,16z"

# --- Logos (relative paths from each sub-page)  ---
$logoDarkRoot    = "images/logo-dark.png"    # homepage uses this
$logoLightRoot   = "images/logo-light.png"
$logoDarkSub     = "../images/logo-dark.png" # sub-pages use this
$logoLightSub    = "../images/logo-light.png"

# --- Pages to process ---
$pages = @(
    @{ path = "$siteRoot\index.html";         isRoot = $true  },
    @{ path = "$siteRoot\about-us\index.html";  isRoot = $false },
    @{ path = "$siteRoot\contact-us\index.html"; isRoot = $false },
    @{ path = "$siteRoot\services\index.html";  isRoot = $false },
    @{ path = "$siteRoot\404-error\index.html"; isRoot = $false }
)

# ---- Helper: Google icon SVG (replaces YouTube in footer social icons) ----
$googleIconBlock = '<a class="elementor-icon elementor-social-icon elementor-social-icon-google elementor-animation-float elementor-repeater-item-9e81aae" href="https://www.google.com/search?q=DigiSales+Media+Indore" target="_blank">
					<span class="elementor-screen-only">Google</span>
					<svg aria-hidden="true" class="e-font-icon-svg e-fab-google" viewBox="0 0 488 512" xmlns="http://www.w3.org/2000/svg"><path d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"/></svg>				</a>'

# ---- Contact info block for footer ----
$footerContactBlock = @"
		<div class="elementor-element e-con-full e-flex e-con e-child" style="flex-direction:column;gap:8px;padding:20px 0;min-width:220px;">
			<h5 style="color:#fff;margin:0 0 8px 0;font-size:16px;font-weight:600;border-bottom:1px solid rgba(255,255,255,0.2);padding-bottom:8px;">Contact Us</h5>
			<p style="color:rgba(255,255,255,0.8);margin:4px 0;font-size:13px;">&#128222; <a href="tel:$phone1Raw" style="color:rgba(255,255,255,0.8);text-decoration:none;">$phone1</a></p>
			<p style="color:rgba(255,255,255,0.8);margin:4px 0;font-size:13px;">&#128222; <a href="tel:$phone2Raw" style="color:rgba(255,255,255,0.8);text-decoration:none;">$phone2</a></p>
			<p style="color:rgba(255,255,255,0.8);margin:4px 0;font-size:13px;">&#128231; <a href="mailto:$email" style="color:rgba(255,255,255,0.8);text-decoration:none;">$email</a></p>
			<p style="color:rgba(255,255,255,0.8);margin:4px 0;font-size:13px;">&#128205; <a href="$mapLink" target="_blank" style="color:rgba(255,255,255,0.8);text-decoration:none;">$address</a></p>
			<p style="color:rgba(255,255,255,0.8);margin:4px 0;font-size:13px;">&#128172; <a href="$whatsapp" target="_blank" style="color:rgba(255,255,255,0.8);text-decoration:none;">WhatsApp: $phone1</a></p>
		</div>
"@

foreach ($page in $pages) {
    $filePath = $page.path
    if (-not (Test-Path $filePath)) {
        Write-Host "SKIP (not found): $filePath"
        continue
    }

    Write-Host "Processing: $filePath"
    $c = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $isRoot = $page.isRoot
    $logoDark  = if ($isRoot) { $logoDarkRoot  } else { $logoDarkSub  }
    $logoLight = if ($isRoot) { $logoLightRoot } else { $logoLightSub }

    # 1. PAGE TITLE
    $c = $c -replace 'About Us\s*&#8211;\s*Nexus\s*&#8211;\s*Social Media Marketing Agency', "About Us &#8211; DigiSales Media &#8211; Digital Marketing Agency"
    $c = $c -replace 'Contact Us\s*&#8211;\s*Nexus\s*&#8211;\s*Social Media Marketing Agency', "Contact Us &#8211; DigiSales Media &#8211; Digital Marketing Agency"
    $c = $c -replace 'Services\s*&#8211;\s*Nexus\s*&#8211;\s*Social Media Marketing Agency', "Services &#8211; DigiSales Media &#8211; Digital Marketing Agency"
    $c = $c -replace 'Nexus\s*&#8211;\s*Social Media Marketing Agency\s*&#8211;\s*Growing Brands Through Creative Social Strategies', "DigiSales Media &#8211; Digital Marketing Agency &#8211; Growing Brands Through Creative Digital Strategies"
    $c = $c -replace '404.*&#8211;\s*Nexus', "404 &#8211; DigiSales Media"

    # 2. HEADER LOGO (dark) - replace old CDN src + srcset with local file
    $c = $c -replace 'src="https://preview\.raddito\.net/nexus/wp-content/uploads/sites/281/2026/09/logo-dark\.png"[^>]*?(?:srcset="[^"]*?")?[^>]*?(?:sizes="[^"]*?")?', "src=`"$logoDark`" style=`"max-height:55px;width:auto;`""

    # 3. FOOTER LOGO (light) - replace old CDN src + srcset with local file
    $c = $c -replace 'src="https://preview\.raddito\.net/nexus/wp-content/uploads/sites/281/2026/09/logo-light\.png"[^>]*?(?:srcset="[^"]*?")?[^>]*?(?:sizes="[^"]*?")?', "src=`"$logoLight`" style=`"max-height:55px;width:auto;`""

    # 4. HERO BADGE TEXT
    $c = $c -replace 'SOCIAL MEDIA MARKETING AGENCY', 'DIGITAL MARKETING AGENCY'

    # 5. HERO / PAGE DESCRIPTIONS
    $c = $c -replace 'We help businesses create engaging content, run data-driven campaigns, and build a strong social media presence that drives real results\.', 'We help businesses generate leads, scale their brand with 360° digital marketing, AI automation, and data-driven strategies that drive real results.'
    $c = $c -replace 'Helping brands grow through creative social media strategies and digital experiences\.', "Helping brands grow through 360° digital marketing, AI automation, and data-driven strategies since $founded."

    # 6. CONTACT PAGE - old email
    $c = $c -replace 'hello@nexus\.com', $email
    $c = $c -replace 'info@nexus\.com', $email
    $c = $c -replace 'contact@nexus\.com', $email

    # 7. BOOK A CALL button → WhatsApp link
    $c = $c -replace 'href="" class="jkit-button-wrapper">Book a Call', "href=`"$whatsapp`" target=`"_blank`" class=`"jkit-button-wrapper`">Book a Call"

    # 8. ABOUT US page content
    $c = $c -replace 'We are a passionate team of social media experts', "We are a passionate team of digital marketing experts"
    $c = $c -replace 'social media marketing agency', "360° digital marketing agency"
    $c = $c -replace 'Social Media Marketing Agency', "Digital Marketing Agency"
    $c = $c -replace 'SOCIAL MEDIA MARKETING', 'DIGITAL MARKETING'
    $c = $c -replace 'Founded in \d{4}', "Founded in $founded"
    $c = $c -replace 'Since \d{4}', "Since $founded"

    # 9. SERVICES page footer services list
    $c = $c -replace '<span class="elementor-icon-list-text">Social Media Marketing</span>', '<span class="elementor-icon-list-text">Social Media Management</span>'
    $c = $c -replace '<span class="elementor-icon-list-text">Content Creation</span>', '<span class="elementor-icon-list-text">Lead Generation</span>'
    $c = $c -replace '<span class="elementor-icon-list-text">Brand Strategy</span>', '<span class="elementor-icon-list-text">SEO &amp; AI Search</span>'
    $c = $c -replace '<span class="elementor-icon-list-text">Analytics &amp; Reporting</span>', '<span class="elementor-icon-list-text">AI Automation &amp; CRM</span>'
    $c = $c -replace '<span class="elementor-icon-list-text">Social Media Consulting</span>', '<span class="elementor-icon-list-text">Website Development</span>'

    # 10. FOOTER - newsletter description
    $c = $c -replace 'Join our newsletter and get marketing tips, industry updates\.', 'Join our newsletter for digital marketing tips, AI insights, and industry updates.'

    # 11. YOUTUBE → GOOGLE social icon in footer
    $youtubeStart = $c.IndexOf('elementor-social-icon-youtube')
    if ($youtubeStart -gt 0) {
        $anchorStart = $c.LastIndexOf('<a class=', $youtubeStart)
        $anchorEnd   = $c.IndexOf('</a>', $anchorStart) + 4
        $c = $c.Substring(0, $anchorStart) + $googleIconBlock + $c.Substring($anchorEnd)
    }

    # 12. ADD CONTACT BLOCK IN FOOTER (before newsletter section)
    # Check if not already added
    if ($c -notmatch 'digisalesindia@gmail\.com' -and $c -match 'elementor-element-5b1a12a') {
        $c = $c -replace '		<div class="elementor-element elementor-element-5b1a12a', "$footerContactBlock`n		<div class=`"elementor-element elementor-element-5b1a12a`""
    }

    # 13. CONTACT PAGE - phone icon box text
    $c = $c -replace '(<h2 class="title">Call Us</h2><p class="icon-box-description">)[^<]*(</p>)', "`${1}$phone1 / $phone2`${2}"
    $c = $c -replace '(<h2 class="title">Email Us</h2><p class="icon-box-description">)[^<]*(</p>)', "`${1}$email`${2}"
    $c = $c -replace '(<h2 class="title">Our Location</h2><p class="icon-box-description">)[^<]*(</p>)', "`${1}$addressFull`${2}"
    $c = $c -replace '(<h2 class="title">WhatsApp</h2><p class="icon-box-description">)[^<]*(</p>)', "`${1}$phone1`${2}"

    # 14. SERVICES page menu fix - remove Services Details from submenu (in sub-pages)
    if (-not $isRoot) {
        $c = $c -replace '<li id="menu-item-45" class="menu-item menu-item-type-custom menu-item-object-custom[^"]*" menu-item-45"><a href="#">Services</a>\s*<ul class="sub-menu">\s*<li[^>]*><a href="[^"]*services[^"]*">Services</a></li>\s*<li[^>]*><a href="[^"]*services-details[^"]*">Services Details</a></li>\s*</ul>\s*</li>', '<li id="menu-item-45" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-45"><a href="../services/index.html">Services</a></li>'
    }

    # Write back
    $tmpPath = [System.IO.Path]::GetTempFileName() + ".html"
    [System.IO.File]::WriteAllText($tmpPath, $c, [System.Text.Encoding]::UTF8)
    Write-Host "  -> Saved temp: $tmpPath"

    # Store temp path in page object for later copy
    $page["tmp"] = $tmpPath
}

Write-Host ""
Write-Host "=== All pages processed. Ready to copy. ==="

# Output temp paths for copying
foreach ($page in $pages) {
    if ($page.ContainsKey("tmp")) {
        Write-Host "COPY:$($page.tmp)|$($page.path)"
    }
}

