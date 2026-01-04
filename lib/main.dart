// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/routes/app_pages.dart';
import 'package:jokko_agro/core/services/cart_service.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/app.dart';
import 'package:google_fonts/google_fonts.dart';

// lib/main.dart - Partie modifiée
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation
  await _initializeApp();

  runApp(const JokkoAgroApp());
}

Future<void> _initializeApp() async {
  try {
    // 1. Initialiser Firebase
    await FirebaseService.initialize();
    debugPrint('✅ Firebase initialisé');

    // 2. Initialiser GetX
    Get.lazyPut(() => AuthService(), fenix: true);
    Get.lazyPut(() => CartService(), fenix: true);

    // 3. Charger l'utilisateur et le panier
    final authService = Get.find<AuthService>();
    final cartService = Get.find<CartService>();

    await authService.loadCurrentUser();

    // 4. Charger le panier selon l'état de connexion
    if (authService.currentUser != null) {
      debugPrint('👤 Utilisateur connecté: ${authService.currentUser!.email}');

      // Attendre un peu que Firebase Auth soit complètement prêt
      await Future.delayed(const Duration(milliseconds: 500));

      // Charger le panier depuis Firebase
      await cartService.loadCart(forceRefresh: true);
    } else {
      debugPrint('👤 Utilisateur non connecté');

      // Charger uniquement le cache local
      await cartService.loadCart();
    }

    debugPrint('✅ Application initialisée avec succès');
  } catch (e) {
    debugPrint('❌ Erreur d\'initialisation: $e');
    // L'application continue avec des valeurs par défaut
  }
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
      initialRoute: '/',
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      home: const App(),
    );
  }
}

