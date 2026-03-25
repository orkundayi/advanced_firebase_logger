# Firebase Logger Example Setup

This example app uses Firebase Core and Cloud Firestore.

It expects a real Firebase project and a working FlutterFire configuration. When Firebase is available, the app:

- initializes Firebase with `DefaultFirebaseOptions.currentPlatform`
- auto-creates `app_settings/logger` if it does not exist
- writes sample logs into `app_logs`
- reads and applies logger settings from Firestore in real time

## Current Integration Status

This example is already structured for FlutterFire.

Generated and local Firebase files are expected to live under the `example/` app only.

Current active setup assumptions:

- Android, Web, and Windows were configured with FlutterFire CLI
- `lib/firebase_options.dart` is generated locally
- Android uses `android/app/google-services.json`

## 1. Create Or Open A Firebase Project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Create a project or select an existing one
3. If prompted, enable Google Analytics only if you actually need it

## 2. Enable Firestore

1. Open `Build > Firestore Database`
2. Click `Create database`
3. Choose `Start in test mode` for local testing, or use your own rules
4. Choose the Firestore region

If Firestore is not enabled, the example fails with `Cloud Firestore API has not been used in project ... before or it is disabled`.

## 3. Configure FlutterFire

From the `example/` folder, run:

```bash
dart pub global run flutterfire_cli:flutterfire configure --project=YOUR_PROJECT_ID --platforms=android,web,windows
```

This generates:

- `lib/firebase_options.dart`
- Android app registration metadata
- platform-specific Firebase wiring

For Android, Firebase may also require `android/app/google-services.json` depending on the platform setup and plugins involved.

## 4. Android SHA Fingerprints

For Android registration, add your SHA keys in Firebase Console.

The quickest way to get them is:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:PATH = "$env:JAVA_HOME\bin;" + $env:PATH
cd example/android
.\gradlew signingReport
```

Add the reported `SHA1` and `SHA-256` values to your Android Firebase app settings.

## 5. Firestore Rules For Local Testing

If you want the example to work immediately, allow access to the collections it uses:

```text
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /app_settings/{document} {
      allow read, write: if true;
    }

    match /app_logs/{document} {
      allow read, write: if true;
    }
  }
}
```

This is only appropriate for temporary local testing.

## 6. Install Dependencies

```bash
cd example
flutter pub get
```

## 7. Run The Example

Android:

```bash
flutter run -d android
```

Web:

```bash
flutter run -d chrome
```

Windows:

```bash
flutter run -d windows
```

## 8. Expected Firestore Data

The example uses these paths:

- `app_settings/logger`
- `app_logs/*`

On first successful startup, the app attempts to create `app_settings/logger` with default values.

## 9. Common Problems

### Firestore API disabled

Symptom:

- `Cloud Firestore API has not been used in project ... before or it is disabled`

Fix:

- enable Firestore in Firebase / Google Cloud Console

### Missing permissions

Symptom:

- `[cloud_firestore/permission-denied]`
- `Missing or insufficient permissions`

Fix:

- publish Firestore rules that allow the example to read and write `app_settings` and `app_logs`

### Firebase locked screen remains visible

Symptom:

- the app stays in locked mode

Fix:

- verify `lib/firebase_options.dart` exists
- verify Firestore is enabled
- verify Firestore rules allow reads for `app_settings/logger`

## 10. Security Note

Do not use the permissive rules above in production.

For real apps, you should:

- require authentication
- scope writes by user or service role
- restrict what can be updated in `app_settings`
- validate log payload structure
