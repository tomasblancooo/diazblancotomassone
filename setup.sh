#!/usr/bin/env bash
# Genera el APK de CyberSec CRM (Linux / macOS)
set -e
cd "$(dirname "$0")"

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] Flutter no esta en el PATH. Instalalo desde https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "== 1/6 Creando proyecto Android base =="
flutter create --org com.cybersec --project-name cybersec_crm --platforms android app

echo "== 2/6 Copiando el codigo de la app =="
rm -rf app/lib
cp -R lib app/lib

cd app
echo "== 3/6 Ajustando Android =="
dart ../tool/patch_android.dart

echo "== 4/6 Instalando dependencias =="
flutter pub add shared_preferences
flutter pub get

echo "== 5/6 Analizando el codigo =="
flutter analyze || echo "[AVISO] El analisis reporto observaciones. Se continua con la compilacion."

echo "== 6/6 Compilando APK release =="
flutter build apk --release

cp build/app/outputs/flutter-apk/app-release.apk ../CyberSec_CRM.apk
echo
echo "LISTO: $(cd .. && pwd)/CyberSec_CRM.apk"
