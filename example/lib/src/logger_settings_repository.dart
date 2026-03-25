import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'example_constants.dart';

DocumentReference<Map<String, dynamic>> get loggerSettingsDocument {
  return FirebaseFirestore.instance
      .collection(settingsCollectionName)
      .doc(settingsDocumentName);
}

Map<String, dynamic> get defaultLoggerConfigurationMap {
  return <String, dynamic>{
    'loggingEnabled': true,
    'remoteLoggingEnabled': true,
    'consoleLoggingEnabled': true,
    'minimumLevel': LogLevel.info.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

Stream<FirebaseLoggerConfiguration> watchLoggerConfiguration() {
  return loggerSettingsDocument.snapshots().map(
    (snapshot) => FirebaseLoggerConfiguration.fromMap(
      snapshot.data() ?? defaultLoggerConfigurationMap,
    ),
  );
}

Future<void> ensureLoggerConfigurationDocument() async {
  final snapshot = await loggerSettingsDocument.get();
  if (!snapshot.exists) {
    await loggerSettingsDocument.set(defaultLoggerConfigurationMap);
  }
}

Future<FirebaseLoggerConfiguration> loadLoggerConfiguration() async {
  final snapshot = await loggerSettingsDocument.get();
  return FirebaseLoggerConfiguration.fromMap(
    snapshot.data() ?? defaultLoggerConfigurationMap,
  );
}

Future<void> saveLoggerConfiguration({
  required bool loggingEnabled,
  required bool remoteLoggingEnabled,
  required bool consoleLoggingEnabled,
  required LogLevel minimumLevel,
}) async {
  await loggerSettingsDocument.set(<String, dynamic>{
    'loggingEnabled': loggingEnabled,
    'remoteLoggingEnabled': remoteLoggingEnabled,
    'consoleLoggingEnabled': consoleLoggingEnabled,
    'minimumLevel': minimumLevel.name,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}
