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
        return macos;
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
    apiKey: 'AIzaSyCxtRDu4mNkV_-QtWQKGBMiNcmBTGM6JoQ',
    appId: '1:619494175023:web:b11877c915c160ea1471da',
    messagingSenderId: '619494175023',
    projectId: 'call-app-c3cbf',
    authDomain: 'call-app-c3cbf.firebaseapp.com',
    storageBucket: 'call-app-c3cbf.appspot.com',
    measurementId: 'G-CLQ5ZE29P4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEM1c5DFYRFryT1uCe3ABN8zc0qtz25TY',
    appId: '1:619494175023:android:81c81fb5763491641471da',
    messagingSenderId: '619494175023',
    projectId: 'call-app-c3cbf',
    storageBucket: 'call-app-c3cbf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCU_axGkyHdiokz3JssLDrTvtBuvg_k_uk',
    appId: '1:619494175023:ios:763328b13a32b5fd1471da',
    messagingSenderId: '619494175023',
    projectId: 'call-app-c3cbf',
    storageBucket: 'call-app-c3cbf.appspot.com',
    iosBundleId: 'com.example.callApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCU_axGkyHdiokz3JssLDrTvtBuvg_k_uk',
    appId: '1:619494175023:ios:70a3747cd8e04e181471da',
    messagingSenderId: '619494175023',
    projectId: 'call-app-c3cbf',
    storageBucket: 'call-app-c3cbf.appspot.com',
    iosBundleId: 'com.example.callApp.RunnerTests',
  );
}
