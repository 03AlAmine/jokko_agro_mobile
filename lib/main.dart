// lib/main.dart - VERSION FINALE SANS PRINT
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/routes/app_pages.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialiser Firebase
  try {
    await FirebaseService.initialize();
  } catch (e) {
    // Gérer l'erreur Firebase silencieusement ou logger
  }
  
  // 2. Injecter AuthService avec GetX
  Get.put<AuthService>(AuthService(), permanent: true);
  
  // 3. Charger l'utilisateur s'il existe
  try {
    await Get.find<AuthService>().loadCurrentUser();
  } catch (e) {
    // Aucun utilisateur en cache - c'est normal
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
        fontFamily: GoogleFonts.inter().fontFamily, // Utilisez Inter
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const App(),
      getPages: AppPages.pages,
    );
  }
}