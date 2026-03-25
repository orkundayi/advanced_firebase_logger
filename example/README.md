# Firebase Logger Example

This example is now a small showcase app with multiple screens so you can test the package more realistically after connecting Firebase.

## Screens

### 1. Write Logs

This screen is used to generate sample logs.

- info log
- warning log
- error log with stack trace
- fine log for debug scenarios
- shared global and user context preview

### 2. View Logs

This screen reads the latest log entries from Firestore and shows them in a list.

- message
- level
- tag
- context
- extras
- error details

### 3. Management

This screen behaves like a simple admin panel.

- turn all logging on or off
- turn Firestore writes on or off
- turn console logging on or off
- change the minimum log level instantly
- create the default logger config document automatically on first startup

## Firebase Requirement

This example expects Firebase to be configured.

If Firebase is not initialized:

- the showcase screens are hidden
- a locked setup screen is shown instead
- after you add Firebase configuration and restart, the full app appears

If Firebase is initialized and `app_settings/logger` does not exist yet, the example creates it automatically with safe defaults.

## Setup

1. Read [SETUP.md](SETUP.md)
2. Configure Firebase for the example app
3. Run `flutter pub get`
4. Run `flutter run`

If you use FlutterFire CLI:

```bash
cd example
flutterfire configure
flutter pub get
flutter run
```

## What To Test After Connecting Firebase

1. Open `Write Logs` and send a few logs
2. Open `View Logs` and confirm the entries appear in the Firestore-backed list
3. Open `Management` and turn `Remote logging` off
4. Go back to `Write Logs` and send logs again
5. Confirm new logs no longer arrive in Firestore
6. Turn `Logging` off and verify logging stops immediately

## Note

This example is designed to become useful after you plug in your own Firebase project.
