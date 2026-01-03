
// lib/shared/models/market_model.dart
import 'package:jokko_agro/shared/models/product_model.dart';

class MarketProduct {
  final String id;
  final String name;
  final String producerName;
  final String producerId;
  final double producerRating;
  final double price;
  final String unit;
  final int quantity;
  final String category;
  final String? description;
  final List<String>? certifications;
  final bool isOrganic;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final int views;
  final int sales;
  final int minOrderQuantity;
  
  // Spécifiques au marché
  final double distance; // en km
  final double rating; // note moyenne
  final int reviews; // nombre d'avis
  final int stock; // stock disponible
  final String? displayEmoji; // emoji pour l'affichage
  
  MarketProduct({
    required this.id,
    required this.name,
    required this.producerName,
    required this.producerId,
    required this.producerRating,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.category,
    this.description,
    this.certifications,
    this.isOrganic = false,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.views = 0,
    this.sales = 0,
    this.minOrderQuantity = 1,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.stock,
    this.displayEmoji,
  });
  
  factory MarketProduct.fromProduct(
    Product product, {
    required double distance,
    required double rating,
    required int reviews,
  }) {
    return MarketProduct(
      id: product.id,
      name: product.name,
      producerName: product.producerName,
      producerId: product.producerId,
      producerRating: 4.5, // À implémenter plus tard
      price: product.price,
      unit: product.unit,
      quantity: product.quantity,
      category: product.category,
      description: product.description,
      certifications: product.certifications,
      isOrganic: product.isOrganic,
      location: product.location,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      status: product.status,
      views: product.views,
      sales: product.sales,
      minOrderQuantity: product.minOrderQuantity,
      distance: distance,
      rating: rating,
      reviews: reviews,
      stock: product.quantity, // Le stock est la quantité totale
      displayEmoji: _getCategoryEmoji(product.category),
    );
  }
  
  static String? _getCategoryEmoji(String category) {
    final emojis = {
      'vegetables': '🥦',
      'fruits': '🍎',
      'cereals': '🌾',
      'tubers': '🥔',
      'legumes': '🥜',
      'poultry': '🐔',
      'dairy': '🥛',
      'spices': '🌶️',
    };
    return emojis[category];
  }
  
  bool get isCertified => certifications != null && certifications!.isNotEmpty;
  bool get isLocal => certifications?.contains('local') == true;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'producerName': producerName,
      'producerId': producerId,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'category': category,
      'description': description,
      'certifications': certifications,
      'isOrganic': isOrganic,
      'location': location,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'views': views,
      'sales': sales,
      'minOrderQuantity': minOrderQuantity,
      'distance': distance,
      'rating': rating,
      'reviews': reviews,
      'stock': stock,
      'displayEmoji': displayEmoji,
    };
  }
}