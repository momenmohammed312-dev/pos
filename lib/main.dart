import 'package:flutter/material.dart';
import 'package:pos_disck/ui/%D9%8Dscreens/products_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/ٍscreens/login_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'data/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase but continue in offline mode if it fails.
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCMi8-Es37geuAvMDMbqo-C6gu6s-6Gzsk",
        authDomain: "pos-disck.firebaseapp.com",
        projectId: "pos-disck",
        storageBucket: "pos-disck.firebasestorage.app",
        messagingSenderId: "1089822952745",
        appId: "1:1089822952745:web:a146fd7dbedd4fd5b9fb38",
        measurementId: "G-ETB2CDEDN5",
      ),
    );
    debugPrint('Firebase initialized');
  } catch (e) {
    debugPrint('Firebase init failed, running in offline mode: $e');
  }

  // Ensure local database is initialized for offline storage.
  try {
    await DbHelper.instance.database;
    debugPrint('Local database ready');
  } catch (e) {
    debugPrint('Failed to initialize local DB: $e');
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => ProductsScreen(),
      },
    );
  }
}
