import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Callback used to persist a log entry.
typedef FirebaseLoggerWriter =
    Future<void> Function(String collectionName, Map<String, dynamic> logEntry);

/// Runtime logger configuration that can be pushed from an admin panel,
/// Firestore document, or feature-flag service.
class FirebaseLoggerConfiguration {
  const FirebaseLoggerConfiguration({
    this.loggingEnabled = true,
    this.consoleLoggingEnabled = true,
    this.remoteLoggingEnabled = true,
    this.minimumLevel = LogLevel.info,
  });

  final bool loggingEnabled;
  final bool consoleLoggingEnabled;
  final bool remoteLoggingEnabled;
  final LogLevel minimumLevel;

  /// Builds a logger configuration from a dynamic map source.
  factory FirebaseLoggerConfiguration.fromMap(Map<String, dynamic> map) {
    return FirebaseLoggerConfiguration(
      loggingEnabled: map['loggingEnabled'] as bool? ?? true,
      consoleLoggingEnabled: map['consoleLoggingEnabled'] as bool? ?? true,
      remoteLoggingEnabled: map['remoteLoggingEnabled'] as bool? ?? true,
      minimumLevel: FirebaseLoggerConfiguration.parseLogLevel(
        map['minimumLevel'],
      ),
    );
  }

  /// Parses a log level name and falls back to INFO for invalid values.
  static LogLevel parseLogLevel(Object? rawValue) {
    if (rawValue is LogLevel) {
      return rawValue;
    }

    final value = rawValue?.toString().trim().toUpperCase();
    for (final level in LogLevel.values) {
      if (level.name == value) {
        return level;
      }
    }

    return LogLevel.info;
  }
}

/// Firebase Logger için log seviyeleri.
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

  /// The numeric value representing the log level priority.
  final int value;

  /// The string name of the log level.
  final String name;
}

/// Firebase Cloud Firestore'a log yazmak için kullanılan ana sınıf.
class FirebaseLogger {
  static FirebaseLogger? _instance;
  static FirebaseFirestore? _firestore;
  static FirebaseLoggerWriter? _writer;
  static String _collectionName = 'logs';
  static LogLevel _minimumLevel = LogLevel.info;
  static bool _isLoggingEnabled = true;
  static bool _enableConsoleLogging = true;
  static bool _enableRemoteLogging = true;
  static bool _isInitialized = false;
  static StreamSubscription<FirebaseLoggerConfiguration>?
  _configurationSubscription;
  static Map<String, dynamic> _globalContext = <String, dynamic>{};
  static Map<String, dynamic> _userContext = <String, dynamic>{};

  FirebaseLogger._();

  /// FirebaseLogger'ın singleton instance'ı.
  static FirebaseLogger get instance {
    _instance ??= FirebaseLogger._();
    return _instance!;
  }

  /// Firebase Logger'ı başlatır.
  ///
  /// [collectionName] - Firestore'da kullanılacak koleksiyon adı.
  /// [minimumLevel] - Minimum log seviyesi.
  /// [enableConsoleLogging] - Logları debug console'a da yazar.
  /// [enableRemoteLogging] - Firestore'a yazmayı açar veya kapatır.
  /// [globalContext] - Tüm loglara otomatik eklenecek ortak alanlar.
  static Future<void> initialize({
    String collectionName = 'logs',
    LogLevel minimumLevel = LogLevel.info,
    bool enableConsoleLogging = true,
    bool enableRemoteLogging = true,
    Map<String, dynamic>? globalContext,
    FirebaseFirestore? firestoreInstance,
    FirebaseLoggerWriter? writer,
    Stream<FirebaseLoggerConfiguration>? configurationStream,
  }) async {
    try {
      if (enableRemoteLogging && writer == null && firestoreInstance == null) {
        if (Firebase.apps.isEmpty) {
          throw Exception(
            'Firebase is not initialized. Please initialize Firebase first or disable remote logging.',
          );
        }
      }

      _firestore = enableRemoteLogging && writer == null
          ? (firestoreInstance ?? FirebaseFirestore.instance)
          : firestoreInstance;
      _writer = writer;
      _collectionName = collectionName;
      _minimumLevel = minimumLevel;
      _enableConsoleLogging = enableConsoleLogging;
      _enableRemoteLogging = enableRemoteLogging;
      _globalContext = Map<String, dynamic>.from(
        globalContext ?? const <String, dynamic>{},
      );
      _userContext = <String, dynamic>{};
      _isInitialized = true;

      if (configurationStream != null) {
        await bindConfigurationStream(configurationStream);
      }
    } catch (e) {
      throw Exception('Failed to initialize FirebaseLogger: $e');
    }
  }

