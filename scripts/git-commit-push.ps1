param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Message,

    [string]$Remote = "origin",
    [string]$Branch = "",
    [switch]$NoAdd
)

$ErrorActionPreference = "Stop"

function Stop-WithMessage {
    param([string]$Text)

    Write-Host "ERROR: $Text" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Stop-WithMessage "Git is not installed or is not available in PATH."
}

$repoRoot = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
    Stop-WithMessage "Run this script from inside a Git repository."
}

Set-Location $repoRoot

if ([string]::IsNullOrWhiteSpace($Branch)) {
    $Branch = git branch --show-current
    if ([string]::IsNullOrWhiteSpace($Branch)) {
        Stop-WithMessage "Could not detect the current branch. Pass -Branch <branch-name>."
    }
}

$remoteUrl = git remote get-url $Remote 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($remoteUrl)) {
    Stop-WithMessage "Git remote '$Remote' is not configured. Add it with: git remote add $Remote <github-repo-url>"
}

if ($remoteUrl -notmatch "github\.com") {
    Write-Host "WARNING: Remote '$Remote' does not look like a GitHub URL: $remoteUrl" -ForegroundColor Yellow
}

if (-not $NoAdd) {
    Write-Host "Staging changes..."
    git add -A
}

$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
    Stop-WithMessage "No changes to commit."
}

Write-Host "Creating commit on branch '$Branch'..."
git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage "Commit failed."
}

Write-Host "Pushing to $Remote/$Branch..."
git push -u $Remote $Branch
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage "Push failed. Check your GitHub credentials, branch protection, or remote URL."
}

Write-Host "Done. Code committed and pushed to GitHub." -ForegroundColor Green
