# Advanced Firebase Logger

Advanced Firebase Logger is a Flutter package that acts as a thin logging layer for app teams who want to write logs from anywhere in their project and persist them in Firebase Cloud Firestore.

## What It Solves

- Lets application code call a single logger from any screen, service, or repository.
- Adds shared context such as app version, environment, or current user automatically.
- Writes logs to Firestore while still printing them to the debug console.
- Supports console-only mode so the same API works even when Firebase is unavailable.
- Stores errors as structured payloads with exception type and stack trace.

## Features

- 8 log levels: `FINEST`, `FINER`, `FINE`, `CONFIG`, `INFO`, `WARNING`, `SEVERE`, `SHOUT`
- Generic `log()` API for dynamic level selection
- Dedicated `error()` API for exceptions and stack traces
- Global context and user context management
- Configurable remote logging and console logging
- Firestore collection customization
- Minimum log level filtering

## Installation

Add the package to your app:

```yaml
dependencies:
  advanced_firebase_logger: ^0.1.1
  firebase_core: ^4.6.0
  cloud_firestore: ^6.2.0
```

## Quick Start

```dart
import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseLogger.initialize(
    collectionName: 'app_logs',
    minimumLevel: LogLevel.info,
    enableConsoleLogging: true,
    enableRemoteLogging: true,
    globalContext: <String, dynamic>{
      'app': 'my_app',
      'environment': 'production',
      'appVersion': '1.2.0',
    },
  );

  FirebaseLogger.setUserContext(<String, dynamic>{
    'userId': '42',
    'plan': 'pro',
  });

  runApp(const MyApp());
}
```

## Logging API

### Generic log entry

```dart
await FirebaseLogger.log(
  LogLevel.info,
  'Checkout started',
  tag: 'CHECKOUT',
  additionalData: <String, dynamic>{
    'step': 'cart_review',
    'itemCount': 3,
  },
);
```

### Error logging

```dart
try {
  throw StateError('Gateway returned 502');
} catch (error, stackTrace) {
  await FirebaseLogger.error(
    'Payment request failed',
    tag: 'PAYMENT',
    error: error,
    stackTrace: stackTrace,
    additionalData: <String, dynamic>{
      'endpoint': '/payments/confirm',
      'retryable': true,
    },
  );
}
```

### Convenience level methods

```dart
await FirebaseLogger.info('User signed in');
await FirebaseLogger.warning('Refresh token is about to expire');
await FirebaseLogger.severe('Realtime connection dropped');
```

## Context Management

Global context is attached to every log entry.

```dart
FirebaseLogger.setGlobalContext(<String, dynamic>{
  'environment': 'staging',
  'appVersion': '1.2.0',
});

FirebaseLogger.addGlobalContext(<String, dynamic>{
  'screen': 'checkout',
});
```

User context is also attached automatically and can be updated independently.

```dart
FirebaseLogger.setUserContext(<String, dynamic>{
  'userId': '42',
  'region': 'tr-istanbul',
});

FirebaseLogger.clearUserContext();
```

## Demo Mode

If you want to keep the same API when Firebase is unavailable, initialize the package with remote logging disabled.

```dart
await FirebaseLogger.initialize(
  enableRemoteLogging: false,
  enableConsoleLogging: true,
  globalContext: <String, dynamic>{
    'environment': 'demo',
  },
);
```

## Runtime Log Management

If you have an admin panel, a feature flag, or a Firestore document that controls logging, update the logger at runtime instead of rebuilding your app.

```dart
final loggingEnabled = config['loggingEnabled'] as bool;
final remoteLoggingEnabled = config['remoteLoggingEnabled'] as bool;

FirebaseLogger.updateConfiguration(
  loggingEnabled: loggingEnabled,
  remoteLoggingEnabled: remoteLoggingEnabled,
  minimumLevel: loggingEnabled ? LogLevel.info : LogLevel.shout,
);
```

You can also control each part separately:

```dart
FirebaseLogger.setLoggingEnabled(false);
FirebaseLogger.setRemoteLoggingEnabled(false);
FirebaseLogger.setConsoleLoggingEnabled(true);
```

Recommended production setup:

- `loggingEnabled`: emergency kill switch for all logs
- `remoteLoggingEnabled`: turn off Firestore writes when volume spikes
- `consoleLoggingEnabled`: keep local debugging active in development
- `minimumLevel`: raise to `warning` or `severe` during noisy periods

## Live Configuration Stream

If you want the app to react immediately after `initialize()`, pass a configuration stream to the logger and feed it from Firestore, Remote Config, or your own backend.

```dart
await FirebaseLogger.initialize(
  enableRemoteLogging: true,
  configurationStream: FirebaseFirestore.instance
      .collection('app_settings')
      .doc('logger')
      .snapshots()
      .map(
        (snapshot) => FirebaseLoggerConfiguration.fromMap(
          snapshot.data() ?? const <String, dynamic>{},
        ),
      ),
);
```

When `loggingEnabled` or `remoteLoggingEnabled` changes in that document, the app applies it immediately without restarting.

## Firestore Document Shape

Each log is stored in Firestore using a structured payload.

```json
{
  "timestamp": "Firebase server timestamp",
  "clientTimestamp": "2026-03-25T10:00:00.000Z",
  "level": "SEVERE",
  "levelValue": 600,
  "message": "Payment request failed",
  "tag": "PAYMENT",
  "context": {
    "app": "my_app",
    "environment": "production",
    "userId": "42"
  },
  "extras": {
    "endpoint": "/payments/confirm",
    "retryable": true
  },
  "error": {
    "message": "Bad state: Gateway returned 502",
    "type": "StateError",
    "stackTrace": "..."
  }
}
```

## Example App

The example app demonstrates:

- initializing the package in Firebase mode or demo mode
- using `log()` instead of `switch`-based level dispatch
- adding global and user context
- logging structured errors
- changing the minimum log level at runtime

Run it with:

```bash
cd example
flutter pub get
flutter run
```

If Firebase is not configured, the example still works in console-only mode.

## Recommendations

- Use `info` and `config` for business events you want to inspect later.
- Keep `fine`, `finer`, and `finest` mostly for local debugging.
- Store dynamic event-specific values in `additionalData`.
- Store stable app and user metadata in global or user context.
- Avoid writing high-frequency UI events directly to Firestore.

## License

This project is licensed under the MIT License.
