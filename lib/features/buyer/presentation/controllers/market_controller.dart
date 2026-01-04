// lib/features/buyer/presentation/controllers/market_controller.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/core/services/cart_service.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'package:jokko_agro/shared/models/product_model.dart';
import 'package:jokko_agro/shared/models/market_model.dart';

class MarketController extends GetxController {
  final CartService cartService =
      Get.find<CartService>(); // Ajoutez cette ligne

  // Variables réactives
  final allProducts = <MarketProduct>[].obs;
  final filteredProducts = <MarketProduct>[].obs;
  final isLoading = false.obs;
  final viewMode = 'grid'.obs;

  // Filtres
  final searchQuery = ''.obs;
  final selectedCategory = 'all'.obs;
  final selectedCertification = 'all'.obs;
  final selectedSort = 'distance'.obs;
  final priceRange = [0.0, 100000.0].obs;
  final maxDistance = 50.0.obs;

  // Catégories avec icônes Flutter
  final categories = [
    {'id': 'all', 'name': 'Tout voir', 'icon': Icons.store, 'count': 0},
    {'id': 'vegetables', 'name': 'Légumes', 'icon': Icons.eco, 'count': 0},
    {'id': 'fruits', 'name': 'Fruits', 'icon': Icons.apple, 'count': 0},
    {'id': 'cereals', 'name': 'Céréales', 'icon': Icons.grass, 'count': 0},
    {'id': 'tubers', 'name': 'Tubercules', 'icon': Icons.park, 'count': 0},
    {
      'id': 'legumes',
      'name': 'Légumineuses',
      'icon': Icons.set_meal,
      'count': 0
    },
    {'id': 'poultry', 'name': 'Volaille', 'icon': Icons.pets, 'count': 0},
    {'id': 'dairy', 'name': 'Laitiers', 'icon': Icons.local_drink, 'count': 0},
    {
      'id': 'spices',
      'name': 'Épices',
      'icon': Icons.local_fire_department,
      'count': 0
    },
  ].obs;

  // Certifications
  final certifications = [
    {'id': 'all', 'name': 'Toutes'},
    {'id': 'certified', 'name': 'Certifié'},
    {'id': 'organic', 'name': 'Bio'},
    {'id': 'local', 'name': 'Local'},
  ].obs;

  // Options de tri
  final sortOptions = [
    {'id': 'distance', 'name': 'Plus proche'},
    {'id': 'price_low', 'name': 'Prix croissant'},
    {'id': 'price_high', 'name': 'Prix décroissant'},
    {'id': 'rating', 'name': 'Meilleures notes'},
    {'id': 'newest', 'name': 'Plus récent'},
  ].obs;

  // Propriétés calculées
  int get totalProducts => allProducts.length;
  int get certifiedProductsCount =>
      allProducts.where((p) => p.isCertified).length;
  int get organicProductsCount => allProducts.where((p) => p.isOrganic).length;
  int get localProductsCount => allProducts.where((p) => p.isLocal).length;

  int get uniqueProducersCount {
    final uniqueProducers = allProducts.map((p) => p.producerId).toSet();
    return uniqueProducers.length;
  }

  double get averageProductRating {
    if (allProducts.isEmpty) return 0;
    return allProducts.map((p) => p.rating).reduce((a, b) => a + b) /
        allProducts.length;
  }

  double get averageDistance {
    if (allProducts.isEmpty) return 0;
    return allProducts.map((p) => p.distance).reduce((a, b) => a + b) /
        allProducts.length;
  }

  int get lowStockProducts => allProducts.where((p) => p.stock < 10).length;

  double get totalProductsValue => allProducts.fold(
      0.0, (sum, product) => sum + (product.price * product.quantity));

  // Méthodes utilitaires
  String getCategoryName(String categoryId) {
    try {
      return categories.firstWhere(
        (c) => c['id'] == categoryId,
        orElse: () => {'name': categoryId},
      )['name'] as String;
    } catch (e) {
      return categoryId;
    }
  }

