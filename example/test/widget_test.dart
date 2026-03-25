import 'package:flutter_test/flutter_test.dart';

import 'package:advanced_firebase_logger_example/src/example_app.dart';

void main() {
  testWidgets('shows locked screen when Firebase is unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExampleApp(firebaseInitialized: false));

    expect(find.text('Firebase Required'), findsOneWidget);
    expect(find.text('Example is currently locked'), findsOneWidget);
  });
}
