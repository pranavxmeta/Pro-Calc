param (
    [string]$Patch = "",      # Optional: pass a specific patch number like -Patch 0
    [switch]$NoPatch          # Optional: pass -NoPatch to omit the patch completely (e.g. 26.8)
)

# 1. Fetch tags from remote (if git repository is connected)
try {
    git fetch --tags --quiet 2>$null
} catch {}

# 2. Get current Year and Month
$Year = (Get-Date -Format "yy")
$Month = (Get-Date).Month

# 3. Determine Patch Number
if ($NoPatch) {
    # If -NoPatch switch is used: Version name is just YY.M
    $VersionName = "$Year.$Month"
}
elseif ($Patch -ne "") {
    # If user manually passed a patch number (e.g., -Patch 0)
    $VersionName = "$Year.$Month.$Patch"
}
else {
    # Auto-calculate patch based on existing Git tags
    $Prefix = "v$Year.$Month."
    $MatchingTags = git tag -l "$Prefix*" 2>$null
    
    if ($MatchingTags) {
        $Patches = $MatchingTags | ForEach-Object { 
            [int]($_ -replace "^$([regex]::Escape($Prefix))", "") 
        }
        $LatestPatch = ($Patches | Measure-Object -Maximum).Maximum
        $CalculatedPatch = $LatestPatch + 1
    } else {
        # First build of this month (or no tags set yet)
        $CalculatedPatch = 0
    }
    $VersionName = "$Year.$Month.$CalculatedPatch"
}

# 4. Compute unique Build Number from total commits
try {
    $BuildNumber = (git rev-list --count HEAD).Trim()
} catch {
    # Fallback if git is not initialized
    $BuildNumber = 1
}

$FullVersion = "$VersionName+$BuildNumber"
$TagName = "v$VersionName"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Building Release: $FullVersion" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

# 5. Build Flutter APK
flutter build apk --release `
  --build-name="$VersionName" `
  --build-number="$BuildNumber"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build Failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`nBuild Successful!" -ForegroundColor Green

# Ask to create and push tag
if (-not $NoPatch) {
    $choice = Read-Host "Do you want to create and push git tag '$TagName'? (y/n)"
    if ($choice -eq "y" -or $choice -eq "Y") {
        git tag $TagName
        Write-Host "Tag $TagName created locally." -ForegroundColor Green
        
        # Push tag to remote repository
        git push origin $TagName
        Write-Host "Tag $TagName successfully pushed to remote!" -ForegroundColor Green
    }
}