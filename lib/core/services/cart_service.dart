// lib/features/cart/data/services/cart_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jokko_agro/shared/models/market_model.dart';
import 'package:jokko_agro/shared/models/cart_model.dart';
import 'package:jokko_agro/shared/models/order_model.dart' as my_order;

class CartService extends GetxService {
  static CartService get to => Get.find();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Variables réactives
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  final RxDouble _subtotal = 0.0.obs;
  final RxDouble _deliveryFee = 0.0.obs;
  final RxDouble _total = 0.0.obs;
  final RxInt _itemCount = 0.obs;
  final RxBool _isLoading = false.obs;
  
  // Getters publics
  List<CartItem> get cartItems => _cartItems.toList();
  double get subtotal => _subtotal.value;
  double get deliveryFee => _deliveryFee.value;
  double get total => _total.value;
  int get itemCount => _itemCount.value;
  bool get isLoading => _isLoading.value;
  bool get isCartEmpty => _cartItems.isEmpty;
  
  @override
  void onInit() {
    super.onInit();
    debugPrint('🛒 CartService initialisé');
  }
  
  /// Charge le panier depuis Firebase et le cache local
  Future<void> loadCart({bool forceRefresh = false}) async {
    try {
      if (_isLoading.value && !forceRefresh) return;
      
      _isLoading.value = true;
      debugPrint('🔄 Chargement du panier...');
      
      final user = _auth.currentUser;
      
      // 1. Charger depuis le cache local d'abord (pour réactivité)
      final List<CartItem> localItems = await _loadFromLocalCache();
      
      if (!forceRefresh && localItems.isNotEmpty) {
        _cartItems.value = localItems;
        _calculateTotals();
        debugPrint('📱 Panier chargé depuis cache local: ${_cartItems.length} items');
      }
      
      // 2. Si utilisateur connecté, synchroniser avec Firebase
      if (user != null) {
        try {
          debugPrint('👤 Synchronisation avec Firebase pour ${user.uid}');
          
          final cartDoc = await _firestore
              .collection('user_carts')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 10));
          
          if (cartDoc.exists && cartDoc.data() != null) {
            final data = cartDoc.data()!;
            
            if (data['items'] != null && data['items'] is List) {
              final firebaseItems = (data['items'] as List)
                  .map((item) {
                    try {
                      return CartItem.fromMap(Map<String, dynamic>.from(item));
                    } catch (e) {
                      debugPrint('⚠️ Erreur conversion item Firebase: $e');
                      return null;
                    }
                  })
                  .where((item) => item != null)
                  .cast<CartItem>()
                  .toList();
              
              debugPrint('☁️ ${firebaseItems.length} items chargés depuis Firebase');
              
              // Fusionner les paniers: priorité à Firebase
              if (firebaseItems.isNotEmpty) {
                await _mergeCarts(localItems, firebaseItems);
              } else if (localItems.isNotEmpty) {
                // Sauvegarder le cache local dans Firebase
                await _saveCartToFirebase(localItems);
              }
            }
          } else {
            debugPrint('📭 Aucun panier dans Firebase');
            if (localItems.isNotEmpty) {
              await _saveCartToFirebase(localItems);
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erreur Firebase: $e - Utilisation du cache local');
        }
      }
      
      _calculateTotals();
      debugPrint('✅ Panier final: ${_cartItems.length} items, Total: ${_total.value}F');
      
    } catch (e) {
      debugPrint('❌ Erreur critique lors du chargement: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// Fusionne le cache local et Firebase (priorité à Firebase pour les conflits)
  Future<void> _mergeCarts(List<CartItem> localItems, List<CartItem> firebaseItems) async {
    final mergedItems = <CartItem>[];
    final allProductIds = <String>{};
    
    // Ajouter d'abord tous les items Firebase
    for (var fbItem in firebaseItems) {
      mergedItems.add(fbItem);
      allProductIds.add(fbItem.productId);
    }
    
    // Ajouter les items locaux qui ne sont pas dans Firebase
    for (var localItem in localItems) {
      if (!allProductIds.contains(localItem.productId)) {
        mergedItems.add(localItem);
      }
    }
    
    // Vérifier les stocks avant de sauvegarder
    final validatedItems = await _validateStockQuantities(mergedItems);
    
    _cartItems.value = validatedItems;
    await saveLocalCache(validatedItems);
    
    final user = _auth.currentUser;
    if (user != null) {
      await _saveCartToFirebase(validatedItems);
    }
  }
  
  /// Valide les quantités par rapport aux stocks disponibles
  Future<List<CartItem>> _validateStockQuantities(List<CartItem> items) async {
    final validatedItems = <CartItem>[];
    
    for (var item in items) {
      try {
        final productDoc = await _firestore
            .collection('products')
            .doc(item.productId)
            .get();
        
        if (productDoc.exists) {
          final productData = productDoc.data();
          final availableStock = productData?['quantity'] ?? 0;
          final minOrderQty = productData?['minOrderQuantity'] ?? 1;
          
          // Ajuster la quantité si nécessaire
          int adjustedQuantity = item.quantity;
          
          if (item.quantity > availableStock) {
            debugPrint('⚠️ Stock insuffisant pour ${item.productName}: ${item.quantity} > $availableStock');
            adjustedQuantity = availableStock;
            
            if (adjustedQuantity < minOrderQty) {
              debugPrint('❌ Quantité ajustée ($adjustedQuantity) inférieure au minimum ($minOrderQty) - suppression');
              continue; // Ne pas ajouter cet item
            }
          } else if (item.quantity < minOrderQty) {
            adjustedQuantity = minOrderQty;
          }
          
          if (adjustedQuantity > 0) {
            validatedItems.add(item.copyWith(quantity: adjustedQuantity));
          }
        } else {
          debugPrint('⚠️ Produit ${item.productId} non trouvé - suppression du panier');
        }
      } catch (e) {
        debugPrint('⚠️ Erreur validation stock pour ${item.productId}: $e');
        validatedItems.add(item); // Conserver l'item en cas d'erreur
      }
    }
    
    return validatedItems;
  }
  
  /// Chargement depuis le cache local
  Future<List<CartItem>> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJsonList = prefs.getStringList('cart_items') ?? [];
      
      if (cartJsonList.isEmpty) return [];
      
      final items = <CartItem>[];
      
      for (final jsonString in cartJsonList) {
        try {
          final Map<String, dynamic> data = json.decode(jsonString);
          items.add(CartItem.fromMap(data));
        } catch (e) {
          debugPrint('⚠️ Erreur décodage cache local: $e');
        }
      }
      
      debugPrint('📱 Cache local: ${items.length} items');
      return items;
    } catch (e) {
      debugPrint('❌ Erreur chargement cache local: $e');
      return [];
    }
  }
  
  /// Sauvegarde dans le cache local
  Future<void> saveLocalCache(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJsonList = items.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList('cart_items', cartJsonList);
      debugPrint('📱 Cache local sauvegardé: ${items.length} items');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde cache local: $e');
    }
  }
  
