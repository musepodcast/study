# Run from any directory. A normal run commits all repository changes and pushes production.
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('Patch', 'Minor', 'Major', 'Build')]
    [string]$Bump = 'Patch',
    [string]$Message = 'Update civics study app',
    [switch]$PrepareOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $repoRoot 'app'
$pubspecPath = Join-Path $appRoot 'pubspec.yaml'

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Command $($Arguments -join ' ') failed (exit $LASTEXITCODE). Nothing further will be published."
    }
}

function Read-Git {
    param([string[]]$Arguments)
    $output = & git @Arguments
    if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed." }
    return ($output -join "`n").Trim()
}

Push-Location -LiteralPath $repoRoot
try {
    Get-Command git -ErrorAction Stop | Out-Null
    $gitRoot = Read-Git -Arguments @('rev-parse', '--show-toplevel')
    if ([IO.Path]::GetFullPath($gitRoot) -ne [IO.Path]::GetFullPath($repoRoot)) {
        throw 'The script must be inside the study repository tools directory.'
    }
    $branch = Read-Git -Arguments @('branch', '--show-current')
    if ($branch -ne 'test_dev') { throw "Switch to test_dev first. Current branch: $branch" }
    $remote = Read-Git -Arguments @('remote', 'get-url', '--push', 'origin')
    if ($remote -notmatch '^(https://github\.com/musepodcast/study(?:\.git)?/?|git@github\.com:musepodcast/study(?:\.git)?)$') {
        throw "Unexpected origin push URL: $remote"
    }

    $original = [IO.File]::ReadAllText($pubspecPath)
    $versionMatch = [regex]::Match($original, '(?m)^version:[ \t]*(\d+)\.(\d+)\.(\d+)\+(\d+)[ \t]*\r?$')
    if (-not $versionMatch.Success) { throw 'Expected a pubspec version such as 1.0.0+1.' }
    $major = [long]$versionMatch.Groups[1].Value
    $minor = [long]$versionMatch.Groups[2].Value
    $patch = [long]$versionMatch.Groups[3].Value
    $build = [long]$versionMatch.Groups[4].Value + 1
    switch ($Bump) {
        'Major' { $major++; $minor = 0; $patch = 0 }
        'Minor' { $minor++; $patch = 0 }
        'Patch' { $patch++ }
    }
    $nextVersion = "$major.$minor.$patch+$build"
    $previousVersion = "$($versionMatch.Groups[1].Value).$($versionMatch.Groups[2].Value).$($versionMatch.Groups[3].Value)+$($versionMatch.Groups[4].Value)"
    $action = "Bump $previousVersion to $nextVersion and validate"
    if (-not $PrepareOnly) { $action += ', commit all changes, and push test_dev to production' }
    if (-not $PSCmdlet.ShouldProcess($repoRoot, $action)) { return }

    foreach ($command in @('flutter', 'dart', 'python')) {
        Get-Command $command -ErrorAction Stop | Out-Null
    }
    Invoke-Checked -Command git -Arguments @('fetch', 'origin', 'test_dev')
    $counts = (Read-Git -Arguments @('rev-list', '--left-right', '--count', 'HEAD...refs/remotes/origin/test_dev')) -split '\s+'
    if ([int]$counts[1] -gt 0) {
        throw 'GitHub has commits missing locally. Integrate origin/test_dev, then rerun this script.'
    }

    # Preserve all other YAML content, its original line endings, and UTF-8 without BOM.
    $replacement = 'version: ' + $nextVersion
    if ($versionMatch.Value.EndsWith("`r")) { $replacement += "`r" }
    $updated = $original.Substring(0, $versionMatch.Index) + $replacement + $original.Substring($versionMatch.Index + $versionMatch.Length)
    [IO.File]::WriteAllText($pubspecPath, $updated, (New-Object Text.UTF8Encoding($false)))
    Write-Host "Version: $previousVersion -> $nextVersion"

    Push-Location -LiteralPath $appRoot
    try {
        Invoke-Checked -Command flutter -Arguments @('pub', 'get')
        Invoke-Checked -Command dart -Arguments @('format', 'lib', 'test')
        Invoke-Checked -Command flutter -Arguments @('analyze')
        Invoke-Checked -Command flutter -Arguments @('test')
        Invoke-Checked -Command python -Arguments @('../tools/validate_data.py')
        Invoke-Checked -Command flutter -Arguments @('build', 'web', '--release', '--base-href', '/study/', '--no-web-resources-cdn')
        if (-not (Test-Path -LiteralPath 'build/web/index.html')) { throw 'Web build is missing index.html.' }
    }
    finally { Pop-Location }

    if ($PrepareOnly) {
        Write-Host "Prepared $nextVersion. Checks passed; changes are local and uncommitted."
        return
    }
    Invoke-Checked -Command git -Arguments @('add', '--all')
    Invoke-Checked -Command git -Arguments @('commit', '-m', "${Message} (v$nextVersion)")
    Invoke-Checked -Command git -Arguments @('push', '-u', 'origin', 'test_dev')
    Write-Host "Uploaded v$nextVersion. GitHub Actions is deploying production."
    Write-Host 'Watch: https://github.com/musepodcast/study/actions'
    Write-Host 'Website: https://musepodcast.github.io/study/'
}
finally { Pop-Location }
