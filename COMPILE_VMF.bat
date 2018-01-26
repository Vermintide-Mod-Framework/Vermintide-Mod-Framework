@setlocal enableextensions
@echo off

:: project-defined variable, you probably shouldn't change them

set SOUCE_CODE_DIR=.\vmf_source
set TEMP_DIR=.\TEMP
set ORIGINAL_VMF_BUNDLE_FILE_NAME=98161451961848df
set NEW_VMF_BUNDLE_FILE_NAME=000_VMF_Main_Bundle

:: manual setting pathes (in case this batch file won't be able to find steam installation folders) [you can change them :D]

set MANUAL_MODS_DIR=C:\Program Files (x86)\Steam\steamapps\common\Warhammer End Times Vermintide\bundle\mods
set MANUAL_STINGRAY_EXE=C:\Program Files (x86)\Steam\steamapps\common\Warhammer End Times Vermintide Mod Tools\bin\stingray_win64_dev_x64.exe

:: find Vermintide folder

set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 235540"
set VALUE_NAME=InstallLocation

for /F "usebackq skip=2 tokens=1-2*" %%A in (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) do (
  set MODS_DIR=%%C\bundle\mods
)

:: find Stingray SDK folder

set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 718610"
set VALUE_NAME=InstallLocation

FOR /F "usebackq skip=2 tokens=1-2*" %%A in (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) do (

  set STINGRAY_EXE=%%C\bin\stingray_win64_dev_x64.exe
)

:: checking if Vermintide mods folder and Sringray binary exist

if not exist "%MODS_DIR%" set MODS_DIR=%MANUAL_MODS_DIR%

if not exist "%MODS_DIR%" (
  echo ERROR: Vermintide install location not found. Script execution aborted.
  pause
  exit
)

if not exist "%STINGRAY_EXE%" set MODS_DIR=%MANUAL_STINGRAY_EXE%

if not exist "%STINGRAY_EXE%" (
  echo ERROR: stingray_win64_dev_x64.exe not found. Script execution aborted.
  pause
  exit
)

::compiling

echo Starting...

"%STINGRAY_EXE%" --compile-for win32 --source-dir "%SOUCE_CODE_DIR%" --data-dir "%TEMP_DIR%\compile" --bundle-dir "%TEMP_DIR%\bundle"

echo Done.

::moving compiled file to the mods directory (overwritting if needed)

move /y %TEMP_DIR%\bundle\*. "%MODS_DIR%"

::if ORIGINAL_VMF_BUNDLE_FILE_NAME and NEW_VMF_BUNDLE_FILE_NAME specified, delete the old renamed file and rename the new one

if not "%ORIGINAL_VMF_BUNDLE_FILE_NAME%"== "" ^
if not "%NEW_VMF_BUNDLE_FILE_NAME%"== "" ^
if exist "%MODS_DIR%\%NEW_VMF_BUNDLE_FILE_NAME%" ^
del "%MODS_DIR%\%NEW_VMF_BUNDLE_FILE_NAME%"

if not "%ORIGINAL_VMF_BUNDLE_FILE_NAME%"== "" ^
if not "%NEW_VMF_BUNDLE_FILE_NAME%"== "" ^
ren "%MODS_DIR%\%ORIGINAL_VMF_BUNDLE_FILE_NAME%" "%NEW_VMF_BUNDLE_FILE_NAME%"

pause