  /// Sauvegarde dans Firebase
  Future<void> _saveCartToFirebase(List<CartItem> items) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('👤 Utilisateur non connecté - skip Firebase');
        return;
      }
      
      await _firestore
          .collection('user_carts')
          .doc(user.uid)
          .set({
            'items': items.map((item) => item.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
            'userId': user.uid,
            'email': user.email,
          }, SetOptions(merge: true));
      
      debugPrint('☁️ Firebase sauvegardé: ${items.length} items');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde Firebase: $e');
      rethrow;
    }
  }
  
  /// Ajoute un produit au panier
  Future<void> addToCart(MarketProduct product, {int quantity = 1}) async {
    try {
      debugPrint('➕ Ajout au panier: ${product.name} x$quantity');
      
      // Vérifier les contraintes
      if (quantity < product.minOrderQuantity) {
        Get.snackbar(
          'Quantité minimale',
          'Quantité minimale: ${product.minOrderQuantity} ${product.unit}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      if (quantity > product.stock) {
        Get.snackbar(
          'Stock insuffisant',
          'Stock disponible: ${product.stock} ${product.unit}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex >= 0) {
        // Mettre à jour la quantité
        final existingItem = _cartItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;
        
        if (newQuantity > product.stock) {
          Get.snackbar(
            'Stock insuffisant',
            'Quantité totale ($newQuantity) dépasse le stock disponible: ${product.stock}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        
        _cartItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
        debugPrint('📈 Quantité mise à jour: $newQuantity');
      } else {
        // Nouvel item
        final newItem = CartItem.fromMarketProduct(product, quantity: quantity);
        _cartItems.add(newItem);
        debugPrint('🆕 Nouvel item ajouté: ${newItem.productName}');
      }
      
      _calculateTotals();
      await _saveCart();
      
      // Feedback utilisateur
      Get.snackbar(
        '✅ Ajouté au panier',
        '${product.name} (x$quantity)',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
      );
      
    } catch (e) {
      debugPrint('❌ Erreur addToCart: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  /// Met à jour la quantité d'un produit
  Future<void> updateQuantity(String productId, int newQuantity) async {
    try {
      final index = _cartItems.indexWhere((item) => item.productId == productId);
      
      if (index >= 0) {
        final item = _cartItems[index];
        
        // Vérifier le stock
        try {
          final productDoc = await _firestore
              .collection('products')
              .doc(productId)
              .get();
          
          if (productDoc.exists) {
            final stock = productDoc.data()?['quantity'] ?? 0;
            final minQty = productDoc.data()?['minOrderQuantity'] ?? 1;
            
            if (newQuantity < minQty) {
              Get.snackbar(
                'Quantité minimale',
                'Quantité minimale: $minQty',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }
            
            if (newQuantity > stock) {
              Get.snackbar(
                'Stock insuffisant',
                'Stock disponible: $stock',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
          }
        } catch (e) {
          debugPrint('⚠️ Impossible de vérifier le stock: $e');
        }
        
        _cartItems[index] = item.copyWith(quantity: newQuantity);
        _calculateTotals();
        await _saveCart();
        
        debugPrint('🔄 Quantité mise à jour pour ${item.productName}: $newQuantity');
      }
    } catch (e) {
      debugPrint('❌ Erreur updateQuantity: $e');
    }
  }
  
  /// Supprime un produit du panier
  Future<void> removeFromCart(String productId) async {
    final item = _cartItems.firstWhereOrNull((item) => item.productId == productId);
    if (item != null) {
      _cartItems.removeWhere((item) => item.productId == productId);
      _calculateTotals();
      await _saveCart();
      
      Get.snackbar(
        '✅ Retiré du panier',
        '${item.productName} a été retiré',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  /// Vide complètement le panier
  Future<void> clearCart() async {
    _cartItems.clear();
    _calculateTotals();
    await _saveCart();
    
    Get.snackbar(
      '✅ Panier vidé',
      'Tous les produits ont été retirés',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  /// Sauvegarde le panier (local + Firebase)
  Future<void> _saveCart() async {
    try {
      debugPrint('💾 Sauvegarde du panier...');
      
      await saveLocalCache(_cartItems);
      
      final user = _auth.currentUser;
      if (user != null) {
        await _saveCartToFirebase(_cartItems);
      }
      
      debugPrint('✅ Panier sauvegardé');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde panier: $e');
    }
  }
  
  /// Calcule les totaux
  void _calculateTotals() {
    final calculatedSubtotal = _cartItems.fold(
      0.0, 
      (previousSum, item) => previousSum + item.totalPrice
    );
    _subtotal.value = calculatedSubtotal;
    
    // Frais de livraison: 500FCFA si sous-total < 5000FCFA
    _deliveryFee.value = calculatedSubtotal < 5000 ? 500.0 : 0.0;
    
    _total.value = calculatedSubtotal + _deliveryFee.value;
    
    _itemCount.value = _cartItems.fold(
      0, 
      (previousSum, item) => previousSum + item.quantity
    );
    
    debugPrint('🧮 Calculs: Sous-total=$calculatedSubtotal, Frais=${_deliveryFee.value}, Total=${_total.value}, Items=${_itemCount.value}');
  }
  
  /// Récupère un produit spécifique du panier
  CartItem? getCartItem(String productId) {
    return _cartItems.firstWhereOrNull((item) => item.productId == productId);
  }
  
  /// Synchronise le panier avec Firebase (à appeler après connexion)
  Future<void> syncCartAfterLogin() async {
    try {
      debugPrint('🔄 Synchronisation après connexion');
      
      // Charger depuis Firebase pour écraser le cache local
      await loadCart(forceRefresh: true);
      
    } catch (e) {
      debugPrint('❌ Erreur synchronisation: $e');
    }
  }
  
  /// Passe une commande
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
      final orderId = 'CMD_${DateTime.now().millisecondsSinceEpoch}_${user.uid.substring(0, 8)}';
      
      // Créer la commande
      final order = my_order.Order(
        id: orderId,
        userId: user.uid,
        userName: userName,
        userPhone: userPhone,
        userEmail: userEmail,
        items: _cartItems.toList(),
        subtotal: _subtotal.value,
        deliveryFee: _deliveryFee.value,
        total: _total.value,
        status: 'pending',
        paymentMethod: paymentMethod,
        deliveryAddress: deliveryAddress,
        notes: notes,
        orderDate: DateTime.now(),
      );
      
      debugPrint('📝 Création commande: $orderId');
      
      // Sauvegarder dans Firestore
      final batch = _firestore.batch();
      
      // 1. Sauvegarder dans la collection globale des commandes
      batch.set(
        _firestore.collection('orders').doc(orderId),
        order.toMap()
      );
      
      // 2. Sauvegarder dans les commandes utilisateur
      batch.set(
        _firestore.collection('user_orders').doc(user.uid).collection('orders').doc(orderId),
        order.toMap()
      );
      
      // 3. Mettre à jour les stocks et ventes
      for (final item in _cartItems) {
        final productRef = _firestore.collection('products').doc(item.productId);
        batch.update(productRef, {
          'sales': FieldValue.increment(item.quantity),
          'quantity': FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        final producerRef = _firestore.collection('users').doc(item.producerId);
        batch.update(producerRef, {
          'totalSales': FieldValue.increment(item.totalPrice),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('✅ Commande créée et stocks mis à jour');
      
      // Vider le panier après commande
      await clearCart();
      
      // Rediriger vers la confirmation
      Get.offNamed('/buyer/order-confirmation', arguments: order.toMap());
      
    } catch (e) {
      debugPrint('❌ Erreur checkout: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la commande: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  /// Récupère les commandes utilisateur
  Future<List<my_order.Order>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final querySnapshot = await _firestore
          .collection('user_orders')
          .doc(user.uid)
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(50)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return my_order.Order.fromMap(doc.data());
      }).toList();
    } catch (e) {
      debugPrint('❌ Erreur récupération commandes: $e');
      return [];
    }
  }
}