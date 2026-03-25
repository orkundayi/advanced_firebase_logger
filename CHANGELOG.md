## 0.2.0

### Added
* Added a generic logging API with `log()` and structured `error()` support.
* Added runtime logger configuration controls for enabling or disabling all logging, console logging, and remote logging independently.
* Added live configuration stream support so apps can react immediately to remote logger setting changes.
* Added global context and user context helpers for richer log payloads.
* Added writer injection and payload helpers to simplify testing and custom sink integrations.
* Added a multi-screen example app with log writing, Firestore log viewing, and runtime management screens.
* Added Firebase bootstrap integration for the example app using generated FlutterFire options.

### Changed
* Refactored the example app into a clearer multi-file structure.
* Updated the example setup guide to the current FlutterFire and Firestore workflow.
* Improved package tests to cover configuration changes, runtime toggles, payload generation, and structured error logging.

### Fixed
* Fixed initialization behavior when using a custom writer without a real Firebase app instance.
* Fixed example bootstrap flow to stay locked only when Firebase or Firestore access is actually unavailable.

## 0.1.1

### 🔧 Hata Düzeltmeleri
* **Paket Formatı**: Dart formatter uyumluluğu sağlandı
* **Git Durumu**: Commit edilmemiş dosya sorunları çözüldü
* **Publish Sorunları**: Paket yayınlama hataları giderildi

## 0.1.0

### ✨ Yeni Özellikler
* **Debug Konsol Entegrasyonu**: Loglar artık Flutter debug konsolunda gerçek zamanlı olarak görüntülenir
* **Gelişmiş Log Formatı**: Zaman damgası ve etiketlerle iyileştirilmiş log formatı
* **Demo Mod Desteği**: Example uygulama Firebase konfigürasyonu olmadan da çalışabilir
* **Daha İyi Hata Yönetimi**: Firebase mevcut olmadığında graceful fallback

### 🔧 İyileştirmeler
* **%100 Dartdoc Kapsamı**: Tüm public API elementleri artık dokümante edilmiş
* **Example Uygulama**: Firebase kurulum rehberi ile tam çalışan örnek
* **Kurulum Dokümantasyonu**: Detaylı Firebase konfigürasyon talimatları
* **Platform Desteği**: Tüm Flutter platformları için geliştirilmiş destek

### 📚 Dokümantasyon
* **Kapsamlı README**: Yeni özellikler ve örneklerle güncellenmiş
* **Kurulum Rehberi**: Adım adım Firebase konfigürasyon talimatları
* **Example Dokümantasyonu**: Demo mod ile tam example uygulama

### 🐛 Hata Düzeltmeleri
* **Log Görünürlüğü**: Debug konsolunda logların görünmediği sorun düzeltildi
* **Hata Yönetimi**: Firebase başlatma hatalarında daha iyi hata yönetimi

## 0.0.1

* Advanced Firebase Logger'ın ilk sürümü
* 8 farklı log seviyesi desteği (FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, SHOUT)
* Firebase Cloud Firestore entegrasyonu
* Özelleştirilebilir minimum log seviyesi
* Zengin metadata ve tag desteği
* Singleton pattern implementasyonu
* Kapsamlı hata yönetimi
* Gelişmiş yapılandırma seçenekleri
