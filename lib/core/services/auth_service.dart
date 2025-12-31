// lib/core/services/auth_service.dart - MODIFIÉ
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jokko_agro/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer; // AJOUTER CET IMPORT

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current user
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Register user
  Future<AppUser?> register({
    required String email,
    required String password,
    required String phone,
    required String fullName,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final user = AppUser(
        uid: credential.user!.uid,
        email: email,
        phone: phone,
        fullName: fullName,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userRole', role);

      _currentUser = user;
      return user;
    } catch (e) {
      // REMPLACER print par log
      developer.log('Registration error: $e', name: 'AuthService');
      throw _handleAuthError(e);
    }
  }

  // Login user
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        final user = AppUser.fromMap(doc.data()!);
        
        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', user.role);

        _currentUser = user;
        return user;
      }
      return null;
    } catch (e) {
      // REMPLACER print par log
      developer.log('Login error: $e', name: 'AuthService');
      throw _handleAuthError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
  }

  // Get current user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  // Error handling
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Cette adresse email est déjà utilisée';
        case 'invalid-email':
          return 'Adresse email invalide';
        case 'operation-not-allowed':
          return 'Opération non autorisée';
        case 'weak-password':
          return 'Mot de passe trop faible';
        case 'user-disabled':
          return 'Compte désactivé';
        case 'user-not-found':
          return 'Utilisateur non trouvé';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        default:
          return 'Une erreur est survenue: ${error.message}';
      }
    }
    return 'Une erreur est survenue';
  }
}