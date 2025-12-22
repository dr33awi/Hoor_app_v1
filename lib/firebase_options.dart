// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyARb5Mo5j7HYfw9ZuKKZgR8zfdZkRK-f6U', // من google-services.json
    appId:
        '1:730727540126:android:844c37547696c3bf9b228f', // من google-services.json
    messagingSenderId: '730727540126',
    projectId: 'hoormanager-81b49',
    storageBucket: 'hoormanager-81b49.firebasestorage.app',
  );
}
