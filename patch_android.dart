import 'dart:io';

/// Ajusta el proyecto Android generado por `flutter create`.
/// Se ejecuta desde la carpeta "app".
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    stderr.writeln(
      'No se encontro AndroidManifest.xml. Ejecuta este script dentro de la carpeta app.',
    );
    exit(1);
  }
  var xml = manifest.readAsStringSync();
  final re = RegExp(r'android:label="[^"]*"');
  if (!re.hasMatch(xml)) {
    stderr.writeln('No se encontro android:label en el manifest.');
    exit(1);
  }
  xml = xml.replaceFirst(re, 'android:label="CyberSec CRM"');
  manifest.writeAsStringSync(xml);

  // El test de ejemplo de Flutter referencia una app que ya no existe.
  final test = File('test/widget_test.dart');
  if (test.existsSync()) {
    test.deleteSync();
  }
  stdout.writeln('Manifest actualizado (nombre visible: CyberSec CRM).');
}
