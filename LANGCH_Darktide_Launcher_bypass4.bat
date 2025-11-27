REM Made by xsSplater under GPL 3.0 license.
@echo off
setlocal enableextensions enabledelayedexpansion
1>nul chcp 65001

title "Darktide Launcher bypass"
mode con cols=100 lines=30

set SteamAppId=1361210

REM Initialize language settings
set "LANGUAGE=auto"

REM Detect SYSTEM LANGUAGE
:DETECT_LANGUAGE
if "!LANGUAGE!"=="auto" (
	REM Check system locale via registry
	for /f "tokens=2*" %%I in ('reg query "HKCU\Control Panel\International" /v LocaleName 2^>nul') do (
		set "SYSTEM_LOCALE=%%J"
	)
	REM If registry method failed, try wmic
	if not defined SYSTEM_LOCALE (
		for /f "tokens=2 delims==" %%I in ('wmic os get locale /value 2^>nul') do (
			set "SYSTEM_LOCALE=%%I"
		)
	)
	
	REM If both methods failed, use environment variable
	if not defined SYSTEM_LOCALE (
		if not "%USERNAME:п%=%"=="%USERNAME%" (
			set "LANGUAGE=ru"
		) else if not "%USERNAME:а%=%"=="%USERNAME%" (
			set "LANGUAGE=ru"
		) else if not "%USERNAME:е%=%"=="%USERNAME%" (
			set "LANGUAGE=ru"
		) else (
			set "LANGUAGE=en"
		)
	) else (
		REM Clean and check the locale value
		set "SYSTEM_LOCALE=!SYSTEM_LOCALE: =!"
		if "!SYSTEM_LOCALE!"=="0419" set "LANGUAGE=ru"
		if "!SYSTEM_LOCALE!"=="ru-RU" set "LANGUAGE=ru"
		if "!SYSTEM_LOCALE!"=="ru" set "LANGUAGE=ru"
		if "!SYSTEM_LOCALE!"=="en-US" set "LANGUAGE=en"
		if "!SYSTEM_LOCALE!"=="en" set "LANGUAGE=en"
		if not defined LANGUAGE set "LANGUAGE=en"
	)
)

REM Initialize translations
if "!LANGUAGE!"=="ru" (
	set "MSG_SELECT_LANGUAGE=Выберите язык игры:"
	set "MSG_KEEP_CURRENT=Текущий язык сохранен."
	set "MSG_WRONG_CHOICE=Неправильный выбор! Попробуйте снова."
	set "MSG_UPDATING_LANGUAGE=Обновление языка на !target_language!..."
	set "MSG_SETTINGS_NOT_FOUND=Файл настроек не найден: !config_file!"
	set "MSG_DEFAULT_LANGUAGE=Будет использован язык по умолчанию: !default_language!"
	set "MSG_LANGUAGE_UPDATED=Язык успешно изменен на !target_language!"
	set "MSG_LANGUAGE_ALREADY_SET=Язык уже установлен на !target_language! или не найден в настройках."
	set "MSG_ERROR_LOCATION=ОШИБКА: Скрипт не должен находиться в папке 'Content'!"
	set "MSG_PLACE_IN_ROOT=Поместите его в корневую папку игры (например Warhammer 40,000 DARKTIDE)"
	set "MSG_XBOX_FOUND=Найдена версия XBOX"
	set "MSG_STEAM_FOUND=Найдена версия STEAM"
	set "MSG_NO_FOLDERS=Ошибка: Не найдены папки 'Content' (Xbox) или 'binaries' (Steam)!"
	set "MSG_MOVE_TO_FOLDER=Переместите этот batch-файл в папку с игрой. Обычно 'Warhammer 40,000 DARKTIDE'"
	set "MSG_GAME_RUNNING=Игра уже запущена! Выход..."
	set "MSG_STEAM_NOT_RUNNING=Steam не запущен. Пожалуйста, запустите Steam перед запуском игры!"
	set "MSG_LAUNCHING_STEAM=Запуск Steam версии..."
	set "MSG_LAUNCHING_XBOX=Запуск Xbox версии..."
	set "MSG_FILE_NOT_FOUND=Ошибка: Файл не найден -"
	set "MSG_GAME_CLOSED=Игра закрыта. Это окно закроется через 2 секунды..."
) else (
	set "MSG_SELECT_LANGUAGE=Select the game language:"
	set "MSG_KEEP_CURRENT=The current language has been saved."
	set "MSG_WRONG_CHOICE=Wrong choice! Try again."
	set "MSG_UPDATING_LANGUAGE=Updating language to !target_language!..."
	set "MSG_SETTINGS_NOT_FOUND=Settings file not found: !config_file!"
	set "MSG_DEFAULT_LANGUAGE=The default language will be used: !default_language!"
	set "MSG_LANGUAGE_UPDATED=Language successfully changed to !target_language!"
	set "MSG_LANGUAGE_ALREADY_SET=The language is already set to !target_language! or not found in the settings."
	set "MSG_ERROR_LOCATION=ERROR: Script must not be in the 'Content' folder!"
	set "MSG_PLACE_IN_ROOT=Place it in the root folder of the game (eg Warhammer 40,000 DARKTIDE)"
	set "MSG_XBOX_FOUND=XBOX version found"
	set "MSG_STEAM_FOUND=STEAM version found"
	set "MSG_NO_FOLDERS=Error: No 'Content' (Xbox) or 'binaries' (Steam) folders found!"
	set "MSG_MOVE_TO_FOLDER=Move this batch file to the game folder. Usually 'Warhammer 40,000 DARKTIDE'"
	set "MSG_GAME_RUNNING=The game is already running! Exit..."
	set "MSG_STEAM_NOT_RUNNING=Steam is not running. Please launch Steam before launching the game!"
	set "MSG_LAUNCHING_STEAM=Launching Steam version..."
	set "MSG_LAUNCHING_XBOX=Launching the Xbox version..."
	set "MSG_FILE_NOT_FOUND=Error: File not found -"
	set "MSG_GAME_CLOSED=Game closed. This window will close in 2 seconds..."
)

