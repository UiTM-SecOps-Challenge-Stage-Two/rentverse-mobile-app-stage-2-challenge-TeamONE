# RENTVERSE - Mobile Application

Platform properti rental modern yang menghubungkan pemilik properti (landlord) dengan penyewa (tenant) dengan fitur-fitur canggih seperti chat real-time, payment gateway, dan verifikasi identitas.

## 📱 Tentang Aplikasi

RENTVERSE adalah aplikasi mobile berbasis Flutter yang menyediakan platform lengkap untuk rental properti dengan dua role utama:

- **Tenant (Penyewa)**: Mencari dan menyewa properti
- **Landlord (Pemilik)**: Mengelola dan menyewakan properti

### ✨ Fitur Utama

#### Untuk Tenant
- 🏠 Browse dan cari properti berdasarkan lokasi
- 📍 Integrasi peta untuk melihat lokasi properti
- 💬 Chat real-time dengan pemilik properti
- 💳 Pembayaran terintegrasi dengan Midtrans
- 📄 Manajemen booking dan kontrak sewa
- ⭐ Review dan rating properti
- 🔔 Notifikasi real-time via Firebase
- 👤 Verifikasi identitas (iKYC)

#### Untuk Landlord
- 📊 Dashboard analytics properti
- ➕ Tambah dan kelola properti
- 📝 Manajemen booking dari tenant
- 💰 Wallet dan sistem payout
- 📈 Statistik performa properti
- 🔍 Verifikasi properti

## 📋 Prasyarat

Sebelum menjalankan aplikasi, pastikan Anda telah menginstal:

1. **Flutter SDK** (versi 3.5.1 atau lebih tinggi)
   ```bash
   flutter --version
   ```

2. **Android Studio** atau **VS Code** dengan Flutter extension

3. **Android SDK** (untuk development Android)
   - Android SDK Platform 21 atau lebih tinggi
   - Android Build Tools

4. **Xcode** (untuk development iOS - hanya di macOS)

5. **Git**

## 🚀 Cara Menjalankan Aplikasi

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Kode (untuk Retrofit & Floor)

Aplikasi ini menggunakan code generation untuk Retrofit (API client) dan Floor (database). Jalankan perintah berikut:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

> **Catatan**: Perintah ini akan generate file-file seperti `*.g.dart` yang diperlukan untuk menjalankan aplikasi.

### 3. Konfigurasi Firebase (Opsional)

Jika Anda ingin menggunakan fitur notifikasi:

1. Download file `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS) dari Firebase Console
2. Letakkan file tersebut di:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 5. Jalankan Aplikasi

#### Menggunakan Emulator/Simulator

```bash
# Cek device yang tersedia
flutter devices

# Jalankan di device yang dipilih
flutter run
```

#### Menggunakan Device Fisik

1. Aktifkan **Developer Mode** dan **USB Debugging** di perangkat Android Anda
2. Hubungkan perangkat ke komputer via USB
3. Jalankan:
   ```bash
   flutter run
   ```

#### Mode Debug vs Release

```bash
# Debug mode (default)
flutter run

# Release mode (lebih cepat, untuk testing)
flutter run --release

# Profile mode (untuk performance profiling)
flutter run --profile
```

### 6. Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK per ABI (ukuran lebih kecil)
flutter build apk --split-per-abi
```

APK akan tersimpan di: `build/app/outputs/flutter-apk/`

### 7. Build App Bundle (untuk Google Play Store)

```bash
flutter build appbundle --release
```

App Bundle akan tersimpan di: `build/app/outputs/bundle/release/`

## 🧪 Testing

### Menjalankan Tests

Proyek ini sudah dilengkapi dengan basic widget tests. Untuk menjalankan semua tests:

```bash
flutter test
```

### Menjalankan Test Spesifik

```bash
# Jalankan file test tertentu
flutter test test/widget_test.dart

# Jalankan test dengan nama tertentu
flutter test --plain-name "Simple text widget test"
```

### Test Coverage

Untuk melihat coverage dari tests:

```bash
flutter test --coverage
```

Coverage report akan tersimpan di `coverage/lcov.info`

### UI Testing Mode (Development)

Untuk development UI tanpa perlu login, gunakan `main_test.dart`:

```bash
flutter run lib/main_test.dart
```

File ini berguna untuk:
- Testing UI components tanpa autentikasi
- Rapid prototyping
- UI slicing
- Langsung menampilkan tenant navigation

> **Catatan**: `main_test.dart` melewati proses login dan langsung menampilkan halaman tenant untuk mempercepat development.

## 📁 Struktur Proyek

```
lib/
├── common/              # Komponen dan utilities bersama
│   ├── bloc/           # Global BLoCs (Auth, Navigation)
│   ├── colors/         # Custom color definitions
│   ├── screen/         # Reusable screens
│   └── widget/         # Reusable widgets
├── core/               # Core functionality
│   └── services/       # Services (DI, Notifications, etc.)
├── features/           # Feature modules
│   ├── auth/          # Authentication & Profile
│   ├── bookings/      # Booking management
│   ├── chat/          # Real-time chat
│   ├── disputes/      # Dispute handling
│   ├── map/           # Map integration
│   ├── notification/  # Notifications
│   ├── review/        # Reviews & ratings
│   └── wallet/        # Wallet & payments
└── role/              # Role-specific features
    ├── lanlord/       # Landlord features
    └── tenant/        # Tenant features
```

## 🔧 Troubleshooting

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Error: "CocoaPods not installed" (iOS)

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### Error: "Version solving failed"

```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### Error: LucideIcons tidak ditemukan

Pastikan Anda sudah menjalankan `flutter pub get` setelah clone repository.

## 🌐 Konfigurasi Backend

Aplikasi ini memerlukan backend API. Pastikan untuk mengkonfigurasi base URL API di file konfigurasi yang sesuai.

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web (experimental)
- ⚠️ Windows, macOS, Linux (belum dioptimalkan)

## 👥 Role & Permissions

Aplikasi mendukung 2 role utama:
1. **TENANT** - Penyewa properti
2. **LANDLORD** - Pemilik properti

Role ditentukan saat registrasi dan mempengaruhi UI/UX serta fitur yang tersedia.

## 📄 Lisensi

Proyek ini dibuat untuk keperluan pendidikan dan development.

## 🤝 Kontribusi

Untuk berkontribusi pada proyek ini:
1. Fork repository
2. Buat branch baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## 📞 Kontak & Support

Jika mengalami masalah atau memiliki pertanyaan, silakan buat issue di repository ini.

---

**Versi**: 1.0.0+1  
**Last Updated**: Desember 2025
