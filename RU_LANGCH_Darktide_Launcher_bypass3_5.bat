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

REM Языковые настройки
set "config_file=%APPDATA%\Fatshark\Darktide\user_settings.config"
set "default_language=ru"

:language_menu
echo.
echo Выберите язык игры:
echo 1 - Английский ^(en^)
echo 2 - Русский ^(ru^)
echo 3 - Французский ^(fr^)
echo 4 - Китайский традиционный ^(zh-tw^)
echo 5 - Китайский упрощённый ^(zh-cn^)
echo 6 - Польский ^(pl^)
echo 7 - Немецкий ^(de^)
echo 8 - Испанский ^(es^)
echo 9 - Итальянский ^(it^)
echo 0 - Японский ^(ja^)
echo - - Корейский ^(ko^)
echo = - Португальский ^(pt-br^)
echo z - Оставить текущий
echo.
set /p language_choice="Введите номер выбора: "

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
	echo Текущий язык сохранён.
	goto check_running
)

echo Неверный выбор! Попробуйте снова.
goto language_menu

:update_language
echo Обновление языка на !target_language!...

REM Создаем резервную копию
if exist "!config_file!" (
	copy "!config_file!" "!config_file!.backup" >nul
)

REM Проверяем существование файла настроек
if not exist "!config_file!" (
	echo Файл настроек не найден: !config_file!
	echo Будет использован язык по умолчанию: !default_language!
	goto check_running
)

REM Создаём временный файл
set "temp_file=!config_file!.tmp"

REM Обрабатываем файл и заменяем language_id с сохранением структуры
set "updated=0"
(
for /f "usebackq delims=" %%A in ("!config_file!") do (
	set "line=%%A"
	set "original_line=%%A"
	
	REM Простая и надежная замена - ищем строку с language_id и заменяем значение в кавычках
	echo.!line! | findstr /C:"language_id" >nul
	if !errorlevel! equ 0 (
		REM Нашли строку с language_id, заменяем содержимое кавычек
		for /f "tokens=1,2,3 delims=^=" %%X in ("!line!") do (
			set "part1=%%X"
			set "part2=%%Y"
			set "part3=%%Z"
		)
		if "!part2!" neq "" (
			REM Убираем пробелы и кавычки, оставляем только новое значение
			set "part2=!target_language!"
			set "line=!part1!= "!part2!"!part3!"
			set "updated=1"
		)
	)
	
	echo.!line!
)
) > "!temp_file!"

REM Заменяем оригинальный файл
if !updated! equ 1 (
	move /y "!temp_file!" "!config_file!" >nul
	echo Язык успешно изменен на !target_language!
) else (
	del "!temp_file!"
	echo Язык уже установлен на !target_language! или не найден в настройках.
)

REM ЗАПУСК ИГРЫ
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