  /// Binds a runtime configuration stream and applies updates immediately.
  static Future<void> bindConfigurationStream(
    Stream<FirebaseLoggerConfiguration> configurationStream,
  ) async {
    await _configurationSubscription?.cancel();
    _configurationSubscription = configurationStream.listen(applyConfiguration);
  }

  /// Applies a runtime configuration snapshot.
  static void applyConfiguration(FirebaseLoggerConfiguration configuration) {
    updateConfiguration(
      loggingEnabled: configuration.loggingEnabled,
      consoleLoggingEnabled: configuration.consoleLoggingEnabled,
      remoteLoggingEnabled: configuration.remoteLoggingEnabled,
      minimumLevel: configuration.minimumLevel,
    );
  }

  /// Stops listening to external runtime configuration updates.
  static Future<void> disposeConfigurationBinding() async {
    await _configurationSubscription?.cancel();
    _configurationSubscription = null;
  }

  /// Genel amaçlı log yazma metodu.
  static Future<void> log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'FirebaseLogger is not initialized. Call FirebaseLogger.initialize() first.',
      );
    }

    if (!_isLoggingEnabled) {
      return;
    }

    if (level.value < _minimumLevel.value) {
      return;
    }

    final logData = buildLogEntry(
      level,
      message,
      additionalData: additionalData,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    _writeToConsole(
      level,
      message,
      tag: tag,
      context: logData['context'] as Map<String, dynamic>?,
      additionalData: logData['extras'] as Map<String, dynamic>?,
      error: error,
      stackTrace: stackTrace,
    );

    if (!_enableRemoteLogging) {
      return;
    }

    try {
      if (_writer != null) {
        await _writer!(_collectionName, logData);
        return;
      }

      await _firestore!.collection(_collectionName).add(logData);
    } catch (e, trace) {
      debugPrint('FirebaseLogger Error: $e');
      debugPrint('$trace');
    }
  }

  /// Exception ve stack trace içeren hata logu yazar.
  static Future<void> error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    LogLevel level = LogLevel.severe,
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      level,
      message,
      additionalData: additionalData,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// FINEST seviyesinde log yazar.
  static Future<void> finest(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      LogLevel.finest,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// FINER seviyesinde log yazar.
  static Future<void> finer(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      LogLevel.finer,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// FINE seviyesinde log yazar.
  static Future<void> fine(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(LogLevel.fine, message, additionalData: additionalData, tag: tag);
  }

  /// CONFIG seviyesinde log yazar.
  static Future<void> config(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      LogLevel.config,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// INFO seviyesinde log yazar.
  static Future<void> info(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(LogLevel.info, message, additionalData: additionalData, tag: tag);
  }

  /// WARNING seviyesinde log yazar.
  static Future<void> warning(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      LogLevel.warning,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// SEVERE seviyesinde log yazar.
  static Future<void> severe(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      LogLevel.severe,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// SHOUT seviyesinde log yazar.
  static Future<void> shout(
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
  }) async {
    await log(
      LogLevel.shout,
      message,
      additionalData: additionalData,
      tag: tag,
    );
  }

  /// Global context'i tamamen değiştirir.
  static void setGlobalContext(Map<String, dynamic> context) {
    _globalContext = Map<String, dynamic>.from(context);
  }

  /// Var olan global context'e yeni alanlar ekler.
  static void addGlobalContext(Map<String, dynamic> context) {
    _globalContext = <String, dynamic>{..._globalContext, ...context};
  }

  /// Global context'i temizler.
  static void clearGlobalContext() {
    _globalContext = <String, dynamic>{};
  }

  /// User context'i tamamen değiştirir.
  static void setUserContext(Map<String, dynamic> context) {
    _userContext = Map<String, dynamic>.from(context);
  }

  /// Var olan user context'e yeni alanlar ekler.
  static void addUserContext(Map<String, dynamic> context) {
    _userContext = <String, dynamic>{..._userContext, ...context};
  }

  /// User context'i temizler.
  static void clearUserContext() {
    _userContext = <String, dynamic>{};
  }

  /// Mevcut global context'in kopyasını döndürür.
  static Map<String, dynamic> getGlobalContext() {
    return Map<String, dynamic>.from(_globalContext);
  }

  /// Mevcut user context'in kopyasını döndürür.
  static Map<String, dynamic> getUserContext() {
    return Map<String, dynamic>.from(_userContext);
  }

  /// Minimum log seviyesini ayarlar.
  static void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
  }

  /// Tüm loglamayı runtime sırasında açar veya kapatır.
  static void setLoggingEnabled(bool enabled) {
    _isLoggingEnabled = enabled;
  }

  /// Sadece console logging'i runtime sırasında açar veya kapatır.
  static void setConsoleLoggingEnabled(bool enabled) {
    _enableConsoleLogging = enabled;
  }

  /// Sadece remote logging'i runtime sırasında açar veya kapatır.
  static void setRemoteLoggingEnabled(bool enabled) {
    _enableRemoteLogging = enabled;
  }

  /// Logger konfigürasyonunu tek çağrıda günceller.
  static void updateConfiguration({
    bool? loggingEnabled,
    bool? consoleLoggingEnabled,
    bool? remoteLoggingEnabled,
    LogLevel? minimumLevel,
  }) {
    if (loggingEnabled != null) {
      _isLoggingEnabled = loggingEnabled;
    }

    if (consoleLoggingEnabled != null) {
      _enableConsoleLogging = consoleLoggingEnabled;
    }

    if (remoteLoggingEnabled != null) {
      _enableRemoteLogging = remoteLoggingEnabled;
    }

    if (minimumLevel != null) {
      _minimumLevel = minimumLevel;
    }
  }

  /// Mevcut minimum log seviyesini döndürür.
  static LogLevel getMinimumLevel() {
    return _minimumLevel;
  }

  /// Genel logging durumunu döndürür.
  static bool get isLoggingEnabled => _isLoggingEnabled;

  /// Console logging durumunu döndürür.
  static bool get isConsoleLoggingEnabled => _enableConsoleLogging;

  /// Remote logging durumunu döndürür.
  static bool get isRemoteLoggingEnabled => _enableRemoteLogging;

  /// Logger'ın başlatılıp başlatılmadığını kontrol eder.
  static bool get isInitialized => _isInitialized;

  /// Testlerde payload doğrulamak için log girdisi üretir.
  @visibleForTesting
  static Map<String, dynamic> buildLogEntry(
    LogLevel level,
    String message, {
    Map<String, dynamic>? additionalData,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    DateTime? clientTimestamp,
    Object? serverTimestamp,
  }) {
    final mergedContext = <String, dynamic>{..._globalContext, ..._userContext};

    final logData = <String, dynamic>{
      'timestamp': serverTimestamp ?? FieldValue.serverTimestamp(),
      'clientTimestamp': (clientTimestamp ?? DateTime.now().toUtc())
          .toIso8601String(),
      'level': level.name,
      'levelValue': level.value,
      'message': message,
      'tag': ?tag,
      if (mergedContext.isNotEmpty) 'context': mergedContext,
      if (additionalData != null && additionalData.isNotEmpty)
        'extras': Map<String, dynamic>.from(additionalData),
      if (error != null || stackTrace != null)
        'error': <String, dynamic>{
          if (error != null) 'message': error.toString(),
          if (error != null) 'type': error.runtimeType.toString(),
          if (stackTrace != null) 'stackTrace': stackTrace.toString(),
        },
    };

    return logData;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
    _firestore = null;
    _writer = null;
    _configurationSubscription = null;
    _collectionName = 'logs';
    _minimumLevel = LogLevel.info;
    _isLoggingEnabled = true;
    _enableConsoleLogging = true;
    _enableRemoteLogging = true;
    _isInitialized = false;
    _globalContext = <String, dynamic>{};
    _userContext = <String, dynamic>{};
  }

  static void _writeToConsole(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Map<String, dynamic>? additionalData,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enableConsoleLogging) {
      return;
    }

    final buffer = StringBuffer(
      '[${level.name}] ${DateTime.now().toIso8601String()}',
    );
    if (tag != null) {
      buffer.write(' [$tag]');
    }
    buffer.write(': $message');

    if (context != null && context.isNotEmpty) {
      buffer.write('\nContext: $context');
    }

    if (additionalData != null && additionalData.isNotEmpty) {
      buffer.write('\nExtras: $additionalData');
    }

    if (error != null) {
      buffer.write('\nError: $error');
    }

    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }

    debugPrint(buffer.toString());
  }
}
