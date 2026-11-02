# Replace team member images in about-us
$fullPath = "c:\Users\admin\Downloads\nexus-site\about-us\index.html"
$c = [System.IO.File]::ReadAllText($fullPath)

# Image files are: team 1.png, team 2.png, team 3.png, team 4.png, team 5.png
# URL encode spaces: "team 1.png" -> "team%201.png"
# Path from about-us: ../images/team%201.png

# Find all img tags with Team-1-X.webp pattern and their positions in order
$pattern = [regex]'(<img[^>]+src="https://preview\.raddito\.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-)(\d)(\.webp"[^>]*/\s*>)'
$matches = [regex]::Matches($c, '<img loading="lazy" decoding="async" width="300" height="300" src="https://preview\.raddito\.net[^"]*Team-1-\d[^"]*"[^>]*/>')

Write-Host "Found $($matches.Count) team img tags"

# Map: appearance order -> local file
# Order in HTML: Team-1-1 (member 1), Team-1-2 (member 2), Team-1-3 (member 3)
# We have 5 local files: team 1..5
# Assign: Team-1-1 -> team 1, Team-1-2 -> team 2, Team-1-3 -> team 3
# For 4th and 5th members we need to find their img tags separately

$localImages = @{
    "Team-1-1" = "../images/team%201.png"
    "Team-1-2" = "../images/team%202.png"
    "Team-1-3" = "../images/team%203.png"
}

# Replace Team-1-1 block (all CDN refs for this member)
$old1_src  = 'src="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-1.webp"'
$old1_url  = 'url="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-1.webp"'
$old1_srcset = 'srcset="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-1.webp 300w, https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-1-150x150.webp 150w"'
$new1_src  = 'src="../images/team%201.png"'
$new1_url  = 'url="../images/team%201.png"'
$new1_srcset = 'srcset="../images/team%201.png 300w"'

$c = $c.Replace($old1_src, $new1_src).Replace($old1_url, $new1_url).Replace($old1_srcset, $new1_srcset)
Write-Host "Team-1-1 replaced"

# Replace Team-1-2
$old2_src  = 'src="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-2.webp"'
$old2_url  = 'url="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-2.webp"'
$old2_srcset = 'srcset="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-2.webp 300w, https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-2-150x150.webp 150w"'
$new2_src  = 'src="../images/team%202.png"'
$new2_url  = 'url="../images/team%202.png"'
$new2_srcset = 'srcset="../images/team%202.png 300w"'

$c = $c.Replace($old2_src, $new2_src).Replace($old2_url, $new2_url).Replace($old2_srcset, $new2_srcset)
Write-Host "Team-1-2 replaced"

# Replace Team-1-3
$old3_src  = 'src="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-3.webp"'
$old3_url  = 'url="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-3.webp"'
$old3_srcset = 'srcset="https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-3.webp 300w, https://preview.raddito.net/nexus/wp-content/uploads/sites/281/2026/09/Team-1-3-150x150.webp 150w"'
$new3_src  = 'src="../images/team%203.png"'
$new3_url  = 'url="../images/team%203.png"'
$new3_srcset = 'srcset="../images/team%203.png 300w"'

$c = $c.Replace($old3_src, $new3_src).Replace($old3_url, $new3_url).Replace($old3_srcset, $new3_srcset)
Write-Host "Team-1-3 replaced"

# Check if 4th and 5th members use different CDN images
$remaining = [regex]::Matches($c, 'Team-1-\d')
Write-Host "Remaining Team-1-X refs: $($remaining.Count)"
foreach ($r in $remaining) { Write-Host "  $($r.Value) at $($r.Index)" }

# Write temp
$tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString() + ".html")
[System.IO.File]::WriteAllText($tmp, $c, [System.Text.Encoding]::UTF8)
Write-Host "TEMP: $tmp"

