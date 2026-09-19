@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo ВНИМАНИЕ: будут удалены локальные данные PocketBase.
set /p answer=Для продолжения введи YES: 
if /I not "%answer%"=="YES" exit /b 0

if exist pb_data rmdir /s /q pb_data
call START_SERVER.bat
