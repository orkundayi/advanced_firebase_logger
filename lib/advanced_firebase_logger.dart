import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Advanced Firebase Logger package for Flutter applications
/// Provides comprehensive logging to Firebase Cloud Firestore with debug console integration

/// Firebase Logger için log seviyeleri
enum LogLevel {
  finest(0, 'FINEST'),
  finer(100, 'FINER'),
  fine(200, 'FINE'),
  config(300, 'CONFIG'),
  info(400, 'INFO'),
  warning(500, 'WARNING'),
  severe(600, 'SEVERE'),
  shout(700, 'SHOUT');

  const LogLevel(this.value, this.name);

  /// The numeric value representing the log level priority
  final int value;

  /// The string name of the log level
  final String name;
}

/// Firebase Cloud Firestore'a log yazmak için kullanılan ana sınıf
class FirebaseLogger {
  static FirebaseLogger? _instance;
  static FirebaseFirestore? _firestore;
  static String _collectionName = 'logs';
  static LogLevel _minimumLevel = LogLevel.info;
  static bool _isInitialized = false;

  FirebaseLogger._();

  /// FirebaseLogger'ın singleton instance'ı
  static FirebaseLogger get instance {
    _instance ??= FirebaseLogger._();
    return _instance!;
  }

  /// Firebase Logger'ı başlatır
  ///
  /// [collectionName] - Firestore'da kullanılacak koleksiyon adı (varsayılan: 'logs')
  /// [minimumLevel] - Minimum log seviyesi (varsayılan: LogLevel.info)
  static Future<void> initialize({
    String collectionName = 'logs',
    LogLevel minimumLevel = LogLevel.info,
  }) async {
    try {
      // Firebase'in zaten başlatılmış olup olmadığını kontrol et
      if (Firebase.apps.isEmpty) {
        throw Exception(
          'Firebase is not initialized. Please initialize Firebase first.',
        );
      }

      _firestore = FirebaseFirestore.instance;
      _collectionName = collectionName;
      _minimumLevel = minimumLevel;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize FirebaseLogger: $e');
    }
  }

  /// Genel log yazma metodu
  static Future<void> _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'FirebaseLogger is not initialized. Call FirebaseLogger.initialize() first.',
      );
    }

    if (level.value < _minimumLevel.value) {
      return; // Minimum seviyenin altındaki logları atla
    }

    // Debug konsolunda log mesajını göster
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage =
          '[${level.name}] $timestamp${tag != null ? ' [$tag]' : ''}: $message';
      if (additionalData != null && additionalData.isNotEmpty) {
        print('$logMessage\nAdditional Data: $additionalData');
      } else {
        print(logMessage);
      }
    }

    try {
      final logData = {
        'timestamp': FieldValue.serverTimestamp(),
        'level': level.name,
        'levelValue': level.value,
        'message': message,
        'tag': tag,
        if (additionalData != null) ...additionalData,
      };

      await _firestore!.collection(_collectionName).add(logData);
    } catch (e) {
      // Silent fail - log yazma hatası uygulamayı durdurmamali
      if (kDebugMode) {
        print('FirebaseLogger Error: $e');
      }
    }
  }

  /// FINEST seviyesinde log yazar
  static Future<void> finest(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.finest,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// FINER seviyesinde log yazar
  static Future<void> finer(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.finer,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// FINE seviyesinde log yazar
  static Future<void> fine(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.fine,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// CONFIG seviyesinde log yazar
  static Future<void> config(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.config,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// INFO seviyesinde log yazar
  static Future<void> info(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.info,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// WARNING seviyesinde log yazar
  static Future<void> warning(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.warning,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// SEVERE seviyesinde log yazar
  static Future<void> severe(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.severe,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// SHOUT seviyesinde log yazar
  static Future<void> shout(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await _log(
      LogLevel.shout,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// Minimum log seviyesini ayarlar
  static void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
  }

  /// Mevcut minimum log seviyesini döndürür
  static LogLevel getMinimumLevel() {
    return _minimumLevel;
  }

  /// Logger'ın başlatılıp başlatılmadığını kontrol eder
  static bool get isInitialized => _isInitialized;
}
