// lib/main.dart - VERSION CORRIGÉE
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/routes/app_pages.dart';
import 'package:jokko_agro/core/services/cart_service.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await FirebaseService.initialize();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const JokkoAgroApp());
}

class JokkoAgroApp extends StatelessWidget {
  const JokkoAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jokko Agro',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Utilisez un FutureBuilder pour attendre l'initialisation
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Erreur d\'initialisation: ${snapshot.error}'),
                ),
              ),
            );
          }
          
          return const App();
        },
      ),
      getPages: AppPages.pages,
    );
  }

  static Future<void> _initializeApp() async {
    // 1. Créer les instances des services
    final authService = AuthService();
    final cartService = CartService();
    
    // 2. Les enregistrer dans GetX
    Get.put<AuthService>(authService, permanent: true);
    Get.put<CartService>(cartService, permanent: true);
    
    // 3. Charger l'utilisateur si existant
    try {
      await authService.loadCurrentUser();
    } catch (e) {
      print('Error loading user: $e');
    }
    
    // 4. Charger le panier
    try {
      await cartService.loadCart();
    } catch (e) {
      print('Error loading cart: $e');
    }
  }
}