import 'package:flutter_test/flutter_test.dart';
import 'package:advanced_firebase_logger/firebase_logger.dart';

void main() {
  group('FirebaseLogger Tests', () {
    test('LogLevel enum values should be correct', () {
      expect(LogLevel.finest.value, 0);
      expect(LogLevel.finer.value, 100);
      expect(LogLevel.fine.value, 200);
      expect(LogLevel.config.value, 300);
      expect(LogLevel.info.value, 400);
      expect(LogLevel.warning.value, 500);
      expect(LogLevel.severe.value, 600);
      expect(LogLevel.shout.value, 700);
    });

    test('LogLevel enum names should be correct', () {
      expect(LogLevel.finest.name, 'FINEST');
      expect(LogLevel.finer.name, 'FINER');
      expect(LogLevel.fine.name, 'FINE');
      expect(LogLevel.config.name, 'CONFIG');
      expect(LogLevel.info.name, 'INFO');
      expect(LogLevel.warning.name, 'WARNING');
      expect(LogLevel.severe.name, 'SEVERE');
      expect(LogLevel.shout.name, 'SHOUT');
    });

    test('FirebaseLogger should not be initialized initially', () {
      expect(FirebaseLogger.isInitialized, false);
    });

    test('getMinimumLevel should return default level', () {
      expect(FirebaseLogger.getMinimumLevel(), LogLevel.info);
    });

    test('setMinimumLevel should update minimum level', () {
      FirebaseLogger.setMinimumLevel(LogLevel.warning);
      expect(FirebaseLogger.getMinimumLevel(), LogLevel.warning);
      
      // Reset to default
      FirebaseLogger.setMinimumLevel(LogLevel.info);
    });
  });
}
