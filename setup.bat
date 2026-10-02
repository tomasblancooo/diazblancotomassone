@echo off
setlocal
cd /d "%~dp0"

where flutter >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Flutter no esta en el PATH. Instalalo desde https://docs.flutter.dev/get-started/install
  pause
  exit /b 1
)

echo == 1/6 Creando proyecto Android base ==
call flutter create --org com.cybersec --project-name cybersec_crm --platforms android app
if errorlevel 1 goto :error

echo == 2/6 Copiando el codigo de la app ==
if exist app\lib rmdir /S /Q app\lib
xcopy /E /I /Y /Q lib app\lib >nul
if errorlevel 1 goto :error

cd app
echo == 3/6 Ajustando Android ==
call dart ..\tool\patch_android.dart
if errorlevel 1 goto :error

echo == 4/6 Instalando dependencias ==
call flutter pub add shared_preferences
if errorlevel 1 goto :error
call flutter pub get
if errorlevel 1 goto :error

echo == 5/6 Analizando el codigo ==
call flutter analyze
if errorlevel 1 echo [AVISO] El analisis reporto observaciones. Se continua con la compilacion.

echo == 6/6 Compilando APK release ==
call flutter build apk --release
if errorlevel 1 goto :error

copy /Y build\app\outputs\flutter-apk\app-release.apk ..\CyberSec_CRM.apk >nul
cd ..
echo.
echo LISTO: %cd%\CyberSec_CRM.apk
pause
exit /b 0

:error
echo.
echo [ERROR] Algo fallo. Copia el mensaje de error de arriba y pegaselo a la IA.
pause
exit /b 1
