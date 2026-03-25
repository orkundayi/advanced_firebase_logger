Future<void> runLoggingAction(
  void Function(String message, {bool isError}) onActionCompleted, {
  required Future<void> Function() action,
  required String successMessage,
}) async {
  try {
    await action();
    onActionCompleted(successMessage);
  } catch (error) {
    onActionCompleted('Logging failed: $error', isError: true);
  }
}