REM Get the absolute path to the folder where the script is located
set "game_root=%~dp0"
set "game_root=%game_root:~0,-1%"

REM Checking the correctness of the script location
for %%A in ("%game_root%") do set "parent_folder=%%~nxA"

if /i "!parent_folder!"=="content" (
	echo !MSG_ERROR_LOCATION!
	echo !MSG_PLACE_IN_ROOT!
	pause
	exit /b 1
)

REM Checking what version of the game is installed
if exist "content\" (
	set Version=Xbox
	echo !MSG_XBOX_FOUND!
) else if exist "binaries\" (
	set Version=Steam
	echo !MSG_STEAM_FOUND!
) else (
	echo !MSG_NO_FOLDERS!
	echo !MSG_MOVE_TO_FOLDER!
	pause
	exit /b 1
)

REM Language settings
set "config_file=%APPDATA%\Fatshark\Darktide\user_settings.config"
set "default_language=en"

:language_menu
echo.
echo !MSG_SELECT_LANGUAGE!
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
	echo !MSG_KEEP_CURRENT!
	goto check_running
)

echo !MSG_WRONG_CHOICE!
goto language_menu

:update_language
echo !MSG_UPDATING_LANGUAGE!

REM Checking the existence of the settings file
if not exist "!config_file!" (
	echo !MSG_SETTINGS_NOT_FOUND!
	echo !MSG_DEFAULT_LANGUAGE!
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
	echo !MSG_LANGUAGE_UPDATED!
) else (
	del "!temp_file!"
	echo !MSG_LANGUAGE_ALREADY_SET!
)

REM GAME LAUNCH
:check_running
REM Check if the game is already running
tasklist /FI "IMAGENAME eq Darktide.exe" 2>NUL | find /I "Darktide.exe" >NUL
if %errorlevel% equ 0 (
	echo !MSG_GAME_RUNNING!
	timeout /t 1 >nul
	exit
)

if "!Version!"=="Steam" (
	REM Check if Steam is running
	tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I "steam.exe" >NUL
	if errorlevel 1 (
		echo !MSG_STEAM_NOT_RUNNING!
		pause
		exit /b 1
	)
	
	echo !MSG_LAUNCHING_STEAM!
	set "exe_path=%game_root%\binaries\Darktide.exe"
	if exist "!exe_path!" (
		start "" /wait "!exe_path!" --bundle-dir ../bundle --ini settings --backend-auth-service-url https://bsp-auth-prod.atoma.cloud --backend-title-service-url https://bsp-td-prod.atoma.cloud --lua-heap-mb-size 2048
	) else (
		echo !MSG_FILE_NOT_FOUND! !exe_path!
		pause
		exit /b 1
	)
) else if "!Version!"=="Xbox" (
	echo !MSG_LAUNCHING_XBOX!
	set "exe_path=%game_root%\content\binaries\Darktide.exe"
	if exist "!exe_path!" (
		start "" /wait "!exe_path!" --bundle-dir ../bundle --ini settings --backend-auth-service-url https://bsp-auth-prod.atoma.cloud --backend-title-service-url https://bsp-td-prod.atoma.cloud --lua-heap-mb-size 2048
	) else (
		echo !MSG_FILE_NOT_FOUND! !exe_path!
		pause
		exit /b 1
	)
)

echo !MSG_GAME_CLOSED!
timeout /t 2 >nul
exit