  IconData getCategoryIcon(String categoryId) {
    try {
      return categories.firstWhere(
        (c) => c['id'] == categoryId,
        orElse: () => {'icon': Icons.shopping_basket},
      )['icon'] as IconData;
    } catch (e) {
      return Icons.shopping_basket;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;

      final firestoreProducts = await _getAllAvailableProducts();

      final marketProducts = firestoreProducts.map((product) {
        return MarketProduct.fromProduct(
          product,
          distance: _getRandomDistance(),
          rating: _getRandomRating(),
          reviews: _getRandomReviews(),
        );
      }).toList();

      allProducts.value = marketProducts;
      _updateCategoryCounts();
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Product>> _getAllAvailableProducts() async {
    try {
      final querySnapshot = await FirebaseService.firestore
          .collection('products')
          .where('status', isEqualTo: 'available')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  double _getRandomDistance() => (1 + (Random().nextDouble() * 29));
  double _getRandomRating() => 3.5 + (Random().nextDouble() * 1.5);
  int _getRandomReviews() => Random().nextInt(100);

  void _updateCategoryCounts() {
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      if (category['id'] == 'all') {
        categories[i]['count'] = allProducts.length;
      } else {
        categories[i]['count'] =
            allProducts.where((p) => p.category == category['id']).length;
      }
    }
    categories.refresh();
  }

  void applyFilters() {
    if (allProducts.isEmpty) {
      filteredProducts.value = [];
      return;
    }

    List<MarketProduct> filtered = [...allProducts];

    // Filtre par recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.producerName.toLowerCase().contains(query) ||
            (product.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filtre par catégorie
    if (selectedCategory.value != 'all') {
      filtered = filtered.where((product) {
        return product.category == selectedCategory.value;
      }).toList();
    }

    // Filtre par certification
    if (selectedCertification.value != 'all') {
      switch (selectedCertification.value) {
        case 'certified':
          filtered = filtered.where((p) => p.isCertified).toList();
          break;
        case 'organic':
          filtered = filtered.where((p) => p.isOrganic).toList();
          break;
        case 'local':
          filtered = filtered.where((p) => p.isLocal).toList();
          break;
      }
    }

    // Filtre par distance
    filtered = filtered.where((p) => p.distance <= maxDistance.value).toList();

    // Filtre par prix
    filtered = filtered
        .where((p) =>
            p.price >= priceRange.value[0] && p.price <= priceRange.value[1])
        .toList();

    // Filtre par disponibilité
    filtered =
        filtered.where((p) => p.status == 'available' && p.stock > 0).toList();

    // Tri
    filtered.sort((a, b) {
      switch (selectedSort.value) {
        case 'distance':
          return a.distance.compareTo(b.distance);
        case 'price_low':
          return a.price.compareTo(b.price);
        case 'price_high':
          return b.price.compareTo(a.price);
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'newest':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return 0;
      }
    });

    filteredProducts.value = filtered;
  }

  void toggleFavorite(String productId) {
    Get.snackbar(
      'Favoris',
      'Fonctionnalité à venir',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addToCart(MarketProduct product) {
    // Utilisez le service panier au lieu d'afficher un simple snackbar
    cartService.addToCart(product);

    // Ajoutez une animation ou un feedback visuel supplémentaire
    _showAddToCartAnimation(product);
  }

  void _showAddToCartAnimation(MarketProduct product) {
    // Vous pouvez ajouter une animation ici si vous le souhaitez
    // Par exemple, afficher un badge de notification
    Get.snackbar(
      '✅ Ajouté au panier',
      '${product.name} a été ajouté à votre panier',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
    );
  }

  void viewProductDetails(MarketProduct product) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      getCategoryIcon(product.category),
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.producerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Producteur', product.producerName),
                    _buildDetailRow(
                        'Localisation', product.location ?? 'Non spécifié'),
                    _buildDetailRow(
                        'Catégorie', getCategoryName(product.category)),
                    _buildDetailRow('Prix',
                        '${product.price.toInt()} FCFA/${product.unit}'),
                    _buildDetailRow(
                        'Stock disponible', '${product.stock} ${product.unit}'),
                    _buildDetailRow('Quantité minimum',
                        '${product.minOrderQuantity} ${product.unit}'),
                    _buildDetailRow('Distance',
                        '${product.distance.toStringAsFixed(1)} km'),
                    _buildDetailRow('Note produit',
                        '${product.rating.toStringAsFixed(1)}/5 (${product.reviews} avis)'),
                    if (product.certifications != null &&
                        product.certifications!.isNotEmpty)
                      _buildDetailRow(
                          'Certifications', product.certifications!.join(', ')),
                    _buildDetailRow('Bio', product.isOrganic ? 'Oui' : 'Non'),
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: Get.back,
                            child: const Text('Fermer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              addToCart(product);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Ajouter au panier'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'all';
    selectedCertification.value = 'all';
    selectedSort.value = 'distance';
    priceRange.value = [0.0, 100000.0];
    maxDistance.value = 50.0;
    applyFilters();

    Get.snackbar(
      'Filtres',
      'Tous les filtres ont été réinitialisés',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> refreshProducts() async {
    await loadProducts();

    Get.snackbar(
      'Actualisation',
      'Produits actualisés',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
}
