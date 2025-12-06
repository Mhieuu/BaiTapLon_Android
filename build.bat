@echo off
REM Build script for Elder Care Apps

echo ====================================
echo Elder Care System - Build Script
echo ====================================
echo.

set choice=
echo Choose what to do:
echo 1. Build Elder App APK
echo 2. Build Parent App APK
echo 3. Run Elder App (Debug)
echo 4. Run Parent App (Debug)
echo 5. Clean and Get Dependencies
echo 6. Build Both APKs
echo 7. Analyze Code
echo.

set /p choice="Enter your choice (1-7): "

if "%choice%"=="1" goto build_elder
if "%choice%"=="2" goto build_parent
if "%choice%"=="3" goto run_elder
if "%choice%"=="4" goto run_parent
if "%choice%"=="5" goto clean_all
if "%choice%"=="6" goto build_both
if "%choice%"=="7" goto analyze
goto invalid

:build_elder
echo Building Elder App APK...
cd elder_app
call flutter build apk --release
if errorlevel 1 echo Build failed! && pause && exit /b 1
echo.
echo APK location: elder_app\build\app\outputs\apk\release\app-release.apk
pause
exit /b 0

:build_parent
echo Building Parent App APK...
cd parent_app
call flutter build apk --release
if errorlevel 1 echo Build failed! && pause && exit /b 1
echo.
echo APK location: parent_app\build\app\outputs\apk\release\app-release.apk
pause
exit /b 0

:run_elder
echo Running Elder App...
cd elder_app
call flutter run
pause
exit /b 0

:run_parent
echo Running Parent App...
cd parent_app
call flutter run
pause
exit /b 0

:clean_all
echo Cleaning projects...
cd elder_app
call flutter clean
cd ..\parent_app
call flutter clean
cd ..
echo.
echo Getting dependencies...
cd elder_app
call flutter pub get
cd ..\parent_app
call flutter pub get
cd ..
echo Done!
pause
exit /b 0

:build_both
echo Building both apps...
echo.
echo Building Elder App...
cd elder_app
call flutter build apk --release
if errorlevel 1 echo Elder App build failed! && pause && exit /b 1
cd ..
echo.
echo Building Parent App...
cd parent_app
call flutter build apk --release
if errorlevel 1 echo Parent App build failed! && pause && exit /b 1
cd ..
echo.
echo Both APKs built successfully!
echo.
echo Locations:
echo - Elder: elder_app\build\app\outputs\apk\release\app-release.apk
echo - Parent: parent_app\build\app\outputs\apk\release\app-release.apk
pause
exit /b 0

:analyze
echo Analyzing Elder App...
cd elder_app
call flutter analyze
cd ..
echo.
echo Analyzing Parent App...
cd parent_app
call flutter analyze
cd ..
pause
exit /b 0

:invalid
echo Invalid choice!
pause
exit /b 1
