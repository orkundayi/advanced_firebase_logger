import 'package:flutter/material.dart';

import 'src/example_app.dart';
import 'src/example_bootstrap.dart';

Future<void> main() async {
  final result = await bootstrapExampleApp();
  runApp(ExampleApp(firebaseInitialized: result.firebaseInitialized));
}
