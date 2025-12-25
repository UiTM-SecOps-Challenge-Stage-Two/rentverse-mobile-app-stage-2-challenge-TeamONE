import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;
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
    apiKey: 'AIzaSyDgRHTSI3oFrMg0-VtbQTjXqhFvgR0c4EA',
    appId: '1:656592412430:web:dc87278a5e04b6ae47c15f',
    messagingSenderId: '656592412430',
    projectId: 'imperial-signer-453516-t3',
    authDomain: 'imperial-signer-453516-t3.firebaseapp.com',
    storageBucket: 'imperial-signer-453516-t3.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRab9M4o64UF456brG2Bno9R2t4Btqiv0',
    appId: '1:656592412430:android:718b336b8ecf2be647c15f',
    messagingSenderId: '656592412430',
    projectId: 'imperial-signer-453516-t3',
    storageBucket: 'imperial-signer-453516-t3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAvcgtM8FgNymOhkguMz26W-xrYkIeuh4',
    appId: '1:656592412430:ios:04cdaefe1ac93aea47c15f',
    messagingSenderId: '656592412430',
    projectId: 'imperial-signer-453516-t3',
    storageBucket: 'imperial-signer-453516-t3.firebasestorage.app',
    iosBundleId: 'com.example.rentverse',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAvcgtM8FgNymOhkguMz26W-xrYkIeuh4',
    appId: '1:656592412430:ios:04cdaefe1ac93aea47c15f',
    messagingSenderId: '656592412430',
    projectId: 'imperial-signer-453516-t3',
    storageBucket: 'imperial-signer-453516-t3.firebasestorage.app',
    iosBundleId: 'com.example.rentverse',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDgRHTSI3oFrMg0-VtbQTjXqhFvgR0c4EA',
    appId: '1:656592412430:web:7f985564fadfe91847c15f',
    messagingSenderId: '656592412430',
    projectId: 'imperial-signer-453516-t3',
    authDomain: 'imperial-signer-453516-t3.firebaseapp.com',
    storageBucket: 'imperial-signer-453516-t3.firebasestorage.app',
  );
}
