// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jokko_agro/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

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

  // Méthode pour charger l'utilisateur actuel
  Future<void> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(doc.data()!);
        
        // Mettre à jour les SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userFullName', _currentUser!.fullName);
        await prefs.setString('userEmail', _currentUser!.email);
        await prefs.setString('userPhone', _currentUser!.phone);
        await prefs.setString('userLocation', _currentUser!.location ?? '');
      }
    }
  }

  // Obtenir le nom complet de l'utilisateur
  Future<String?> getUserFullName() async {
    if (_currentUser != null) {
      return _currentUser!.fullName;
    }

    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('userFullName');
    
    // Si le nom n'est pas en cache, charger depuis Firestore
    if (fullName == null) {
      await loadCurrentUser();
      return _currentUser?.fullName;
    }

    return fullName;
  }

  // Obtenir l'email de l'utilisateur
  Future<String?> getUserEmail() async {
    if (_currentUser != null) {
      return _currentUser!.email;
    }

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    
    // Si l'email n'est pas en cache, charger depuis Firestore
    if (email == null) {
      await loadCurrentUser();
      return _currentUser?.email;
    }

    return email;
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    await loadCurrentUser();
    return _currentUser != null;
  }

  // Inscription
  Future<AppUser?> register({
    required String email,
    required String password,
    required String phone,
    required String fullName,
    required String role,
    String? location,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le document utilisateur dans Firestore
      final user = AppUser(
        uid: credential.user!.uid,
        email: email,
        phone: phone,
        fullName: fullName,
        role: role,
        location: location,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', credential.user!.uid);
      await prefs.setString('userRole', role);
      await prefs.setString('userFullName', fullName);
      await prefs.setString('userEmail', email);

      _currentUser = user;
      return user;
    } catch (e) {
      developer.log('Registration error: $e', name: 'AuthService');
      throw _handleAuthError(e);
    }
  }

  // Connexion
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupérer les données utilisateur depuis Firestore
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (doc.exists) {
        final user = AppUser.fromMap(doc.data()!);

        // Sauvegarder dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', credential.user!.uid);
        await prefs.setString('userRole', user.role);
        await prefs.setString('userFullName', user.fullName);
        await prefs.setString('userEmail', user.email);
        await prefs.setString('userPhone', user.phone);
        await prefs.setString('userLocation', user.location ?? '');

        _currentUser = user;
        return user;
      }
      return null;
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthService');
      throw _handleAuthError(e);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
  }

  // Obtenir le rôle de l'utilisateur actuel
  Future<String?> getUserRole() async {
    if (_currentUser != null) {
      return _currentUser!.role;
    }

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    
    // Si le rôle n'est pas en cache, charger depuis Firestore
    if (role == null) {
      await loadCurrentUser();
      return _currentUser?.role;
    }

    return role;
  }

  // Gestion des erreurs
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
    return 'Une erreur est survenue: $error';
  }
}