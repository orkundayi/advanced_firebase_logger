import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.firebaseInitialized});

  final bool firebaseInitialized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firebaseInitialized ? 'Firebase Connected' : 'Firebase Locked',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              firebaseInitialized
                  ? 'This showcase demonstrates log writing, Firestore-backed log viewing, and live log management in one app.'
                  : 'Showcase screens are disabled because Firebase is not connected.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(
                  label: Text(
                    'Logger: ${FirebaseLogger.isInitialized ? 'Ready' : 'Not initialized'}',
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                ),
                Chip(
                  label: Text(
                    'Logging: ${FirebaseLogger.isLoggingEnabled ? 'On' : 'Off'}',
                  ),
                ),
                Chip(
                  label: Text(
                    'Remote: ${FirebaseLogger.isRemoteLoggingEnabled ? 'On' : 'Off'}',
                  ),
                ),
                Chip(
                  label: Text(
                    'Console: ${FirebaseLogger.isConsoleLoggingEnabled ? 'On' : 'Off'}',
                  ),
                ),
                Chip(
                  label: Text(
                    'Min Level: ${FirebaseLogger.getMinimumLevel().name}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
