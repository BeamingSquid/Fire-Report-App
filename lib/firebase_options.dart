// Run `flutterfire configure` to regenerate this file with your Firebase project config.
// Or manually fill in the values from Firebase Console > Project Settings > General > Your apps.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIyFR-kC0cDp-ENrIob_0A74r2OKGmV1E',
    appId: '1:521316288334:android:491fde7a71159a6e3bc01f',
    messagingSenderId: '521316288334',
    projectId: 'fire-incident-report-maker',
    storageBucket: 'fire-incident-report-maker.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6TIIk8tmI97HxC7QsSfpD8X4egYoUVow',
    appId: '1:521316288334:web:64758772a20ca4b43bc01f',
    messagingSenderId: '521316288334',
    projectId: 'fire-incident-report-maker',
    authDomain: 'fire-incident-report-maker.firebaseapp.com',
    storageBucket: 'fire-incident-report-maker.firebasestorage.app',
    measurementId: 'G-QVRS4GYKSG',
  );
}
