param(
  [string]$HtmlPath = "index.html"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $HtmlPath)) { throw "Missing $HtmlPath" }

$html = Get-Content -LiteralPath $HtmlPath -Raw

$startMarker = "      <!-- LEFT COLUMN -->"
$endMarker = "      <!-- NOTES PANEL -->"
$start = $html.IndexOf($startMarker)
$end = $html.IndexOf($endMarker)

if ($start -lt 0 -or $end -lt 0 -or $end -le $start) {
  throw "Could not find grid markers in $HtmlPath"
}

$replacement = @"
$startMarker
      <div id="col1">
        <!-- Content rendered from content-data.js -->
      </div>

      <!-- MIDDLE COLUMN -->
      <div id="col2">
        <!-- Content rendered from content-data.js -->
      </div>

"@

$html2 = $html.Substring(0, $start) + $replacement + $html.Substring($end)

# Ensure content-data.js is loaded before the main script.
if ($html2 -notmatch "<script\s+src=""content-data\.js""></script>") {
  $scriptTag = "  <script src=""content-data.js""></script>`r`n"
  $mainScriptIdx = $html2.IndexOf("  <script>")
  if ($mainScriptIdx -lt 0) { throw "Could not find main <script> tag in $HtmlPath" }
  $html2 = $html2.Insert($mainScriptIdx, $scriptTag)
}

Set-Content -LiteralPath $HtmlPath -Value $html2 -Encoding UTF8
Write-Host "Updated $HtmlPath"
