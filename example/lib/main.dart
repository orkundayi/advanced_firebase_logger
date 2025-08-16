import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
// import 'firebase_options_example.dart'; // Uncomment and use this after setting up Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your configuration
  bool firebaseInitialized = false;

  try {
    // Option 1: Use FlutterFire CLI (recommended)
    // await Firebase.initializeApp();

    // Option 2: Use the example configuration file
    // await Firebase.initializeApp(options: FirebaseOptionsExample.currentPlatform);

    // Option 3: Manual configuration (replace with your values)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'your-api-key-here',
        appId: 'your-app-id-here',
        messagingSenderId: 'your-sender-id-here',
        projectId: 'your-project-id-here',
        storageBucket: 'your-project-id.appspot.com',
      ),
    );

    // Initialize FirebaseLogger
    await FirebaseLogger.initialize(collectionName: 'app_logs', minimumLevel: LogLevel.info);
    firebaseInitialized = true;

    runApp(MyApp(firebaseInitialized: firebaseInitialized));
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    debugPrint('Running in demo mode - logs will only appear in debug console');
    runApp(MyApp(firebaseInitialized: false));
  }
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Logger Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: LoggerDemoPage(firebaseInitialized: firebaseInitialized),
    );
  }
}

class LoggerDemoPage extends StatefulWidget {
  final bool firebaseInitialized;

  const LoggerDemoPage({super.key, required this.firebaseInitialized});

  @override
  State<LoggerDemoPage> createState() => _LoggerDemoPageState();
}

class _LoggerDemoPageState extends State<LoggerDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Firebase Logger Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'This example demonstrates how to use FirebaseLogger with different log levels.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Log level buttons
            ElevatedButton(
              onPressed: () => _logMessage(LogLevel.info, 'User logged in successfully'),
              child: const Text('Log INFO'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _logMessage(LogLevel.warning, 'User session expired'),
              child: const Text('Log WARNING'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _logMessage(LogLevel.severe, 'Database connection failed'),
              child: const Text('Log SEVERE'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () => _logMessage(LogLevel.fine, 'User clicked button', tag: 'UI'),
              child: const Text('Log FINE with Tag'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(onPressed: () => _logMessageWithData(), child: const Text('Log with Additional Data')),
            const SizedBox(height: 8),

            ElevatedButton(onPressed: () => _changeLogLevel(), child: const Text('Change Minimum Log Level')),

            const SizedBox(height: 20),
            const Divider(),

            // Status information
            Text(
              'Firebase Status: ${widget.firebaseInitialized ? "Connected" : "Demo Mode"}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.firebaseInitialized ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              'Logger Status: ${FirebaseLogger.isInitialized ? "Initialized" : "Not Initialized"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Current Minimum Level: ${FirebaseLogger.getMinimumLevel().name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            const Text(
              'Check your debug console to see the logs in real-time!',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _logMessage(LogLevel level, String message, {String? tag}) async {
    try {
      if (widget.firebaseInitialized && FirebaseLogger.isInitialized) {
        // Use Firebase Logger
        switch (level) {
          case LogLevel.finest:
            await FirebaseLogger.finest(message, tag: tag);
            break;
          case LogLevel.finer:
            await FirebaseLogger.finer(message, tag: tag);
            break;
          case LogLevel.fine:
            await FirebaseLogger.fine(message, tag: tag);
            break;
          case LogLevel.config:
            await FirebaseLogger.config(message, tag: tag);
            break;
          case LogLevel.info:
            await FirebaseLogger.info(message, tag: tag);
            break;
          case LogLevel.warning:
            await FirebaseLogger.warning(message, tag: tag);
            break;
          case LogLevel.severe:
            await FirebaseLogger.severe(message, tag: tag);
            break;
          case LogLevel.shout:
            await FirebaseLogger.shout(message, tag: tag);
            break;
        }
      } else {
        // Demo mode - just print to console
        final timestamp = DateTime.now().toIso8601String();
        final logMessage = '[DEMO] [${level.name}] $timestamp${tag != null ? ' [$tag]' : ''}: $message';
        debugPrint(logMessage);
      }

      if (mounted) {
        final status = widget.firebaseInitialized ? 'Logged to Firebase' : 'Logged to Console (Demo Mode)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$status: ${level.name} - $message'), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging message: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _logMessageWithData() async {
    try {
      final additionalData = {
        'userId': 'user123',
        'action': 'button_click',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'deviceInfo': {'platform': 'Android', 'version': '1.0.0'},
      };

      if (widget.firebaseInitialized && FirebaseLogger.isInitialized) {
        await FirebaseLogger.info(
          'User performed action with additional context',
          additionalData: additionalData,
          tag: 'USER_ACTION',
        );
      } else {
        // Demo mode - just print to console
        final timestamp = DateTime.now().toIso8601String();
        final logMessage = '[DEMO] [INFO] $timestamp [USER_ACTION]: User performed action with additional context';
        debugPrint(logMessage);
        debugPrint('Additional Data: $additionalData');
      }

      if (mounted) {
        final status = widget.firebaseInitialized ? 'Logged to Firebase' : 'Logged to Console (Demo Mode)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$status: Message with additional data'), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging message: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _changeLogLevel() {
    if (!widget.firebaseInitialized || !FirebaseLogger.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log level can only be changed when Firebase is connected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Minimum Log Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LogLevel.values.map((level) {
            return ListTile(
              title: Text(level.name),
              subtitle: Text('Value: ${level.value}'),
              onTap: () {
                FirebaseLogger.setMinimumLevel(level);
                Navigator.of(context).pop();
                setState(() {}); // Refresh UI
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Minimum log level set to: ${level.name}')));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
