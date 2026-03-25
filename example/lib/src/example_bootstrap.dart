import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'example_constants.dart';
import 'logger_settings_repository.dart';

class ExampleBootstrapResult {
  const ExampleBootstrapResult({required this.firebaseInitialized});

  final bool firebaseInitialized;
}

Future<ExampleBootstrapResult> bootstrapExampleApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseInitialized = false;
  var initialConfiguration = const FirebaseLoggerConfiguration();
  Stream<FirebaseLoggerConfiguration>? configurationStream;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;

    await ensureLoggerConfigurationDocument();
    initialConfiguration = await loadLoggerConfiguration();
    configurationStream = watchLoggerConfiguration();
  } catch (error) {
    debugPrint('Failed to initialize Firebase: $error');
    debugPrint(
      'The example will stay in locked mode until Firebase is configured.',
    );
  }

  await FirebaseLogger.initialize(
    collectionName: logCollectionName,
    minimumLevel: initialConfiguration.minimumLevel,
    enableConsoleLogging: initialConfiguration.consoleLoggingEnabled,
    enableRemoteLogging:
        firebaseInitialized && initialConfiguration.remoteLoggingEnabled,
    configurationStream: configurationStream,
    globalContext: <String, dynamic>{
      'app': 'advanced_firebase_logger_example',
      'environment': firebaseInitialized ? 'firebase' : 'locked',
      'platform': defaultTargetPlatform.name,
    },
  );

  FirebaseLogger.setLoggingEnabled(initialConfiguration.loggingEnabled);

  return ExampleBootstrapResult(firebaseInitialized: firebaseInitialized);
}
