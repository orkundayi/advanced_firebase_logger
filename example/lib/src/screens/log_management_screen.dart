import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../logger_settings_repository.dart';

class LogManagementScreen extends StatelessWidget {
  const LogManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: loggerSettingsDocument.snapshots(),
      builder: (context, snapshot) {
        final storedConfig = FirebaseLoggerConfiguration.fromMap(
          snapshot.data?.data() ?? defaultLoggerConfigurationMap,
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'This screen behaves like an admin panel. Changes are written to the Firestore settings document and the logger applies them immediately.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'First-start behavior',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'When the app starts with Firebase for the first time, it automatically creates app_settings/logger with default enabled values if the document does not exist.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      value: storedConfig.loggingEnabled,
                      onChanged: (value) {
                        saveLoggerConfiguration(
                          loggingEnabled: value,
                          remoteLoggingEnabled:
                              storedConfig.remoteLoggingEnabled,
                          consoleLoggingEnabled:
                              storedConfig.consoleLoggingEnabled,
                          minimumLevel: storedConfig.minimumLevel,
                        );
                      },
                      title: const Text('Enable or disable all logging'),
                      subtitle: const Text(
                        'When false, no logs are processed.',
                      ),
                    ),
                    SwitchListTile(
                      value: storedConfig.remoteLoggingEnabled,
                      onChanged: (value) {
                        saveLoggerConfiguration(
                          loggingEnabled: storedConfig.loggingEnabled,
                          remoteLoggingEnabled: value,
                          consoleLoggingEnabled:
                              storedConfig.consoleLoggingEnabled,
                          minimumLevel: storedConfig.minimumLevel,
                        );
                      },
                      title: const Text('Enable or disable Firebase writes'),
                      subtitle: const Text(
                        'When false, Firestore writes stop immediately.',
                      ),
                    ),
                    SwitchListTile(
                      value: storedConfig.consoleLoggingEnabled,
                      onChanged: (value) {
                        saveLoggerConfiguration(
                          loggingEnabled: storedConfig.loggingEnabled,
                          remoteLoggingEnabled:
                              storedConfig.remoteLoggingEnabled,
                          consoleLoggingEnabled: value,
                          minimumLevel: storedConfig.minimumLevel,
                        );
                      },
                      title: const Text('Enable or disable console output'),
                      subtitle: const Text(
                        'Controls debug console output independently.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LogLevel>(
                      initialValue: storedConfig.minimumLevel,
                      decoration: const InputDecoration(
                        labelText: 'Minimum log level',
                        border: OutlineInputBorder(),
                      ),
                      items: LogLevel.values.map((level) {
                        return DropdownMenuItem<LogLevel>(
                          value: level,
                          child: Text('${level.name} (${level.value})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          saveLoggerConfiguration(
                            loggingEnabled: storedConfig.loggingEnabled,
                            remoteLoggingEnabled:
                                storedConfig.remoteLoggingEnabled,
                            consoleLoggingEnabled:
                                storedConfig.consoleLoggingEnabled,
                            minimumLevel: value,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
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
              ),
            ),
          ],
        );
      },
    );
  }
}
