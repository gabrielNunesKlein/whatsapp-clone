// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDyJjviM-Ri6KYkz5vPSE91wumqvP7Jniw',
    appId: '1:557650095169:web:41c8e65245a0c575d56ac0',
    messagingSenderId: '557650095169',
    projectId: 'whatsweb-b1c01',
    authDomain: 'whatsweb-b1c01.firebaseapp.com',
    storageBucket: 'whatsweb-b1c01.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJ0OiVcTlIz-k0v1VV8NULijritjpRYgQ',
    appId: '1:557650095169:android:ddc5d1a6c6c3b862d56ac0',
    messagingSenderId: '557650095169',
    projectId: 'whatsweb-b1c01',
    storageBucket: 'whatsweb-b1c01.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBAxlcC7XjAXdLcAud1hNvG0sJEKYl73Y',
    appId: '1:557650095169:ios:73ffd93dcf548ec8d56ac0',
    messagingSenderId: '557650095169',
    projectId: 'whatsweb-b1c01',
    storageBucket: 'whatsweb-b1c01.appspot.com',
    iosBundleId: 'com.example.whatssapWeb',
  );
}