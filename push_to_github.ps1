$ErrorActionPreference = "Continue"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Energya Cables 3D - GitHub Deploy Tool" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitPath = $gitCmd.Source
} else {
    $possiblePaths = @(
        "C:\Program Files\Git\cmd\git.exe",
        "C:\Program Files (x86)\Git\cmd\git.exe",
        "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
        "C:\Users\m.galal\AppData\Local\Programs\Git\cmd\git.exe"
    )
    foreach ($p in $possiblePaths) {
        if (Test-Path $p) { $gitPath = $p; break }
    }
}

if (-not $gitPath -or -not (Test-Path $gitPath)) {
    Write-Host "[!] Git executable not found on system PATH." -ForegroundColor Red
    pause
    exit
}

Write-Host "`n[1/3] Adding and committing files..." -ForegroundColor Green
if (-not (Test-Path ".git")) {
    & $gitPath init -b main
}
& $gitPath branch -M main 2>$null
& $gitPath add -A
& $gitPath commit -m "Energya Cables 3D: Fix index.html standalone linkage, 3D Twin & GitHub Pages setup" 2>$null

$defaultRepo = "https://github.com/lava101010/MachineFollowUp-Wip.git"
Write-Host "`nTarget Repository: $defaultRepo" -ForegroundColor White
$inputRepo = Read-Host "Enter your repository URL (or press ENTER to use default)"
if ([string]::IsNullOrWhiteSpace($inputRepo)) {
    $repoUrl = $defaultRepo
} else {
    $repoUrl = $inputRepo.Trim()
}

Write-Host "`n[2/3] Configuring Remote Repository: $repoUrl" -ForegroundColor Green
& $gitPath remote remove origin 2>$null
& $gitPath remote add origin $repoUrl

Write-Host "`n[3/3] Pushing to GitHub (main branch)..." -ForegroundColor Green
Write-Host "Note: If a GitHub login window pops up, click 'Sign in with your browser' / 'Authorize'.`n" -ForegroundColor Yellow

& $gitPath push -u origin main --force

if ($LASTEXITCODE -eq 0) {
    # Extract username and repo name for Pages link
    $pagesUrl = "https://github.com"
    if ($repoUrl -match "github\.com[/:]([^/]+)/([^/\.]+)") {
        $owner = $matches[1]
        $repo = $matches[2]
        $pagesUrl = "https://$owner.github.io/$repo/"
        $settingsUrl = "https://github.com/$owner/$repo/settings/pages"
    } else {
        $settingsUrl = "$repoUrl/settings/pages"
    }

    Write-Host "`n========================================================" -ForegroundColor Green
    Write-Host "  SUCCESSFULLY UPLOADED TO GITHUB!" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "Now enable GitHub Pages in 3 quick steps:" -ForegroundColor White
    Write-Host "1. Open: $settingsUrl" -ForegroundColor Cyan
    Write-Host "2. Under 'Build and deployment':" -ForegroundColor White
    Write-Host "   Set Source: Deploy from a branch" -ForegroundColor White
    Write-Host "   Set Branch: main, and Folder: / (root)" -ForegroundColor White
    Write-Host "3. Click Save!" -ForegroundColor White
    Write-Host "`nYour Live Web Dashboard URL will be:" -ForegroundColor Yellow
    Write-Host "$pagesUrl" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Green
} else {
    Write-Host "`n========================================================" -ForegroundColor Red
    Write-Host "  PUSH FAILED OR PERMISSION DENIED (403)" -ForegroundColor Red
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host "Possible causes:" -ForegroundColor Yellow
    Write-Host "1. If the repository belongs to another user (e.g., lava101010), your logged-in GitHub account must be added as a Collaborator." -ForegroundColor White
    Write-Host "2. Or create a new repository under your own GitHub account and enter its URL." -ForegroundColor White
    Write-Host "3. Or run 'git credential-manager clear' to switch GitHub accounts." -ForegroundColor White
}

Write-Host "`nPress any key to close this window..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
