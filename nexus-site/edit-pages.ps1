# Script to edit all Nexus site HTML pages
# Tasks: Remove Portfolio/Pages nav items, fix internal links

$files = @(
    "C:\Users\admin\Downloads\nexus-site\index.html",
    "C:\Users\admin\Downloads\nexus-site\about-us\index.html",
    "C:\Users\admin\Downloads\nexus-site\services\index.html",
    "C:\Users\admin\Downloads\nexus-site\contact-us\index.html"
)

# Exact strings to remove (Portfolio and Pages nav items with their sub-menus)
$portfolioBlock = '<li id="menu-item-46" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-has-children menu-item-46"><a href="#">Portfolio</a>
<ul class="sub-menu">
	<li id="menu-item-39" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-39"><a href="https://preview.raddito.net/nexus/case-study/">Case study</a></li>
	<li id="menu-item-40" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-40"><a href="https://preview.raddito.net/nexus/case-study-details/">Case study Details</a></li>
</ul>
</li>'

$pagesBlock = '<li id="menu-item-47" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-has-children menu-item-47"><a href="#">Pages</a>
<ul class="sub-menu">
	<li id="menu-item-43" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-43"><a href="https://preview.raddito.net/nexus/team/">Team</a></li>
	<li id="menu-item-44" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-44"><a href="https://preview.raddito.net/nexus/testimonial/">Testimonial</a></li>
	<li id="menu-item-37" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-37"><a href="https://preview.raddito.net/nexus/blog/">Blog</a></li>
	<li id="menu-item-38" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-38"><a href="https://preview.raddito.net/nexus/blog-details/">Blog Details</a></li>
	<li id="menu-item-1004" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-1004"><a href="https://preview.raddito.net/nexus/404-error/">404 Error</a></li>
</ul>
</li>'

foreach ($file in $files) {
    Write-Host "Processing: $file"
    $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

    # ========================
    # B) Remove Portfolio nav item
    # ========================
    if ($content.Contains($portfolioBlock)) {
        $content = $content.Replace($portfolioBlock, '')
        Write-Host "  - Removed Portfolio nav"
    } else {
        Write-Host "  - Portfolio nav not found (exact), trying regex..."
        $content = [regex]::Replace($content, '(?s)<li id="menu-item-46"[^<]*<a[^>]*>Portfolio</a>\s*<ul class="sub-menu">.*?</ul>\s*</li>', '')
    }

    # ========================
    # B) Remove Pages nav item
    # ========================
    if ($content.Contains($pagesBlock)) {
        $content = $content.Replace($pagesBlock, '')
        Write-Host "  - Removed Pages nav"
    } else {
        Write-Host "  - Pages nav not found (exact), trying regex..."
        $content = [regex]::Replace($content, '(?s)<li id="menu-item-47"[^<]*<a[^>]*>Pages</a>\s*<ul class="sub-menu">.*?</ul>\s*</li>', '')
    }

    # ========================
    # D) Fix internal links - determine which page we're editing
    # ========================
    $isRoot = $file -match "nexus-site\\index\.html$"

    if ($isRoot) {
        # Root page: links are relative to nexus-site/
        $content = $content.Replace('href="https://preview.raddito.net/nexus/"', 'href="index.html"')
        $content = $content.Replace('href="https://preview.raddito.net/nexus/about-us/"', 'href="about-us/index.html"')
        $content = $content.Replace('href="https://preview.raddito.net/nexus/services/"', 'href="services/index.html"')
        $content = $content.Replace('href="https://preview.raddito.net/nexus/contact-us/"', 'href="contact-us/index.html"')
    } else {
        # Sub-pages: links are relative, going up one level
        $content = $content.Replace('href="https://preview.raddito.net/nexus/"', 'href="../index.html"')
        $content = $content.Replace('href="https://preview.raddito.net/nexus/about-us/"', 'href="../about-us/index.html"')
        $content = $content.Replace('href="https://preview.raddito.net/nexus/services/"', 'href="../services/index.html"')
        $content = $content.Replace('href="https://preview.raddito.net/nexus/contact-us/"', 'href="../contact-us/index.html"')
    }
    Write-Host "  - Fixed internal nav links"

    # Save the file
    [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Done: $file"
}

Write-Host ""
Write-Host "All files processed!"
