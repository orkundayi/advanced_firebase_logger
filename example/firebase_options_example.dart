// This is an example Firebase configuration file
// Copy this file to your project and modify it with your actual Firebase project details
//
// To get your Firebase configuration:
// 1. Go to https://console.firebase.google.com/
// 2. Create a new project or select existing one
// 3. Add your Flutter app to the project
// 4. Download the google-services.json (Android) and GoogleService-Info.plist (iOS)
// 5. Copy the configuration values below

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Example Firebase configuration options
///
/// **IMPORTANT**: Replace these values with your actual Firebase project configuration
/// You can find these values in your Firebase Console under Project Settings > General
class FirebaseOptionsExample {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // Replace these values with your actual Firebase project configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key-here',
    appId: 'your-web-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'your-project-id-here',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-project-id.appspot.com',
    measurementId: 'your-measurement-id-here',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key-here',
    appId: 'your-android-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'your-project-id-here',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key-here',
    appId: 'your-ios-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'your-project-id-here',
    storageBucket: 'your-project-id.appspot.com',
    iosClientId: 'your-ios-client-id-here',
    iosBundleId: 'com.example.advancedFirebaseLoggerExample',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key-here',
    appId: 'your-macos-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'your-project-id-here',
    storageBucket: 'your-project-id.appspot.com',
    iosClientId: 'your-macos-client-id-here',
    iosBundleId: 'com.example.advancedFirebaseLoggerExample',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key-here',
    appId: 'your-windows-app-id-here',
    messagingSenderId: 'your-sender-id-here',
    projectId: 'your-project-id-here',
    storageBucket: 'your-project-id.appspot.com',
  );
}
