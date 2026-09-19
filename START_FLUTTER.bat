@echo off
setlocal
cd /d "%~dp0"

netstat -ano | findstr ":5556" | findstr "LISTENING" >nul
if not errorlevel 1 (
  echo Site is already running at http://localhost:5556
  echo Do not start a second Flutter instance.
  pause
  exit /b 0
)

where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found in PATH.
  pause
  exit /b 1
)

echo Getting Flutter packages...
call flutter pub get --offline
if errorlevel 1 call flutter pub get
if errorlevel 1 (
  echo Failed to get Flutter packages.
  pause
  exit /b 1
)

echo Starting site at http://localhost:5556
call flutter run -d chrome --web-port=5556 --dart-define=API_BASE_URL=http://127.0.0.1:8090
