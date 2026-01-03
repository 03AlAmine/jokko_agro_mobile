// lib/features/producer/presentation/controllers/products_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'package:jokko_agro/shared/models/product_model.dart';

class ProductsController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  // Variables réactives
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedCategory = 'all'.obs;
  var selectedStatus = 'all'.obs;
  var sortBy = 'recent'.obs;

  // Catégories
  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'Toutes les catégories', 'icon': '📦'},
    {'id': 'vegetables', 'name': 'Légumes', 'icon': '🥦'},
    {'id': 'fruits', 'name': 'Fruits', 'icon': '🍎'},
    {'id': 'cereals', 'name': 'Céréales', 'icon': '🌾'},
    {'id': 'tubers', 'name': 'Tubercules', 'icon': '🥔'},
    {'id': 'legumes', 'name': 'Légumineuses', 'icon': '🥜'},
    {'id': 'spices', 'name': 'Épices', 'icon': '🌶️'},
    {'id': 'dairy', 'name': 'Produits laitiers', 'icon': '🥛'},
    {'id': 'poultry', 'name': 'Volaille', 'icon': '🐔'},
  ];

  // Statuts
  final List<Map<String, dynamic>> statuses = [
    {'id': 'all', 'name': 'Tous les statuts'},
    {'id': 'available', 'name': 'Disponible'},
    {'id': 'sold_out', 'name': 'Épuisé'},
    {'id': 'draft', 'name': 'Brouillon'},
  ];

  // Options de tri
  final List<Map<String, dynamic>> sortOptions = [
    {'id': 'recent', 'name': 'Plus récent'},
    {'id': 'oldest', 'name': 'Plus ancien'},
    {'id': 'price_low', 'name': 'Prix croissant'},
    {'id': 'price_high', 'name': 'Prix décroissant'},
    {'id': 'sales', 'name': 'Meilleures ventes'},
    {'id': 'rating', 'name': 'Meilleures notes'},
  ];

  // Computed properties
  int get totalProductsCount => products.length;
  
  int get availableProductsCount => 
      products.where((p) => p.status == 'available').length;
  
  double get totalValueSum => products.fold(0, (sum, product) {
    return sum + (product.price * product.quantity);
  });

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      
      final user = authService.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return;
      }

      // Charger depuis Firebase
      final fetchedProducts = await FirebaseService.getProducerProducts(user.uid);
      products.value = fetchedProducts;
      applyFilters();
      
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les produits');
      products.value = [];
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<Product> filtered = [...products];

    // Filtre par recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
            (product.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtre par catégorie
    if (selectedCategory.value != 'all') {
      filtered = filtered.where((product) {
        return product.category == selectedCategory.value;
      }).toList();
    }

    // Filtre par statut
    if (selectedStatus.value != 'all') {
      filtered = filtered.where((product) {
        return product.status == selectedStatus.value;
      }).toList();
    }

    // Tri
    filtered.sort((a, b) {
      switch (sortBy.value) {
        case 'recent':
          return b.updatedAt.compareTo(a.updatedAt);
        case 'oldest':
          return a.updatedAt.compareTo(b.updatedAt);
        case 'price_low':
          return a.price.compareTo(b.price);
        case 'price_high':
          return b.price.compareTo(a.price);
        case 'sales':
          return b.sales.compareTo(a.sales);
        case 'rating':
          return b.rating.compareTo(a.rating);
        default:
          return 0;
      }
    });

    filteredProducts.value = filtered;
  }

  Map<String, dynamic> getCategoryInfo(String categoryId) {
    try {
      final category = categories.firstWhere((c) => c['id'] == categoryId);
      return category;
    } catch (e) {
      return {'id': categoryId, 'name': categoryId, 'icon': '📦'};
    }
  }

  Map<String, dynamic> getStatusInfo(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'available':
        color = const Color(0xFF10B981); // Vert
        text = 'Disponible';
        break;
      case 'sold_out':
        color = const Color(0xFFEF4444); // Rouge
        text = 'Épuisé';
        break;
      case 'inactive':
        color = const Color(0xFF6B7280); // Gris
        text = 'Inactif';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return {'color': color, 'text': text};
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Actions
  void editProduct(String productId) {
    Get.snackbar('Modification', 'Modification du produit $productId');
  }

  void viewProduct(String productId) {
    Get.snackbar('Visualisation', 'Visualisation du produit $productId');
  }

  void duplicateProduct(String productId) {
    Get.snackbar('Duplication', 'Duplication du produit $productId');
  }

  Future<void> toggleProductStatus(Product product) async {
    try {
      final newStatus = product.status == 'available' ? 'sold_out' : 'available';
      await FirebaseService.updateProductStatus(product.id, newStatus);
      Get.snackbar('Succès', 'Statut mis à jour: $newStatus');
      await loadProducts();
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final confirmed = await Get.defaultDialog(
      title: 'Confirmer la suppression',
      middleText: 'Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.',
      textConfirm: 'Supprimer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteProduct(productId);
        Get.snackbar('Succès', 'Produit supprimé avec succès');
        await loadProducts();
      } catch (e) {
        Get.snackbar('Erreur', 'Impossible de supprimer le produit: $e');
      }
    }
  }

  List<Product> getTopSellingProducts() {
    final sorted = [...products];
    sorted.sort((a, b) => b.sales.compareTo(a.sales));
    return sorted.take(3).toList();
  }
}