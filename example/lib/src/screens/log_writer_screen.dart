import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:flutter/material.dart';

import '../logging_action.dart';
import '../widgets/action_button.dart';
import '../widgets/context_card.dart';
import '../widgets/status_card.dart';

class LogWriterScreen extends StatelessWidget {
  const LogWriterScreen({
    super.key,
    required this.firebaseInitialized,
    required this.proUser,
    required this.onProUserChanged,
    required this.onActionCompleted,
  });

  final bool firebaseInitialized;
  final bool proUser;
  final ValueChanged<bool> onProUserChanged;
  final void Function(String message, {bool isError}) onActionCompleted;

  @override
  Widget build(BuildContext context) {
    final globalContext = FirebaseLogger.getGlobalContext();
    final userContext = FirebaseLogger.getUserContext();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StatusCard(firebaseInitialized: firebaseInitialized),
        const SizedBox(height: 16),
        ContextCard(title: 'Global Context', data: globalContext),
        const SizedBox(height: 12),
        ContextCard(title: 'User Context', data: userContext),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: proUser,
          onChanged: onProUserChanged,
          title: const Text('Use pro user context'),
          subtitle: const Text(
            'When the user context changes, new logs are written with different metadata.',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ActionButton(
              label: 'Checkout INFO',
              icon: Icons.shopping_cart_checkout,
              onPressed: () {
                return runLoggingAction(
                  onActionCompleted,
                  successMessage: 'Checkout info log sent',
                  action: () {
                    return FirebaseLogger.log(
                      LogLevel.info,
                      'Checkout flow started',
                      tag: 'CHECKOUT',
                      additionalData: <String, dynamic>{
                        'step': 'cart_review',
                        'itemCount': 3,
                        'cartValue': 249.90,
                      },
                    );
                  },
                );
              },
            ),
            ActionButton(
              label: 'Background WARNING',
              icon: Icons.sync_problem,
              onPressed: () {
                return runLoggingAction(
                  onActionCompleted,
                  successMessage: 'Warning log sent',
                  action: () {
                    return FirebaseLogger.log(
                      LogLevel.warning,
                      'Background sync is delayed',
                      tag: 'SYNC',
                      additionalData: <String, dynamic>{
                        'durationMs': 1840,
                        'queueDepth': 7,
                      },
                    );
                  },
                );
              },
            ),
            ActionButton(
              label: 'API Error',
              icon: Icons.report_problem,
              onPressed: () {
                return runLoggingAction(
                  onActionCompleted,
                  successMessage: 'Error log sent',
                  action: () async {
                    try {
                      throw StateError('Payment gateway responded with 502');
                    } catch (error, stackTrace) {
                      await FirebaseLogger.error(
                        'Checkout API call failed',
                        tag: 'PAYMENT',
                        error: error,
                        stackTrace: stackTrace,
                        additionalData: <String, dynamic>{
                          'endpoint': '/payments/confirm',
                          'retryable': true,
                        },
                      );
                    }
                  },
                );
              },
            ),
            ActionButton(
              label: 'Debug FINE',
              icon: Icons.bug_report,
              onPressed: () {
                return runLoggingAction(
                  onActionCompleted,
                  successMessage: 'Fine log sent',
                  action: () {
                    return FirebaseLogger.fine(
                      'Tapped experiment button',
                      tag: 'UI',
                      additionalData: <String, dynamic>{
                        'variant': 'A',
                        'buttonId': 'experiment_cta',
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
