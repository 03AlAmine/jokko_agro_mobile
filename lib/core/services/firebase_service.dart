// lib/core/services/firebase_service.dart - DOIT ÊTRE COMME ÇA
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart'; // CET IMPORT EST CRUCIAL

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // DOIT UTILISER DefaultFirebaseOptions
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;
}