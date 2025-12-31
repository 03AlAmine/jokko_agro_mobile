// lib/main.dart - DOIT ÊTRE COMME ÇA
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/routes/app_pages.dart';
import 'package:jokko_agro/core/services/firebase_service.dart'; // IMPORT
import 'package:jokko_agro/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase AVANT de runApp
  await FirebaseService.initialize();
  
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
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const App(), // Écran d'accueil
      getPages: AppPages.pages, // Routes
    );
  }
}