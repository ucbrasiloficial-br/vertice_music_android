import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initializeIfAvailable() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }
      await Firebase.initializeApp();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase não configurado para build local/guest: $e');
    }
  }
}
