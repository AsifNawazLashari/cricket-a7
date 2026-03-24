import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATKUoiVdv9W50rXobgh5qFhsCehmff1Yg',
    appId: '1:127154040305:android:cricket_a7_android',
    messagingSenderId: '127154040305',
    projectId: 'a7-cricket',
    storageBucket: 'a7-cricket.firebasestorage.app',
    databaseURL: 'https://a7-cricket-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyATKUoiVdv9W50rXobgh5qFhsCehmff1Yg',
    appId: '1:127154040305:web:4c72b512da3910e771e850',
    messagingSenderId: '127154040305',
    projectId: 'a7-cricket',
    storageBucket: 'a7-cricket.firebasestorage.app',
    databaseURL: 'https://a7-cricket-default-rtdb.firebaseio.com',
    measurementId: 'G-WSZZJ8T2YX',
    authDomain: 'a7-cricket.firebaseapp.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATKUoiVdv9W50rXobgh5qFhsCehmff1Yg',
    appId: '1:127154040305:ios:cricket_a7_ios',
    messagingSenderId: '127154040305',
    projectId: 'a7-cricket',
    storageBucket: 'a7-cricket.firebasestorage.app',
    databaseURL: 'https://a7-cricket-default-rtdb.firebaseio.com',
    iosBundleId: 'com.a7.cricket',
  );
}
