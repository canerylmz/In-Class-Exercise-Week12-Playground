@echo off
setlocal

cd /d "%GITHUB_WORKSPACE%"

python -m pip install --upgrade pip

if exist requirements.txt (
    pip install -r requirements.txt
) else (
    pip install django
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'manage.py runserver' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"

set RUNNER_TRACKING_ID=

start "django-server" /MIN cmd /c "python manage.py runserver 127.0.0.1:8000 --noreload > django-server.log 2> django-server-error.log"

endlocal
