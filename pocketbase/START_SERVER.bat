@echo off
setlocal
cd /d "%~dp0"

netstat -ano | findstr ":8090" | findstr "LISTENING" >nul
if not errorlevel 1 (
  echo PocketBase is already running at http://127.0.0.1:8090
  echo Admin UI: http://127.0.0.1:8090/_/
  pause
  exit /b 0
)

if exist pocketbase.exe goto run

echo PocketBase was not found. Downloading PocketBase 0.39.10...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $url='https://github.com/pocketbase/pocketbase/releases/download/v0.39.10/pocketbase_0.39.10_windows_amd64.zip'; Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile 'pocketbase_download.zip'; Expand-Archive -LiteralPath 'pocketbase_download.zip' -DestinationPath '.' -Force; Remove-Item 'pocketbase_download.zip' -Force"
if errorlevel 1 (
  echo Failed to download PocketBase. Check internet connection.
  pause
  exit /b 1
)

if not exist pocketbase.exe (
  echo pocketbase.exe was not found after extraction.
  pause
  exit /b 1
)

:run
echo PocketBase: http://127.0.0.1:8090
echo Admin UI:  http://127.0.0.1:8090/_/
echo Keep this window open.
echo.
pocketbase.exe serve
if errorlevel 1 (
  echo.
  echo PocketBase stopped with an error.
  pause
)
