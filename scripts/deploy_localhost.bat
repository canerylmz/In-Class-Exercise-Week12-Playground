@echo off
setlocal

set "DEPLOY_DIR=%USERPROFILE%\django-localhost-deploy"
set "LOG_DIR=%USERPROFILE%\django-localhost-deploy-logs"

if not exist "%DEPLOY_DIR%" mkdir "%DEPLOY_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

robocopy "%GITHUB_WORKSPACE%" "%DEPLOY_DIR%" /E /XD .git .venv venv __pycache__ /XF django-server*.log
if %ERRORLEVEL% GEQ 8 exit /b %ERRORLEVEL%

cd /d "%DEPLOY_DIR%"

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

powershell -NoProfile -ExecutionPolicy Bypass -File scripts\start_localhost.ps1 -DeployDir "%DEPLOY_DIR%" -LogDir "%LOG_DIR%"
if errorlevel 1 exit /b 1

endlocal
