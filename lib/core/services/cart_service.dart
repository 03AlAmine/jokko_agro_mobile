// lib/features/cart/data/services/cart_service.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:jokko_agro/shared/models/market_model.dart';
import 'package:jokko_agro/shared/models/cart_model.dart';
import 'package:jokko_agro/shared/models/order_model.dart';

class CartService extends GetxService {
  static CartService get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble deliveryFee = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxInt itemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        cartItems.value = [];
        _calculateTotals();
        return;
      }

      // Charger depuis Firebase si l'utilisateur est connecté
      final cartDoc =
          await _firestore.collection('user_carts').doc(user.uid).get();

      if (cartDoc.exists) {
        final data = cartDoc.data();
        if (data != null && data['items'] != null) {
          final items = (data['items'] as List)
              .map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
              .toList();
          cartItems.value = items;
        } else {
          cartItems.value = [];
        }
      } else {
        cartItems.value = [];
      }

      _calculateTotals();
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
      // En cas d'erreur, charger depuis le cache local
      await _loadFromLocalCache();
    }
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart_items') ?? [];

      final items = cartData
          .map((json) {
            try {
              final Map<String, dynamic> data =
                  Map<String, dynamic>.from(json as Map);
              return CartItem.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((item) => item != null)
          .cast<CartItem>()
          .toList();

      cartItems.value = items;
      _calculateTotals();
    } catch (e) {
      print('Erreur lors du chargement local: $e');
      cartItems.value = [];
    }
  }

  Future<void> saveCart() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Sauvegarder dans Firebase
        await _firestore.collection('user_carts').doc(user.uid).set({
          'items': cartItems.map((item) => item.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Sauvegarder aussi localement
      final prefs = await SharedPreferences.getInstance();
      final cartData = cartItems.map((item) => item.toMap()).toList();
      await prefs.setStringList(
          'cart_items', cartData.map((map) => map.toString()).toList());
    } catch (e) {
      print('Erreur lors de la sauvegarde du panier: $e');
    }
  }

  void addToCart(MarketProduct product, {int quantity = 1}) {
    // Vérifier si le produit existe déjà dans le panier
    final existingIndex =
        cartItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Augmenter la quantité si le produit existe déjà
      final existingItem = cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity <= product.stock) {
        cartItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        Get.snackbar(
          'Stock insuffisant',
          'Stock disponible: ${product.stock} ${product.unit}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    } else {
      // Ajouter un nouvel élément au panier
      if (quantity >= product.minOrderQuantity && quantity <= product.stock) {
        cartItems.add(CartItem.fromMarketProduct(product, quantity: quantity));
      } else if (quantity < product.minOrderQuantity) {
        Get.snackbar(
          'Quantité minimale',
          'Quantité minimale: ${product.minOrderQuantity} ${product.unit}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      } else {
        Get.snackbar(
          'Stock insuffisant',
          'Stock disponible: ${product.stock} ${product.unit}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    _calculateTotals();
    saveCart();

    Get.snackbar(
      'Panier',
      '${product.name} ajouté au panier',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      final item = cartItems[index];

      if (newQuantity >= item.minOrderQuantity && newQuantity <= item.stock) {
        cartItems[index] = item.copyWith(quantity: newQuantity);
        _calculateTotals();
        saveCart();
      } else if (newQuantity < item.minOrderQuantity) {
        Get.snackbar(
          'Quantité minimale',
          'Quantité minimale: ${item.minOrderQuantity} ${item.unit}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Stock insuffisant',
          'Stock disponible: ${item.stock} ${item.unit}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item.productId == productId);
    _calculateTotals();
    saveCart();

    Get.snackbar(
      'Panier',
      'Produit retiré du panier',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void clearCart() {
    cartItems.clear();
    _calculateTotals();
    saveCart();

    Get.snackbar(
      'Panier',
      'Panier vidé',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _calculateTotals() {
    // Calculer le sous-total
    final calculatedSubtotal =
        // ignore: avoid_types_as_parameter_names
        cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    subtotal.value = calculatedSubtotal;

    // Calculer les frais de livraison
    deliveryFee.value = calculatedSubtotal < 5000 ? 500.0 : 0.0;

    // Calculer le total
    total.value = calculatedSubtotal + deliveryFee.value;

    // Calculer le nombre total d'articles
    // ignore: avoid_types_as_parameter_names
    itemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isCartEmpty => cartItems.isEmpty;

  List<CartItem> get items => cartItems.toList();

  double get calculatedSubtotal => subtotal.value;
  double get calculatedDeliveryFee => deliveryFee.value;
  double get calculatedTotal => total.value;

  Future<void> checkout({
    required String userName,
    required String userPhone,
    required String userEmail,
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    if (isCartEmpty) {
      Get.snackbar(
        'Panier vide',
        'Ajoutez des produits avant de passer commande',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Non connecté',
        'Veuillez vous connecter pour passer commande',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final orderId =
          'CMD_${DateTime.now().millisecondsSinceEpoch}_${user.uid.substring(0, 8)}';

      final order = Order(
        id: orderId,
        userId: user.uid,
        userName: userName,
        userPhone: userPhone,
        userEmail: userEmail,
        items: cartItems.toList(),
        subtotal: subtotal.value,
        deliveryFee: deliveryFee.value,
        total: total.value,
        status: 'pending',
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        notes: notes,
        orderDate: DateTime.now(),
      );

      // 1. Sauvegarder la commande dans Firebase
      await _firestore.collection('orders').doc(orderId).set(order.toMap());

      // 2. Mettre à jour les statistiques de vente pour chaque produit
      await _updateProductSales(cartItems);

      // 3. Mettre à jour les stocks des produits
      await _updateProductStocks(cartItems);

      // 4. Vider le panier
      clearCart();

      // 5. Sauvegarder aussi dans la collection user_orders pour un accès rapide
      await _firestore
          .collection('user_orders')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .set(order.toMap());

      Get.snackbar(
        'Commande réussie',
        'Votre commande #$orderId a été enregistrée',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Rediriger vers l'écran de confirmation
      Get.offNamed('/order-confirmation', arguments: order);
    } catch (e) {
      print('Erreur lors du checkout: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la commande: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateProductSales(List<CartItem> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore.collection('products').doc(item.productId);

      // Incrémenter les ventes pour chaque produit
      batch.update(productRef, {
        'sales': FieldValue.increment(item.quantity),
        'stock': FieldValue.increment(-item.quantity), // Réduire le stock
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour aussi les ventes du producteur si nécessaire
      final producerRef = _firestore.collection('users').doc(item.producerId);
      batch.update(producerRef, {
        'totalSales': FieldValue.increment(item.totalPrice),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> _updateProductStocks(List<CartItem> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore.collection('products').doc(item.productId);

      // Récupérer le stock actuel pour vérification
      final productDoc = await productRef.get();
      if (productDoc.exists) {
        final currentStock = productDoc.data()?['stock'] ?? 0;
        final newStock = currentStock - item.quantity;

        // Mettre à jour le stock
        batch.update(productRef, {
          'stock': newStock,
          'status': newStock <= 0 ? 'out_of_stock' : 'available',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  // Méthode pour récupérer les commandes d'un utilisateur
  Future<List<Order>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('user_orders')
          .doc(user.uid)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Order.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }
}
