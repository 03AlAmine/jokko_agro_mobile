
// lib/features/buyer/presentation/controllers/market_controller.dart - VERSION CORRIGÉE
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'package:jokko_agro/shared/models/product_model.dart';
import 'package:jokko_agro/shared/models/market_model.dart';

class MarketController extends GetxController {
  // Variables réactives
  var allProducts = <MarketProduct>[].obs;
  var filteredProducts = <MarketProduct>[].obs;
  var isLoading = false.obs;
  
  // Filtres
  var searchQuery = ''.obs;
  var selectedCategory = 'all'.obs;
  var selectedCertification = 'all'.obs;
  var selectedSort = 'distance'.obs;
  var priceRange = [0.0, 100000.0].obs;
  var maxDistance = 50.0.obs;
  var viewMode = 'grid'.obs; // 'grid' ou 'list'
  
  // Catégories
  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'Tout voir', 'icon': '🛒'},
    {'id': 'vegetables', 'name': 'Légumes', 'icon': '🥦'},
    {'id': 'fruits', 'name': 'Fruits', 'icon': '🍎'},
    {'id': 'cereals', 'name': 'Céréales', 'icon': '🌾'},
    {'id': 'tubers', 'name': 'Tubercules', 'icon': '🥔'},
    {'id': 'legumes', 'name': 'Légumineuses', 'icon': '🥜'},
    {'id': 'poultry', 'name': 'Volaille', 'icon': '🐔'},
    {'id': 'dairy', 'name': 'Laitiers', 'icon': '🥛'},
    {'id': 'spices', 'name': 'Épices', 'icon': '🌶️'},
  ];
  
  // Certifications
  final List<Map<String, dynamic>> certifications = [
    {'id': 'all', 'name': 'Toutes'},
    {'id': 'certified', 'name': 'Certifié'},
    {'id': 'organic', 'name': 'Bio'},
    {'id': 'local', 'name': 'Local'},
  ];
  
  // Options de tri
  final List<Map<String, dynamic>> sortOptions = [
    {'id': 'distance', 'name': 'Plus proche'},
    {'id': 'price_low', 'name': 'Prix croissant'},
    {'id': 'price_high', 'name': 'Prix décroissant'},
    {'id': 'rating', 'name': 'Meilleures notes'},
    {'id': 'newest', 'name': 'Plus récent'},
  ];
  
  // Propriétés calculées
  int get totalProducts => allProducts.length;
  int get certifiedProductsCount => 
      allProducts.where((p) => p.isCertified).length;
  int get uniqueProducersCount {
    final uniqueProducers = allProducts.map((p) => p.producerId).toSet();
    return uniqueProducers.length;
  }
  
  // Méthode pour obtenir le nom de la catégorie
  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'name': categoryId, 'icon': '📦'},
    );
    return category['name'];
  }
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      
      // Récupérer tous les produits depuis Firebase
      final firestoreProducts = await _getAllAvailableProducts();
      
      // Transformer les produits en MarketProduct
      final marketProducts = firestoreProducts.map((product) {
        return MarketProduct.fromProduct(
          product,
          distance: _getRandomDistance(),
          rating: _getRandomRating(),
          reviews: _getRandomReviews(),
        );
      }).toList();
      
      allProducts.value = marketProducts;
      applyFilters();
      
    } catch (e) {
      Get.snackbar(
        'Erreur', 
        'Impossible de charger les produits',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Fallback: charger des données de test
      _loadFallbackData();
      
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<List<Product>> _getAllAvailableProducts() async {
    try {
      // Récupérer tous les produits avec statut 'available' 
      // SANS le orderBy pour éviter l'erreur d'index
      final querySnapshot = await FirebaseService.firestore
          .collection('products')
          .where('status', isEqualTo: 'available')
          .where('isActive', isEqualTo: true)
          // .orderBy('createdAt', descending: true) // Commenté temporairement
          .get();
      
      return querySnapshot.docs.map((doc) {
        return Product.fromMap(doc.data() , doc.id);
      }).toList();
      
    } catch (e) {
      return [];
    }
  }
  
  double _getRandomDistance() {
    return (1 + (Random().nextDouble() * 29)).toDouble(); // 1-30 km
  }
  
  double _getRandomRating() {
    return 3.5 + (Random().nextDouble() * 1.5); // 3.5-5.0
  }
  
  int _getRandomReviews() {
    return Random().nextInt(100); // 0-99 avis
  }
  
  void _loadFallbackData() {
    // Données de test pour le développement
    allProducts.value = [
      MarketProduct(
        id: '1',
        name: 'Tomates Bio',
        producerName: 'Alioune Farm',
        producerId: 'producer_1',
        producerRating: 4.8,
        price: 1500,
        unit: 'kg',
        quantity: 50,
        category: 'vegetables',
        description: 'Tomates biologiques cultivées sans pesticides',
        certifications: ['organic', 'local'],
        isOrganic: true,
        location: 'Dakar',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'available',
        views: 100,
        sales: 45,
        minOrderQuantity: 1,
        distance: 2.5,
        rating: 4.8,
        reviews: 45,
        stock: 50,
        displayEmoji: '🍅',
      ),
      MarketProduct(
        id: '2',
        name: 'Riz Local',
        producerName: 'Moussa Agriculture',
        producerId: 'producer_2',
        producerRating: 4.6,
        price: 2500,
        unit: 'kg',
        quantity: 100,
        category: 'cereals',
        description: 'Riz cultivé localement dans la vallée du fleuve',
        certifications: ['local'],
        isOrganic: false,
        location: 'Saint-Louis',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'available',
        views: 150,
        sales: 80,
        minOrderQuantity: 2,
        distance: 15.5,
        rating: 4.3,
        reviews: 32,
        stock: 20,
        displayEmoji: '🌾',
      ),
      MarketProduct(
        id: '3',
        name: 'Oignons Rouges',
        producerName: 'Fatou Market Garden',
        producerId: 'producer_3',
        producerRating: 4.7,
        price: 800,
        unit: 'kg',
        quantity: 200,
        category: 'vegetables',
        description: 'Oignons rouges frais du plateau de Thiès',
        certifications: ['local'],
        isOrganic: true,
        location: 'Thiès',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        status: 'available',
        views: 80,
        sales: 60,
        minOrderQuantity: 3,
        distance: 8.2,
        rating: 4.5,
        reviews: 28,
        stock: 140,
        displayEmoji: '🧅',
      ),
      MarketProduct(
        id: '4',
        name: 'Poulets Fermiers',
        producerName: 'Mamadou Aviculture',
        producerId: 'producer_4',
        producerRating: 4.9,
        price: 5000,
        unit: 'pce',
        quantity: 30,
        category: 'poultry',
        description: 'Poulets élevés en plein air, nourris aux grains locaux',
        certifications: ['organic', 'local'],
        isOrganic: true,
        location: 'Kaolack',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
        status: 'available',
        views: 200,
        sales: 25,
        minOrderQuantity: 1,
        distance: 25.7,
        rating: 4.8,
        reviews: 40,
        stock: 5,
        displayEmoji: '🐔',
      ),
      MarketProduct(
        id: '5',
        name: 'Lait Frais',
        producerName: 'Aïssatou Ferme Laitière',
        producerId: 'producer_5',
        producerRating: 4.4,
        price: 1200,
        unit: 'l',
        quantity: 100,
        category: 'dairy',
        description: 'Lait frais pasteurisé de vaches nourries à l\'herbe',
        certifications: ['organic'],
        isOrganic: true,
        location: 'Louga',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        status: 'available',
        views: 90,
        sales: 70,
        minOrderQuantity: 2,
        distance: 12.3,
        rating: 4.2,
        reviews: 35,
        stock: 30,
        displayEmoji: '🥛',
      ),
    ];
    
    applyFilters();
  }
  
  void applyFilters() {
    if (allProducts.isEmpty) return;
    
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
    filtered = filtered.where((p) => 
        p.price >= priceRange.value[0] && 
        p.price <= priceRange.value[1]).toList();
    
    // Filtre par disponibilité
    filtered = filtered.where((p) => 
        p.status == 'available' && p.stock > 0).toList();
    
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
    Get.snackbar(
      'Panier', 
      '${product.name} ajouté au panier',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  void viewProductDetails(MarketProduct product) {
    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: Text(
                      product.displayEmoji ?? '📦',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Détails du produit
              _buildProductDetailRow('Producteur', product.producerName),
              _buildProductDetailRow('Localisation', product.location ?? 'Non spécifié'),
              _buildProductDetailRow('Catégorie', getCategoryName(product.category)),
              _buildProductDetailRow('Prix', '${product.price.toInt()} FCFA/${product.unit}'),
              _buildProductDetailRow('Stock disponible', '${product.stock} ${product.unit}'),
              _buildProductDetailRow('Quantité minimum', '${product.minOrderQuantity} ${product.unit}'),
              _buildProductDetailRow('Distance', '${product.distance.toStringAsFixed(1)} km'),
              _buildProductDetailRow('Note produit', '${product.rating.toStringAsFixed(1)}/5 (${product.reviews} avis)'),
              
              if (product.certifications != null && product.certifications!.isNotEmpty)
                _buildProductDetailRow('Certifications', product.certifications!.join(', ')),
              
              _buildProductDetailRow('Bio', product.isOrganic ? 'Oui ✅' : 'Non ❌'),
              
              if (product.description != null && product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
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
              
              const SizedBox(height: 24),
              
              // Boutons d'action
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
    );
  }
  
  Widget _buildProductDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
  
  // Méthode pour recharger les produits
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
