$baseUrl = "https://preview.raddito.net/nexus"
$outDir = "C:\Users\admin\Downloads\nexus-site"

# Pages to download
$pages = @(
    @{url="$baseUrl/"; file="index.html"},
    @{url="$baseUrl/about-us/"; file="about-us\index.html"},
    @{url="$baseUrl/services/"; file="services\index.html"},
    @{url="$baseUrl/contact-us/"; file="contact-us\index.html"},
    @{url="$baseUrl/404-error/"; file="404-error\index.html"}
)

function Download-Page($url, $relPath) {
    $fullPath = Join-Path $outDir $relPath
    $dir = Split-Path $fullPath -Parent
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 60
        $content = $resp.Content
        [System.IO.File]::WriteAllText($fullPath, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Downloaded: $relPath"
    } catch {
        Write-Host "FAILED: $url - $_"
    }
}

foreach ($page in $pages) {
    Download-Page $page.url $page.file
}

Write-Host "Done downloading pages!"

