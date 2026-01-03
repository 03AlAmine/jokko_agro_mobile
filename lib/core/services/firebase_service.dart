// lib/core/services/firebase_service.dart
// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';
import '../../shared/models/product_model.dart'; // Ajoutez cette importation

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static FirebaseAuth get auth => _auth;
  static FirebaseFirestore get firestore => _firestore;

  // Ajoutez cette méthode pour récupérer les produits du producteur
  static Future<List<Product>> getProducerProducts(String producerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('producerId', isEqualTo: producerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  static Future<List<Product>> getAllAvailableProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('status', isEqualTo: 'available')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des produits disponibles: $e');
      return [];
    }
  }

  // Vous pouvez aussi ajouter d'autres méthodes utiles
  static Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      rethrow;
    }
  }

  static Future<void> updateProductStatus(
      String productId, String status) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }
}
