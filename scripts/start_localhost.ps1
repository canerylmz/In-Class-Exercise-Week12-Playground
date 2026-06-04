param(
    [string]$DeployDir = (Resolve-Path ".").Path,
    [string]$LogDir = (Resolve-Path ".").Path
)

$ErrorActionPreference = "Stop"

$env:RUNNER_TRACKING_ID = $null

$stdoutLog = Join-Path $LogDir "django-server.log"
$stderrLog = Join-Path $LogDir "django-server-error.log"

Start-Process `
    -FilePath "python" `
    -ArgumentList @("manage.py", "runserver", "127.0.0.1:8000", "--noreload") `
    -WorkingDirectory $DeployDir `
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
