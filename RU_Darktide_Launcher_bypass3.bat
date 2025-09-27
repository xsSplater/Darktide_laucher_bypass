REM Made by xsSplater under GPL 3.0 license.
@echo off
setlocal enableextensions enabledelayedexpansion
1>nul chcp 65001

title "Darktide Launcher bypass"
mode con cols=100 lines=30

set SteamAppId=1361210

REM Получаем абсолютный путь к папке, где находится скрипт
set "game_root=%~dp0"
set "game_root=%game_root:~0,-1%"

REM Проверяем корректность расположения скрипта
for %%A in ("%game_root%") do set "parent_folder=%%~nxA"

if /i "!parent_folder!"=="content" (
	echo ОШИБКА: Скрипт не должен находиться в папке 'content'^!
	echo Поместите его в корневую папку игры ^(например Warhammer 40,000 DARKTIDE^)
	pause
	exit /b 1
)

REM Проверяем, какая версия игры установлена
if exist "content\" (
	set Version=Xbox
	echo Обнаружена XBOX версия
) else if exist "binaries\" (
	set Version=Steam
	echo Обнаружена STEAM версия
) else (
	echo Ошибка: Не найдены папки 'Content' ^(Xbox^) или 'binaries' ^(Steam^)^!
	echo Переместите этот батник в папку c игрой. Обычно ^"Warhammer 40,000 DARKTIDE^"
	pause
	exit /b 1
)

:check_running
REM Проверяем, запущена ли уже игра
tasklist /FI "IMAGENAME eq Darktide.exe" 2>NUL | find /I "Darktide.exe" >NUL
if %errorlevel% equ 0 (
	echo Игра уже запущена^! Выход...
	timeout /t 1 >nul
	exit
)

if "!Version!"=="Steam" (
	REM Проверяем, запущен ли Steam
	tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I "steam.exe" >NUL
	if errorlevel 1 (
		echo Steam не запущен. Запустите Steam перед запуском игры^!
		pause
		exit /b 1
	)
	
	echo Запуск Steam-версии...
	set "exe_path=%game_root%\binaries\Darktide.exe"
	if exist "!exe_path!" (
		start "" /wait "!exe_path!" --bundle-dir ../bundle --ini settings --backend-auth-service-url https://bsp-auth-prod.atoma.cloud --backend-title-service-url https://bsp-td-prod.atoma.cloud --lua-heap-mb-size 2048
	) else (
		echo Ошибка: Файл не найден - !exe_path!
		pause
		exit /b 1
	)
) else if "!Version!"=="Xbox" (
	echo Запуск Xbox-версии...
	set "exe_path=%game_root%\content\binaries\Darktide.exe"
	if exist "!exe_path!" (
		start "" /wait "!exe_path!" --bundle-dir ../bundle --ini settings --backend-auth-service-url https://bsp-auth-prod.atoma.cloud --backend-title-service-url https://bsp-td-prod.atoma.cloud --lua-heap-mb-size 2048
	) else (
		echo Ошибка: Файл не найден - !exe_path!
		pause
		exit /b 1
	)
)

echo Игра закрыта. Это окно закроется через 2 секунды...
timeout /t 2 >nul
exit