# Firebase Logger Example

This example demonstrates how to use the `advanced_firebase_logger` package in a Flutter application.

## Features Demonstrated

- **Basic Logging**: Different log levels (INFO, WARNING, SEVERE, etc.)
- **Tagged Logging**: Adding tags to categorize logs
- **Additional Data**: Including structured data with logs
- **Dynamic Log Level**: Changing minimum log level at runtime
- **Real-time Debug Console**: See logs in Flutter debug console

## Setup

**⚠️ IMPORTANT**: This example requires a Firebase project setup to work properly.

### Quick Setup (Recommended)

1. **Follow the detailed setup guide**: See [SETUP.md](SETUP.md) for complete Firebase project setup instructions
2. **Dependencies**: Run `flutter pub get` in the example directory
3. **Run**: Execute `flutter run` to see the example in action

### What You Need to Do

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com/)
2. **Enable Cloud Firestore** in your Firebase project
3. **Add your app** to Firebase (Android/iOS/Web)
4. **Download config files** (`google-services.json`, `GoogleService-Info.plist`)
5. **Update Firebase configuration** in the example
6. **Set Firestore security rules** to allow read/write access

### Alternative: Use FlutterFire CLI

If you have FlutterFire CLI installed:
```bash
cd example
flutterfire configure
flutter pub get
flutter run
```

## What You'll See

- Buttons to test different log levels
- Real-time log output in the debug console
- Current logger status and configuration
- Interactive log level selection
- **Demo Mode**: If Firebase is not configured, the app will run in demo mode and show logs only in the console

## Debug Console Output

When you run the app, you'll see logs like this in your debug console:

```
[INFO] 2024-01-15T10:30:45.123Z: User logged in successfully
[WARNING] 2024-01-15T10:30:46.456Z: User session expired
[INFO] 2024-01-15T10:30:47.789Z [USER_ACTION]: User performed action with additional context
Additional Data: {userId: user123, action: button_click, timestamp: 1705315847789, deviceInfo: {platform: Android, version: 1.0.0}}
```

## Note

This example requires Firebase to be properly configured. If Firebase initialization fails, the app will still run but logging to Firestore won't work.
