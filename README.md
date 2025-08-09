# Advanced Firebase Logger

Firebase tabanlı Flutter uygulamaları için geliştirilmiş gelişmiş bir loglama paketi. Bu paket, farklı log seviyelerini destekler ve logları otomatik olarak Firebase Cloud Firestore'a kaydeder.

## Özellikler

- **8 farklı log seviyesi**: FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, SHOUT
- **Firebase Cloud Firestore entegrasyonu**: Loglar otomatik olarak Firestore'a kaydedilir
- **Özelleştirilebilir minimum log seviyesi**: Hangi seviyedeki logların kaydedileceğini belirleyebilirsiniz
- **Ek veri desteği**: Log mesajlarıyla birlikte ek meta veriler ekleyebilirsiniz
- **Tag desteği**: Logları kategorilere ayırmak için tag kullanabilirsiniz
- **Singleton pattern**: Uygulama genelinde tek instance kullanımı

## Başlangıç

### Gereksinimler

- Flutter SDK
- Firebase projesi ve Firebase yapılandırması
- Cloud Firestore etkinleştirilmiş olmalı

### Kurulum

`pubspec.yaml` dosyanıza ekleyin:

```yaml
dependencies:
  advanced_firebase_logger: ^0.0.1
  firebase_core: ^3.8.0
  cloud_firestore: ^5.4.4
```

### Firebase Yapılandırması

1. Firebase Console'da bir proje oluşturun
2. Flutter uygulamanızı Firebase projesine ekleyin
3. Cloud Firestore'u etkinleştirin
4. Firebase yapılandırma dosyalarını projenize ekleyin

## Kullanım

### Başlatma

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:advanced_firebase_logger/firebase_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase'i başlat
  await Firebase.initializeApp();
  
  // FirebaseLogger'ı başlat
  await FirebaseLogger.initialize(
    collectionName: 'app_logs', // Opsiyonel: varsayılan 'logs'
    minimumLevel: LogLevel.info, // Opsiyonel: varsayılan LogLevel.info
  );
  
  runApp(MyApp());
}
```

### Temel Kullanım

```dart
// Farklı seviyelererde log yazma
await FirebaseLogger.finest('En detaylı log mesajı');
await FirebaseLogger.finer('Detaylı log mesajı');
await FirebaseLogger.fine('Login Successful');
await FirebaseLogger.config('Yapılandırma değişti');
await FirebaseLogger.info('Kullanıcı giriş yaptı');
await FirebaseLogger.warning('Dikkat: Düşük hafıza');
await FirebaseLogger.severe('Kritik hata oluştu');
await FirebaseLogger.shout('Acil durum!');
```

### Ek Verilerle Kullanım

```dart
// Ek meta verilerle log yazma
await FirebaseLogger.info(
  'Kullanıcı profili güncellendi',
  additionalData: {
    'userId': '12345',
    'action': 'profile_update',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  },
  tag: 'USER_MANAGEMENT',
);
```

### Minimum Log Seviyesi Ayarlama

```dart
// Sadece WARNING ve üzeri seviyedeki logları kaydet
FirebaseLogger.setMinimumLevel(LogLevel.warning);

// Mevcut minimum seviyeyi öğren
LogLevel currentLevel = FirebaseLogger.getMinimumLevel();
```

## Log Seviyeleri

| Seviye | Değer | Açıklama |
|--------|--------|----------|
| FINEST | 0 | En detaylı debugging bilgileri |
| FINER | 100 | Detaylı debugging bilgileri |
| FINE | 200 | Debugging bilgileri |
| CONFIG | 300 | Yapılandırma bilgileri |
| INFO | 400 | Genel bilgi mesajları |
| WARNING | 500 | Uyarı mesajları |
| SEVERE | 600 | Ciddi hata mesajları |
| SHOUT | 700 | Kritik/acil durum mesajları |

## Firestore Veri Yapısı

Loglar aşağıdaki yapıda Firestore'a kaydedilir:

```json
{
  "timestamp": "Firebase Server Timestamp",
  "level": "INFO",
  "levelValue": 400,
  "message": "Log mesajı",
  "tag": "Optional tag",
  "additionalData": { /* Ek veriler */ }
}
```

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
