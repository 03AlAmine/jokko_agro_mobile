// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jokko_agro/core/services/cart_service.dart';
import 'dart:developer' as developer;

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Variables réactives
  final Rx<AppUser?> _currentUser = Rx<AppUser?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  
  // Getters
  AppUser? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoggedIn => _currentUser.value != null;
  
  @override
  void onInit() {
    super.onInit();
    developer.log('🔐 AuthService initialisé', name: 'AuthService');
    // Charger l'utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCurrentUser();
    });
  }
  
  /// Charge l'utilisateur actuel depuis Firebase et le cache
  Future<void> loadCurrentUser() async {
    try {
      _isLoading.value = true;
      developer.log('🔄 Chargement de l\'utilisateur...', name: 'AuthService');
      
      final User? firebaseUser = _auth.currentUser;
      
      if (firebaseUser != null) {
        developer.log('👤 Utilisateur Firebase trouvé: ${firebaseUser.email}', name: 'AuthService');
        
        // Essayer de charger depuis Firestore
        try {
          final doc = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get()
              .timeout(const Duration(seconds: 10));
          
          if (doc.exists && doc.data() != null) {
            final user = AppUser.fromMap(doc.data()!);
            _currentUser.value = user;
            
            // Mettre à jour le cache local
            await _updateLocalCache(user);
            
            developer.log('✅ Utilisateur chargé depuis Firestore: ${user.fullName}', name: 'AuthService');
          } else {
            developer.log('⚠️ Utilisateur non trouvé dans Firestore', name: 'AuthService');
            // Essayer de charger depuis le cache local
            await _loadFromLocalCache();
          }
        } catch (e) {
          developer.log('⚠️ Erreur Firestore: $e - Chargement depuis cache', name: 'AuthService');
          await _loadFromLocalCache();
        }
      } else {
        developer.log('👤 Aucun utilisateur Firebase', name: 'AuthService');
        await _loadFromLocalCache();
      }
      
    } catch (e) {
      developer.log('❌ Erreur lors du chargement de l\'utilisateur: $e', name: 'AuthService');
      _errorMessage.value = 'Impossible de charger l\'utilisateur: $e';
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Charge l'utilisateur depuis le cache local
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final uid = prefs.getString('userUid');
      final email = prefs.getString('userEmail');
      final fullName = prefs.getString('userFullName');
      final phone = prefs.getString('userPhone');
      final role = prefs.getString('userRole');
      final location = prefs.getString('userLocation');
      
      if (uid != null && email != null && fullName != null && role != null) {
        final cachedUser = AppUser(
          uid: uid,
          email: email,
          phone: phone ?? '',
          fullName: fullName,
          role: role,
          location: location,
          createdAt: DateTime.now(),
        );
        
        _currentUser.value = cachedUser;
        developer.log('📱 Utilisateur chargé depuis cache: $fullName', name: 'AuthService');
      } else {
        developer.log('📭 Aucun utilisateur en cache', name: 'AuthService');
        _currentUser.value = null;
      }
    } catch (e) {
      developer.log('❌ Erreur chargement cache: $e', name: 'AuthService');
      _currentUser.value = null;
    }
  }
  
  /// Met à jour le cache local
  Future<void> _updateLocalCache(AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('userUid', user.uid);
      await prefs.setString('userEmail', user.email);
      await prefs.setString('userFullName', user.fullName);
      await prefs.setString('userPhone', user.phone);
      await prefs.setString('userRole', user.role);
      if (user.location != null) {
        await prefs.setString('userLocation', user.location!);
      }
      await prefs.setBool('isLoggedIn', true);
      
      developer.log('📱 Cache local mis à jour pour ${user.fullName}', name: 'AuthService');
    } catch (e) {
      developer.log('⚠️ Erreur mise à jour cache: $e', name: 'AuthService');
    }
  }
  
  /// Inscription d'un nouvel utilisateur
  Future<AppUser?> register({
    required String email,
    required String password,
    required String phone,
    required String fullName,
    required String role,
    String? location,
    String? profileImageUrl,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      developer.log('📝 Inscription en cours pour: $email', name: 'AuthService');
      
      // 1. Créer l'utilisateur dans Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      developer.log('✅ Compte Firebase créé: ${credential.user!.uid}', name: 'AuthService');
      
      // 2. Créer l'objet utilisateur
      final user = AppUser(
        uid: credential.user!.uid,
        email: email,
        phone: phone,
        fullName: fullName,
        role: role,
        location: location,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
      );
      
      // 3. Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());
      
      developer.log('✅ Utilisateur sauvegardé dans Firestore', name: 'AuthService');
      
      // 4. Mettre à jour le cache local
      await _updateLocalCache(user);
      
      // 5. Mettre à jour l'utilisateur courant
      _currentUser.value = user;
      
      // 6. Synchroniser le panier après inscription
      await _syncCartAfterAuth();
      
      developer.log('🎉 Inscription réussie pour ${user.fullName}', name: 'AuthService');
      
      return user;
    } on FirebaseAuthException catch (e) {
      final errorMsg = _handleAuthError(e);
      _errorMessage.value = errorMsg;
      developer.log('❌ Erreur Firebase Auth: $errorMsg', name: 'AuthService');
      return null;
    } catch (e) {
      _errorMessage.value = 'Une erreur est survenue: $e';
      developer.log('❌ Erreur inattendue: $e', name: 'AuthService');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Connexion d'un utilisateur existant
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      developer.log('🔑 Connexion en cours pour: $email', name: 'AuthService');
      
      // 1. Authentifier avec Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      developer.log('✅ Authentification Firebase réussie', name: 'AuthService');
      
      // 2. Récupérer les données utilisateur depuis Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      
      if (!doc.exists) {
        _errorMessage.value = 'Compte utilisateur non trouvé';
        developer.log('❌ Compte non trouvé dans Firestore', name: 'AuthService');
        return null;
      }
      
      // 3. Créer l'objet utilisateur
      final user = AppUser.fromMap(doc.data()!);
      
      // 4. Mettre à jour le cache local
      await _updateLocalCache(user);
      
      // 5. Mettre à jour l'utilisateur courant
      _currentUser.value = user;
      
      // 6. Synchroniser le panier après connexion
      await _syncCartAfterAuth();
      
      developer.log('🎉 Connexion réussie pour ${user.fullName}', name: 'AuthService');
      
      return user;
    } on FirebaseAuthException catch (e) {
      final errorMsg = _handleAuthError(e);
      _errorMessage.value = errorMsg;
      developer.log('❌ Erreur Firebase Auth: $errorMsg', name: 'AuthService');
      return null;
    } catch (e) {
      _errorMessage.value = 'Une erreur est survenue: $e';
      developer.log('❌ Erreur inattendue: $e', name: 'AuthService');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Synchronise le panier après authentification
  Future<void> _syncCartAfterAuth() async {
    try {
      final cartService = Get.find<CartService>();
      
      // Attendre un peu que tout soit stable
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Synchroniser le panier
      await cartService.loadCart(forceRefresh: true);
      
      developer.log('🛒 Panier synchronisé après auth', name: 'AuthService');
    } catch (e) {
      developer.log('⚠️ Erreur synchronisation panier: $e', name: 'AuthService');
    }
  }
  
  /// Déconnexion de l'utilisateur
  Future<bool> logout() async {
    try {
      _isLoading.value = true;
      developer.log('🚪 Déconnexion en cours...', name: 'AuthService');
      
      // 1. Sauvegarder le panier localement avant déconnexion
      try {
        final cartService = Get.find<CartService>();
        await cartService.saveLocalCache(cartService.cartItems);
        developer.log('🛒 Panier sauvegardé localement', name: 'AuthService');
      } catch (e) {
        developer.log('⚠️ Erreur sauvegarde panier: $e', name: 'AuthService');
      }
      
      // 2. Déconnecter de Firebase Auth
      await _auth.signOut();
      
      // 3. Effacer le cache local (sauf certaines préférences)
      final prefs = await SharedPreferences.getInstance();
      
      // Garder certaines préférences si besoin
      final cartItems = prefs.getStringList('cart_items') ?? [];
      
      // Effacer toutes les données utilisateur
      await prefs.clear();
      
      // Restaurer le panier (pour mode invité)
      if (cartItems.isNotEmpty) {
        await prefs.setStringList('cart_items', cartItems);
      }
      
      // 4. Réinitialiser l'utilisateur courant
      _currentUser.value = null;
      _errorMessage.value = '';
      
      // 5. Vider le panier en mémoire
      final cartService = Get.find<CartService>();
      cartService.cartItems.clear();
      
      developer.log('✅ Déconnexion réussie', name: 'AuthService');
      
      return true;
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la déconnexion: $e';
      developer.log('❌ Erreur déconnexion: $e', name: 'AuthService');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Vérifie si l'utilisateur est connecté
  Future<bool> checkLoginStatus() async {
    try {
      await loadCurrentUser();
      return _currentUser.value != null;
    } catch (e) {
      developer.log('❌ Erreur vérification statut: $e', name: 'AuthService');
      return false;
    }
  }
  
  /// Obtient le nom complet de l'utilisateur
  Future<String?> getUserFullName() async {
    if (_currentUser.value != null) {
      return _currentUser.value!.fullName;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userFullName');
  }
  
  /// Obtient l'email de l'utilisateur
  Future<String?> getUserEmail() async {
    if (_currentUser.value != null) {
      return _currentUser.value!.email;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
  
  /// Obtient le rôle de l'utilisateur
  Future<String?> getUserRole() async {
    if (_currentUser.value != null) {
      return _currentUser.value!.role;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }
  
  /// Obtient le téléphone de l'utilisateur
  Future<String?> getUserPhone() async {
    if (_currentUser.value != null) {
      return _currentUser.value!.phone;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPhone');
  }
  
  /// Met à jour le profil utilisateur
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? location,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUser.value == null) return false;
      
      _isLoading.value = true;
      
      // Mettre à jour les champs fournis
      final updatedUser = _currentUser.value!.copyWith(
        fullName: fullName,
        phone: phone,
        location: location,
        profileImageUrl: profileImageUrl,
      );
      
      // Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(_currentUser.value!.uid)
          .update(updatedUser.toMap());
      
      // Mettre à jour localement
      _currentUser.value = updatedUser;
      await _updateLocalCache(updatedUser);
      
      developer.log('📝 Profil mis à jour', name: 'AuthService');
      
      return true;
    } catch (e) {
      developer.log('❌ Erreur mise à jour profil: $e', name: 'AuthService');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Réinitialise le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      
      await _auth.sendPasswordResetEmail(email: email);
      
      developer.log('📧 Email de réinitialisation envoyé à $email', name: 'AuthService');
      
      return true;
    } catch (e) {
      _errorMessage.value = 'Impossible d\'envoyer l\'email: $e';
      developer.log('❌ Erreur réinitialisation mot de passe: $e', name: 'AuthService');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Vérifie si l'email est déjà utilisé
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isEmpty;
    } catch (e) {
      developer.log('❌ Erreur vérification email: $e', name: 'AuthService');
      return false;
    }
  }
  
  /// Gestion des erreurs d'authentification
  String _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'operation-not-allowed':
        return 'Opération non autorisée. Contactez l\'administrateur.';
      case 'weak-password':
        return 'Le mot de passe est trop faible. Utilisez au moins 6 caractères.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion internet.';
      default:
        return 'Une erreur est survenue: ${error.message}';
    }
  }
  
  /// Efface le message d'erreur
  void clearError() {
    _errorMessage.value = '';
  }
  
  @override
  void onClose() {
    developer.log('🔐 AuthService fermé', name: 'AuthService');
    super.onClose();
  }
}