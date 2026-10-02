# CyberSec CRM: kit para generar el APK

App móvil (Android) para gestionar clientes corporativos según su riesgo de ciberseguridad.
Es la versión móvil de la planilla CyberSec CRM: fórmula de riesgo automática y colores rojo/ámbar/verde.

## Qué incluye

- Lista de clientes con color automático, buscador y filtros (todos, en riesgo, seguros, auditoría vencida).
- Alta, edición y baja (deslizar a la izquierda o botón de eliminar).
- Vista previa del riesgo mientras se carga el formulario.
- Dashboard: total, en riesgo, auditorías vencidas, puntaje medio, barras por empresa, gráfico circular y alertas.
- Datos guardados en el teléfono. No necesita internet, cuenta ni servidor.
- 4 clientes de ejemplo la primera vez que se abre.

## Reglas de riesgo

| Vulnerabilidades críticas | Puntaje base |
|---|---|
| 5 o más | 95 |
| 2 a 4 | 40 |
| 0 a 1 | 0 |

Si la última auditoría tiene más de 90 días, suma 15 puntos (tope 100).
Nivel: 80 o más = Crítico (rojo, "En riesgo"), 40 a 79 = Medio (ámbar), menos de 40 = Bajo (verde, "Seguro").

Para cambiar las reglas, editá el archivo `lib/models/cliente.dart` (getter `puntaje`).

## Requisitos (una sola vez)

1. Flutter SDK: https://docs.flutter.dev/get-started/install
2. Android Studio con Android SDK y Command-line Tools.
3. Aceptar licencias: `flutter doctor --android-licenses`
4. Comprobar que todo esté bien: `flutter doctor` (Flutter y Android toolchain con tilde).
5. Conexión a internet en la primera compilación (Gradle descarga dependencias; puede tardar varios minutos).

## Generar el APK

Descomprimí el zip y ejecutá:

- Windows: doble clic en `setup.bat`
- Linux o macOS: `./setup.sh`

Al terminar queda `CyberSec_CRM.apk` en esta misma carpeta.

El script crea el proyecto Android, copia el código, instala `shared_preferences`, analiza y compila.

## Opción sin instalar nada: GitHub Actions

1. Creá un repositorio en github.com y subí el contenido de esta carpeta (lib, tool, README, scripts).
2. Verificá que exista `.github/workflows/build-apk.yml` (si no, creálo desde la web con "Add file > Create new file" y pegá el contenido).
3. Entrá a la pestaña **Actions**, elegí **Build APK** y tocá **Run workflow**. También corre solo con cada subida.
4. Esperá unos minutos. Al terminar, abrí la ejecución y bajá **CyberSec_CRM-apk** desde la sección **Artifacts**. Es un zip que contiene el APK.
5. Si falla, abrí el paso en rojo, copiá el log y pegáselo a la IA.

## Instalar en el celular

1. Pasá `CyberSec_CRM.apk` al teléfono (cable, Drive o WhatsApp como documento).
2. Habilitá "Instalar apps desconocidas" para la app desde la que lo abrís.
3. Abrí el archivo e instalá. Si Play Protect avisa, es normal en APKs propios.

## Si algo falla

Copiá el mensaje de error completo y pegáselo a la IA junto con la salida de `flutter doctor -v`.

| Síntoma | Qué revisar |
|---|---|
| "Flutter no está en el PATH" | Reabrí la terminal tras instalar Flutter |
| Error de licencias de Android | `flutter doctor --android-licenses` |
| Falla Gradle o Java | `flutter doctor -v` y actualizar Android Studio |
| Se queda mucho tiempo en "Running Gradle task" | Es normal la primera vez |

## Límites

- Los datos viven solo en ese teléfono: sin sincronización entre dispositivos ni login.
- El APK sale firmado con la clave de depuración. Sirve para instalar y mostrar; para Google Play hace falta firma propia.
