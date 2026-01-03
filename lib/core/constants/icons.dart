// lib/core/constants/icons.dart
import 'package:flutter/material.dart';

class AppIcons {
  // Catégories
  static const String vegetables = '🥦';
  static const String fruits = '🍎';
  static const String cereals = '🌾';
  static const String tubers = '🥔';
  static const String legumes = '🥜';
  static const String spices = '🌶️';
  static const String dairy = '🥛';
  static const String poultry = '🐔';
  
  // Certifications
  static const String organic = '🌱';
  static const String local = '📍';
  static const String fairtrade = '🤝';
  static const String seasonal = '🌞';
  
  // Actions
  static const String addToCart = '🛒';
  static const String favorite = '❤️';
  static const String share = '📤';
  static const String filter = '⚙️';
  static const String sort = '📊';
  static const String search = '🔍';
  static const String scan = '📱';
  
  // Statut
  static const String available = '✅';
  static const String lowStock = '⚠️';
  static const String outOfStock = '❌';
  static const String certified = '🏆';
  
  // Navigation
  static const String home = '🏠';
  static const String market = '🛍️';
  static const String cart = '🛒';
  static const String orders = '📦';
  static const String profile = '👤';
  
  // Évaluation
  static const String starFilled = '⭐';
  static const String starHalf = '🌟';
  static const String starEmpty = '☆';
  
  // Métriques
  static const String distance = '📍';
  static const String price = '💰';
  static const String rating = '⭐';
  static const String views = '👁️';
  static const String sales = '📈';
  
  // Icons Material avec couleurs
  static IconData get categoryIcon => Icons.category;
  static IconData get filterIcon => Icons.filter_list;
  static IconData get sortIcon => Icons.sort;
  static IconData get searchIcon => Icons.search;
  static IconData get cartIcon => Icons.shopping_cart;
  static IconData get favoriteIcon => Icons.favorite;
  static IconData get favoriteBorderIcon => Icons.favorite_border;
  static IconData get locationIcon => Icons.location_on;
  static IconData get distanceIcon => Icons.place;
  static IconData get priceIcon => Icons.attach_money;
  static IconData get ratingIcon => Icons.star;
  static IconData get organicIcon => Icons.eco;
  static IconData get localIcon => Icons.pin_drop;
  static const IconData certifiedIcon = Icons.verified;
  static IconData get trendingIcon => Icons.trending_up;
  static IconData get recentIcon => Icons.access_time;
  static IconData get popularIcon => Icons.whatshot;
}

// Classes d'icônes par catégorie
class CategoryIcons {
  static Map<String, String> icons = {
    'vegetables': '🥦',
    'fruits': '🍎',
    'cereals': '🌾',
    'tubers': '🥔',
    'legumes': '🥜',
    'spices': '🌶️',
    'dairy': '🥛',
    'poultry': '🐔',
  };
  
  static String getIcon(String category) {
    return icons[category] ?? '📦';
  }
}