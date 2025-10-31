# የመ/አ/ግ/ጉባኤ (Android PDF Reader)

የመ/አ/ግ/ጉባኤ is an Android‑only Flutter app for browsing and reading PDF files shipped in the app’s assets. It focuses on smooth scrolling performance on mobile devices and a clean, simple UI.

## Features

- PDF viewer optimized for Android using `pdfx`
- Continuous vertical scroll, fast flicking, quick scroll thumb
- Asset‑based PDFs (no file permissions needed)
- Optional AppBar actions (zoom/info, etc.)

## Tech stack

- Flutter 3.35.x, Dart 3.9.x
- Android only (no iOS/web/desktop)
- Viewer: [`pdfx`](https://pub.dev/packages/pdfx)

## Project structure

```
lib/
  app.dart                   # MaterialApp setup and theming
  main.dart                  # Entry point (runApp)
  screens/
    pdf_list_screen.dart     # List of PDFs (from assets)
    pdf_viewer_screen.dart   # Android-only PDF viewer screen (pdfx)
  widgets/
    pdf_list_tile.dart       # List item UI component

assets/pdfs/                 # PDF files bundled with the app

android/                     # Android project (Gradle, Manifest)
```

## Requirements

- Flutter SDK (stable)
- Android SDK + platform tools (adb)
- A connected Android device or emulator

## Setup

Install dependencies:

```powershell
cd "C:\Users\Admin\Documents\fl1\pdf_reader_app"
flutter pub get
```

Run on a device (debug):

```powershell
flutter run -d <device_id>
```

## Build a release APK

Universal APK (works on most devices):

```powershell
flutter clean
flutter pub get
flutter build apk --release
or 
flutter build apk --release --target-platform android-arm64 //to build for android only to minimize the size of the apk
flutter install
```

Install the APK via adb:

```powershell
$adb = "C:\\Users\\Admin\\AppData\\Local\\Android\\sdk\\platform-tools\\adb.exe"
& $adb install -r "build\\app\\outputs\\flutter-apk\\app-release.apk"
```

If the installer UI shows only “Done”, launch the app from the app drawer or use:

```powershell
& $adb shell monkey -p com.mau.gibigubaie -c android.intent.category.LAUNCHER 1
```

## Configuration

- App display name (launcher title)
  - File: `android/app/src/main/AndroidManifest.xml`
  - Attribute: `android:label="የመ/አ/ግ/ጉባኤ"`

- Package name / applicationId
  - File: `android/app/build.gradle.kts`
  - Keys: `namespace`, `applicationId` (e.g., `com.mau.gibigubaie`)
  - Changing these yields a new app identity; uninstall old builds first.

- Minimum Android version
  - File: `android/app/build.gradle.kts`
  - Key: `minSdk` (e.g., `21` for Android 5.0+ or higher as required)

- PDFs bundled with the app
  - Place files under `assets/pdfs/`
  - Ensure `pubspec.yaml` has:

    ```yaml
    flutter:
      assets:
        - assets/pdfs/
    ```

## Troubleshooting

- App installs but won’t open on another device
  - Uninstall old package IDs first (e.g., `com.example.pdf_reader_app`, `com.mau.gibigubaie`).
  - Use the universal APK (`app-release.apk`).
  - If still failing, capture crash logs:

    ```powershell
    "C:\\Users\\Admin\\AppData\\Local\\Android\\sdk\\platform-tools\\adb.exe" logcat -b crash
    ```

- “Building with plugins requires symlink support” on Windows
  - Use an elevated (Administrator) PowerShell, or enable Developer Mode (Windows Settings → For developers).

- Release build stops/crashes (shrinker)
  - Disable shrinking to test (in `build.gradle.kts` release block):
    - `isMinifyEnabled = false`, `isShrinkResources = false`
  - Then rebuild; if fixed, add keep rules accordingly.

## License

This project is provided as‑is. Add your preferred license here (e.g., MIT/Apache-2.0). 
