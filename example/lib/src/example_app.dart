import 'package:advanced_firebase_logger/advanced_firebase_logger.dart';
import 'package:flutter/material.dart';

import 'example_constants.dart';
import 'screens/firebase_setup_required_screen.dart';
import 'screens/log_management_screen.dart';
import 'screens/log_viewer_screen.dart';
import 'screens/log_writer_screen.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key, required this.firebaseInitialized});

  final bool firebaseInitialized;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Firebase Logger Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: ExampleHome(firebaseInitialized: firebaseInitialized),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key, required this.firebaseInitialized});

  final bool firebaseInitialized;

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  var selectedIndex = 0;
  var proUser = true;

  @override
  void initState() {
    super.initState();
    FirebaseLogger.addGlobalContext(<String, dynamic>{
      'module': 'example_app',
      'collectionName': logCollectionName,
    });
    applyUserContext();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseInitialized) {
      return const FirebaseSetupRequiredScreen();
    }

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.edit_note_outlined),
        selectedIcon: Icon(Icons.edit_note),
        label: 'Write Logs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'View Logs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.tune_outlined),
        selectedIcon: Icon(Icons.tune),
        label: 'Management',
      ),
    ];

    final pages = <Widget>[
      LogWriterScreen(
        firebaseInitialized: widget.firebaseInitialized,
        proUser: proUser,
        onProUserChanged: (value) {
          setState(() {
            proUser = value;
            applyUserContext();
          });
        },
        onActionCompleted: showResult,
      ),
      const LogViewerScreen(),
      const LogManagementScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(destinations[selectedIndex].label),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  void applyUserContext() {
    FirebaseLogger.setUserContext(<String, dynamic>{
      'userId': proUser ? 'pro-user-42' : 'guest-user-17',
      'plan': proUser ? 'pro' : 'guest',
      'region': 'tr-istanbul',
    });
  }

  void showResult(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}
