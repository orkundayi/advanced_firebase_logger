# Firebase Logger Example - Setup Guide

Bu example'ı çalıştırmak için Firebase projesi kurmanız gerekiyor. Aşağıdaki adımları takip edin:

## 🔥 Firebase Projesi Kurulumu

### 1. Firebase Console'da Proje Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Create a project" veya "Proje oluştur" butonuna tıklayın
3. Proje adını girin (örn: `advanced-firebase-logger-demo`)
4. Google Analytics'i etkinleştirin (önerilen)
5. "Create project" ile projeyi oluşturun

### 2. Flutter Uygulamasını Firebase'e Ekleme

#### Android için:
1. Firebase Console'da "Add app" > "Android" seçin
2. Android package name: `com.example.advancedFirebaseLoggerExample`
3. App nickname: `Firebase Logger Demo`
4. `google-services.json` dosyasını indirin
5. `example/android/app/` klasörüne kopyalayın

#### iOS için:
1. Firebase Console'da "Add app" > "iOS" seçin
2. iOS bundle ID: `com.example.advancedFirebaseLoggerExample`
3. App nickname: `Firebase Logger Demo`
4. `GoogleService-Info.plist` dosyasını indirin
5. `example/ios/Runner/` klasörüne kopyalayın

#### Web için:
1. Firebase Console'da "Add app" > "Web" seçin
2. App nickname: `Firebase Logger Demo`
3. "Register app" ile devam edin

### 3. Cloud Firestore Kurulumu

1. Firebase Console'da "Firestore Database" seçin
2. "Create database" ile veritabanı oluşturun
3. Test mode'da başlatın (güvenlik kurallarını daha sonra ayarlayabilirsiniz)
4. Location seçin (örn: `europe-west3`)

### 4. Güvenlik Kuralları

Firestore'da "Rules" sekmesinde aşağıdaki kuralları ekleyin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Logs collection - anyone can read/write for demo purposes
    // In production, add proper authentication and authorization
    match /logs/{document} {
      allow read, write: if true;
    }
    
    // App logs collection
    match /app_logs/{document} {
      allow read, write: if true;
    }
  }
}
```

## 📱 Uygulama Konfigürasyonu

### 1. Firebase Options Dosyası

`example/firebase_options_example.dart` dosyasını kopyalayın ve kendi Firebase proje bilgilerinizle güncelleyin:

```bash
cp example/firebase_options_example.dart example/lib/firebase_options.dart
```

### 2. Main.dart Güncelleme

`example/lib/main.dart` dosyasında Firebase import'unu aktif edin:

```dart
import 'firebase_options.dart';

// Firebase.initializeApp() çağrısını güncelleyin:
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 3. Dependencies Kurulumu

```bash
cd example
flutter pub get
```

## 🚀 Uygulamayı Çalıştırma

### Android:
```bash
flutter run -d android
```

### iOS:
```bash
flutter run -d ios
```

### Web:
```bash
flutter run -d chrome
```

## 🔍 Test Etme

1. Uygulama başladığında Firebase bağlantısı kurulacak
2. "Log INFO", "Log WARNING" gibi butonlara tıklayın
3. Debug konsolunda logları göreceksiniz
4. Firebase Console > Firestore Database'de logları kontrol edin

## ❌ Yaygın Hatalar ve Çözümleri

### "Firebase is not initialized" Hatası
- Firebase konfigürasyon dosyalarının doğru yerde olduğundan emin olun
- `google-services.json` ve `GoogleService-Info.plist` dosyalarını kontrol edin

### "Permission denied" Hatası
- Firestore güvenlik kurallarını kontrol edin
- Test mode'da olduğundan emin olun

### "Network error" Hatası
- İnternet bağlantınızı kontrol edin
- Firebase proje ayarlarında domain'in ekli olduğundan emin olun

## 📚 Ek Kaynaklar

- [Firebase Flutter Setup](https://firebase.flutter.dev/docs/overview/)
- [Cloud Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

## 🔐 Güvenlik Notu

Bu example test amaçlıdır ve production'da kullanılmamalıdır. Gerçek uygulamalarda:
- Kullanıcı kimlik doğrulaması ekleyin
- Firestore güvenlik kurallarını sıkılaştırın
- API anahtarlarını güvenli tutun
- Rate limiting uygulayın
