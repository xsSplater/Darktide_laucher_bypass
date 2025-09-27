REM Made by xsSplater under GPL 3.0 license.
@echo off
setlocal enableextensions enabledelayedexpansion
1>nul chcp 65001

title "Darktide Launcher bypass"
mode con cols=100 lines=30

set SteamAppId=1361210

REM Get the absolute path to the folder where the script is located
set "game_root=%~dp0"
set "game_root=%game_root:~0,-1%"

REM Checking the correctness of the script location
for %%A in ("%game_root%") do set "parent_folder=%%~nxA"

if /i "!parent_folder!"=="content" (
	echo ERROR: Script must not be in the 'Content' folder^!
	echo Place it in the root folder of the game ^(eg Warhammer 40,000 DARKTIDE^)
	pause
	exit /b 1
)

REM Checking what version of the game is installed
if exist "content\" (
	set Version=Xbox
	echo XBOX version found
) else if exist "binaries\" (
	set Version=Steam
	echo STEAM version found
) else (
	echo Error: No 'Content' ^(Xbox^) or 'binaries' ^(Steam^)^ folders found!
	echo Move this batch file to the game folder. Usually ^"Warhammer 40,000 DARKTIDE^"
	pause
	exit /b 1
)

:check_running
REM Check if the game is already running
tasklist /FI "IMAGENAME eq Darktide.exe" 2>NUL | find /I "Darktide.exe" >NUL
if %errorlevel% equ 0 (
	echo The game is already running^! Exit...
	timeout /t 1 >nul
	exit
)

if "!Version!"=="Steam" (
	REM Check if Steam is running
	tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I "steam.exe" >NUL
	if errorlevel 1 (
		echo Steam is not running. Please launch Steam before launching the game^!
		pause
		exit /b 1
	)
	
	echo Launching Steam version...
	set "exe_path=%game_root%\binaries\Darktide.exe"
	if exist "!exe_path!" (
		start "" /wait "!exe_path!" --bundle-dir ../bundle --ini settings --backend-auth-service-url https://bsp-auth-prod.atoma.cloud --backend-title-service-url https://bsp-td-prod.atoma.cloud --lua-heap-mb-size 2048
	) else (
		echo Error: File not found - !exe_path!
		pause
		exit /b 1
	)
) else if "!Version!"=="Xbox" (
	echo Launching the Xbox version...
	set "exe_path=%game_root%\content\binaries\Darktide.exe"
	if exist "!exe_path!" (
		start "" /wait "!exe_path!" --bundle-dir ../bundle --ini settings --backend-auth-service-url https://bsp-auth-prod.atoma.cloud --backend-title-service-url https://bsp-td-prod.atoma.cloud --lua-heap-mb-size 2048
	) else (
		echo Error: File not found - !exe_path!
		pause
		exit /b 1
	)
)

echo Game closed. This window will close in 2 seconds...
timeout /t 2 >nul
exit