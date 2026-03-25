import 'package:flutter/material.dart';

class FirebaseSetupRequiredScreen extends StatelessWidget {
  const FirebaseSetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Required')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Example is currently locked',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'This showcase app waits for a Firebase connection before enabling the log writer, log viewer, and log management screens.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'After Firebase is connected, the app automatically creates app_settings/logger if it does not already exist.',
                    ),
                    SizedBox(height: 8),
                    Text('1. Log writer screen'),
                    Text('2. Log viewer screen'),
                    Text('3. Log management screen'),
                    SizedBox(height: 16),
                    Text(
                      'Next step: add Firebase configuration to the example and run the app again.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
