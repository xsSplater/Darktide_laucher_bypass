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

REM Language settings
set "config_file=%APPDATA%\Fatshark\Darktide\user_settings.config"
set "default_language=en"

:language_menu
echo.
echo Select the game language:
echo 1 - English ^(en^)
echo 2 - Russian ^(ru^)
echo 3 - French ^(fr^)
echo 4 - Traditional Chinese ^(zh-tw^)
echo 5 - Simplified Chinese ^(zh-cn^)
echo 6 - Polish ^(pl^)
echo 7 - German ^(de^)
echo 8 - Spanish ^(es^)
echo 9 - Italian ^(it^)
echo 0 - Japanese ^(ja^)
echo - - Korean ^(ko^)
echo = - Portuguese ^(pt-br^)
echo z - Keep current
echo.
set /p language_choice="Enter selection number: "

if "!language_choice!"=="1" set "target_language=en" & goto update_language
if "!language_choice!"=="2" set "target_language=ru" & goto update_language
if "!language_choice!"=="3" set "target_language=fr" & goto update_language
if "!language_choice!"=="4" set "target_language=zh-tw" & goto update_language
if "!language_choice!"=="5" set "target_language=zh-cn" & goto update_language
if "!language_choice!"=="6" set "target_language=pl" & goto update_language
if "!language_choice!"=="7" set "target_language=de" & goto update_language
if "!language_choice!"=="8" set "target_language=es" & goto update_language
if "!language_choice!"=="9" set "target_language=it" & goto update_language
if "!language_choice!"=="0" set "target_language=ja" & goto update_language
if "!language_choice!"=="-" set "target_language=ko" & goto update_language
if "!language_choice!"=="=" set "target_language=pt-br" & goto update_language
if "!language_choice!"=="z" (
	echo The current language has been saved.
	goto check_running
)

echo Wrong choice! Try again.
goto language_menu

:update_language
echo Updating language to !target_language!...

REM Create a backup copy
if exist "!config_file!" (
	copy "!config_file!" "!config_file!.backup" >nul
)

REM Checking the existence of the settings file
if not exist "!config_file!" (
	echo Settings file not found: !config_file!
	echo The default language will be used: !default_language!
	goto check_running
)

REM Create a temporary file
set "temp_file=!config_file!.tmp"

REM Process the file and replace the language_id while preserving the structure
set "updated=0"
(
for /f "usebackq delims=" %%A in ("!config_file!") do (
	set "line=%%A"
	set "original_line=%%A"
	
	REM A simple and reliable replacement: find the string with language_id and replace the value in quotation marks.
	echo.!line! | findstr /C:"language_id" >nul
	if !errorlevel! equ 0 (
		REM Found the line with language_id, replace the contents of the quotation marks
		for /f "tokens=1,2,3 delims=^=" %%X in ("!line!") do (
			set "part1=%%X"
			set "part2=%%Y"
			set "part3=%%Z"
		)
		if "!part2!" neq "" (
			REM Remove spaces and quotes, leaving only the new value
			set "part2=!target_language!"
			set "line=!part1!= "!part2!"!part3!"
			set "updated=1"
		)
	)
	
	echo.!line!
)
) > "!temp_file!"

REM Replace the original file
if !updated! equ 1 (
	move /y "!temp_file!" "!config_file!" >nul
	echo Language successfully changed to !target_language!
) else (
	del "!temp_file!"
	echo The language is already set to !target_language! or not found in the settings.
)

REM GAME LAUNCH
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
