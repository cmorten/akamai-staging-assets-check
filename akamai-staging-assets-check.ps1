param (
  [String]    $BaseDomain = "",
  [String[]]  $AssetPaths = @(),
  [Switch]    $Help
)

function Usage() {
  Write-Output "akamai-staging-assets-check - check the status of assets in Akamai staging"
  Write-Output " "
  Write-Output "Usage:"
  Write-Output " "
  Write-Output "./akamai-staging-assets-check.ps1 [BaseDomain] [AssetPath,...] [flags]"
  Write-Output " "
  Write-Output "Parameters:"
  Write-Output "-Help                         show brief help"
  Write-Output "-AssetPaths     [REQUIRED]    specify the asset paths to check"
  Write-Output "-BaseDomain     [REQUIRED]    specify the base domain for assets"
  Write-Output " "
  Write-Output "Examples:"
  Write-Output " "
  Write-Output '    ./akamai-staging-assets-check.ps1 "my.assets.com" "/asset/path/one.js", "/asset/path/two.js"'
  Write-Output '    ./akamai-staging-assets-check.ps1 -BaseDomain "my.assets.com" -AssetPaths "/asset/path/one.js", "/asset/path/two.js"'
}

if ($Help) {
  Usage
  exit 0
}

if (!$BaseDomain) {
  Write-Host "Error: A base domain must be provided.`n"
  Usage
  exit 1
}

if (!$AssetPaths) {
  Write-Host "Error: At least one asset path must be provided.`n"
  Usage
  exit 1
}

$AkamaiDomain = [System.Net.Dns]::GetHostEntry($BaseDomain).HostName;
$AkamaiStagingDomain = $AkamaiDomain -replace "akamaiedge", "akamaiedge-staging"

Write-Output "BASE DOMAIN:`t`t`t$BaseDomain"
Write-Output "AKAMAI CNAME:`t`t`t$AkamaiDomain"
Write-Output "AKAMAI STAGING CNAME:`t`t$AkamaiStagingDomain`n"
Write-Output "Asset Status Checks:"

$ExitCode = 0
foreach ($AssetPath in $AssetPaths) {
  $AssetUrl = "https://$BaseDomain$AssetPath"
  $AkamaiStagingUrl = "https://$AkamaiStagingDomain$AssetPath"

  try {
    $Response = Invoke-WebRequest `
      -Uri $AkamaiStagingUrl `
      -Headers @{Host = "$BaseDomain"} `
      -UseBasicParsing `
      -ErrorAction Stop
    $StatusCode = $Response.StatusCode
  }
  catch {
    $ExitCode = 1
    $StatusCode = $_.Exception.Response.StatusCode.value__, 404 -ne $null
  }

  Write-Output "`t$StatusCode`t$AssetUrl"
}

exit $ExitCode