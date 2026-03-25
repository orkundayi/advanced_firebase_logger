import 'dart:async';

import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(FirebaseLogger.resetForTesting);

  group('LogLevel', () {
    test('enum values should be correct', () {
      expect(LogLevel.finest.value, 0);
      expect(LogLevel.finer.value, 100);
      expect(LogLevel.fine.value, 200);
      expect(LogLevel.config.value, 300);
      expect(LogLevel.info.value, 400);
      expect(LogLevel.warning.value, 500);
      expect(LogLevel.severe.value, 600);
      expect(LogLevel.shout.value, 700);
    });

    test('enum names should be correct', () {
      expect(LogLevel.finest.name, 'FINEST');
      expect(LogLevel.finer.name, 'FINER');
      expect(LogLevel.fine.name, 'FINE');
      expect(LogLevel.config.name, 'CONFIG');
      expect(LogLevel.info.name, 'INFO');
      expect(LogLevel.warning.name, 'WARNING');
      expect(LogLevel.severe.name, 'SEVERE');
      expect(LogLevel.shout.name, 'SHOUT');
    });
  });

  group('FirebaseLogger lifecycle', () {
    test('is not initialized by default', () {
      expect(FirebaseLogger.isInitialized, false);
    });

    test('can initialize with console-only mode', () async {
      await FirebaseLogger.initialize(enableRemoteLogging: false);

      expect(FirebaseLogger.isInitialized, true);
      expect(FirebaseLogger.isLoggingEnabled, true);
      expect(FirebaseLogger.isRemoteLoggingEnabled, false);
      expect(FirebaseLogger.isConsoleLoggingEnabled, true);
      expect(FirebaseLogger.getMinimumLevel(), LogLevel.info);
    });

    test('throws if logging before initialize', () async {
      expect(
        () => FirebaseLogger.log(LogLevel.info, 'hello'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('context management', () {
    test('stores and clears global and user context', () async {
      await FirebaseLogger.initialize(enableRemoteLogging: false);

      FirebaseLogger.setGlobalContext(<String, dynamic>{'appVersion': '1.0.0'});
      FirebaseLogger.addGlobalContext(<String, dynamic>{'environment': 'prod'});
      FirebaseLogger.setUserContext(<String, dynamic>{'userId': '42'});
      FirebaseLogger.addUserContext(<String, dynamic>{'plan': 'pro'});

      expect(FirebaseLogger.getGlobalContext(), <String, dynamic>{
        'appVersion': '1.0.0',
        'environment': 'prod',
      });
      expect(FirebaseLogger.getUserContext(), <String, dynamic>{
        'userId': '42',
        'plan': 'pro',
      });

      FirebaseLogger.clearGlobalContext();
      FirebaseLogger.clearUserContext();

      expect(FirebaseLogger.getGlobalContext(), isEmpty);
      expect(FirebaseLogger.getUserContext(), isEmpty);
    });
  });

  group('payload generation', () {
    test('builds structured payload with merged context and extras', () async {
      await FirebaseLogger.initialize(
        enableRemoteLogging: false,
        globalContext: <String, dynamic>{'app': 'demo'},
      );
      FirebaseLogger.setUserContext(<String, dynamic>{'userId': 'abc'});

      final payload = FirebaseLogger.buildLogEntry(
        LogLevel.warning,
        'Something happened',
        tag: 'AUTH',
        additionalData: <String, dynamic>{'attempt': 2},
        clientTimestamp: DateTime.utc(2026, 3, 25, 10, 0, 0),
        serverTimestamp: 'server-ts',
      );

      expect(payload['timestamp'], 'server-ts');
      expect(payload['clientTimestamp'], '2026-03-25T10:00:00.000Z');
      expect(payload['level'], 'WARNING');
      expect(payload['levelValue'], 500);
      expect(payload['message'], 'Something happened');
      expect(payload['tag'], 'AUTH');
      expect(payload['context'], <String, dynamic>{
        'app': 'demo',
        'userId': 'abc',
      });
      expect(payload['extras'], <String, dynamic>{'attempt': 2});
    });

    test('includes error details when using error logging', () async {
      await FirebaseLogger.initialize(enableRemoteLogging: false);

      final payload = FirebaseLogger.buildLogEntry(
        LogLevel.severe,
        'Payment failed',
        error: StateError('gateway unavailable'),
        stackTrace: StackTrace.fromString('stack-line-1'),
        serverTimestamp: 'server-ts',
      );

      expect(payload['error'], <String, dynamic>{
        'message': 'Bad state: gateway unavailable',
        'type': 'StateError',
        'stackTrace': 'stack-line-1',
      });
    });
  });

  group('remote writing', () {
    test('applies configuration updates from a stream immediately', () async {
      final controller = StreamController<FirebaseLoggerConfiguration>();

      await FirebaseLogger.initialize(
        enableRemoteLogging: false,
        configurationStream: controller.stream,
      );

      controller.add(
        const FirebaseLoggerConfiguration(
          loggingEnabled: false,
          consoleLoggingEnabled: false,
          remoteLoggingEnabled: false,
          minimumLevel: LogLevel.shout,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(FirebaseLogger.isLoggingEnabled, false);
      expect(FirebaseLogger.isConsoleLoggingEnabled, false);
      expect(FirebaseLogger.isRemoteLoggingEnabled, false);
      expect(FirebaseLogger.getMinimumLevel(), LogLevel.shout);

      await controller.close();
      await FirebaseLogger.disposeConfigurationBinding();
    });

    test('can disable all logging at runtime', () async {
      var writeCount = 0;

      await FirebaseLogger.initialize(
        writer: (collectionName, logEntry) async {
          writeCount++;
        },
      );

      FirebaseLogger.setLoggingEnabled(false);
      await FirebaseLogger.error('should be ignored');
      expect(FirebaseLogger.isLoggingEnabled, false);
      expect(writeCount, 0);
    });

    test('can disable only remote logging at runtime', () async {
      var writeCount = 0;

      await FirebaseLogger.initialize(
        writer: (collectionName, logEntry) async {
          writeCount++;
        },
      );

      FirebaseLogger.setRemoteLoggingEnabled(false);
      await FirebaseLogger.warning('console only');

      expect(FirebaseLogger.isRemoteLoggingEnabled, false);
      expect(writeCount, 0);
    });

    test('can update logging configuration in one call', () async {
      await FirebaseLogger.initialize(enableRemoteLogging: false);

      FirebaseLogger.updateConfiguration(
        loggingEnabled: false,
        consoleLoggingEnabled: false,
        remoteLoggingEnabled: false,
        minimumLevel: LogLevel.severe,
      );

      expect(FirebaseLogger.isLoggingEnabled, false);
      expect(FirebaseLogger.isConsoleLoggingEnabled, false);
      expect(FirebaseLogger.isRemoteLoggingEnabled, false);
      expect(FirebaseLogger.getMinimumLevel(), LogLevel.severe);
    });

    test('filters logs below minimum level', () async {
      var writeCount = 0;

      await FirebaseLogger.initialize(
        minimumLevel: LogLevel.warning,
        writer: (collectionName, logEntry) async {
          writeCount++;
        },
      );

      await FirebaseLogger.info('ignored');
      await FirebaseLogger.warning('written');

      expect(writeCount, 1);
    });

    test('writes structured payload through the configured writer', () async {
      late String collectionName;
      late Map<String, dynamic> writtenLog;

      await FirebaseLogger.initialize(
        collectionName: 'app_logs',
        globalContext: <String, dynamic>{'environment': 'prod'},
        writer: (name, logEntry) async {
          collectionName = name;
          writtenLog = logEntry;
        },
      );
      FirebaseLogger.setUserContext(<String, dynamic>{'userId': '99'});

      await FirebaseLogger.log(
        LogLevel.info,
        'User updated profile',
        tag: 'PROFILE',
        additionalData: <String, dynamic>{'source': 'settings'},
      );

      expect(collectionName, 'app_logs');
      expect(writtenLog['level'], 'INFO');
      expect(writtenLog['tag'], 'PROFILE');
      expect(writtenLog['context'], <String, dynamic>{
        'environment': 'prod',
        'userId': '99',
      });
      expect(writtenLog['extras'], <String, dynamic>{'source': 'settings'});
    });
  });
}
