$ErrorActionPreference = "Stop"

$workspace = $env:GITHUB_WORKSPACE
if (-not $workspace) {
    $workspace = (Resolve-Path ".").Path
}

$env:RUNNER_TRACKING_ID = $null

$stdoutLog = Join-Path $workspace "django-server.log"
$stderrLog = Join-Path $workspace "django-server-error.log"

Start-Process `
    -FilePath "python" `
    -ArgumentList @("manage.py", "runserver", "127.0.0.1:8000", "--noreload") `
    -WorkingDirectory $workspace `
    -RedirectStandardOutput $stdoutLog `
    -RedirectStandardError $stderrLog `
    -WindowStyle Hidden

Start-Sleep -Seconds 5

$isListening = Test-NetConnection 127.0.0.1 -Port 8000 -InformationLevel Quiet
if (-not $isListening) {
    Write-Error "Django did not start on 127.0.0.1:8000"

    if (Test-Path $stderrLog) {
        Get-Content $stderrLog
    }

    if (Test-Path $stdoutLog) {
        Get-Content $stdoutLog
    }

    exit 1
}
