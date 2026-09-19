@echo off
setlocal
cd /d "%~dp0"

echo Starting PocketBase...
start "PocketBase" /D "%~dp0pocketbase" cmd /k START_SERVER.bat
timeout /t 8 /nobreak >nul
echo Starting Flutter...
start "Flutter" /D "%~dp0" cmd /k START_FLUTTER.bat
exit /b 0
