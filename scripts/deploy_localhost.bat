@echo off
setlocal

cd /d "%GITHUB_WORKSPACE%"

python -m pip install --upgrade pip
if errorlevel 1 exit /b 1

if exist requirements.txt (
    pip install -r requirements.txt
) else (
    pip install django
)
if errorlevel 1 exit /b 1

python manage.py migrate --noinput
if errorlevel 1 exit /b 1

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'manage.py runserver' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"

powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start_localhost.ps1
if errorlevel 1 exit /b 1

endlocal
