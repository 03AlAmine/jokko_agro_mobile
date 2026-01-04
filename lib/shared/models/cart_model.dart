// lib/features/cart/domain/models/cart_item.dart
import 'package:jokko_agro/shared/models/market_model.dart';

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String producerId;
  final String producerName;
  final double price;
  final String unit;
  final int quantity;
  final int stock;
  final int minOrderQuantity;
  final String? imageUrl;
  final String? displayEmoji;
  
  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.producerId,
    required this.producerName,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.stock,
    required this.minOrderQuantity,
    this.imageUrl,
    this.displayEmoji,
  });
  
  double get totalPrice => price * quantity;
  
  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? producerId,
    String? producerName,
    double? price,
    String? unit,
    int? quantity,
    int? stock,
    int? minOrderQuantity,
    String? imageUrl,
    String? displayEmoji,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      producerId: producerId ?? this.producerId,
      producerName: producerName ?? this.producerName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      displayEmoji: displayEmoji ?? this.displayEmoji,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'producerId': producerId,
      'producerName': producerName,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'stock': stock,
      'minOrderQuantity': minOrderQuantity,
      'imageUrl': imageUrl,
      'displayEmoji': displayEmoji,
    };
  }
  
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      producerId: map['producerId'] ?? '',
      producerName: map['producerName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'kg',
      quantity: map['quantity'] ?? 1,
      stock: map['stock'] ?? 0,
      minOrderQuantity: map['minOrderQuantity'] ?? 1,
      imageUrl: map['imageUrl'],
      displayEmoji: map['displayEmoji'],
    );
  }
  
  factory CartItem.fromMarketProduct(MarketProduct product, {int quantity = 1}) {
    return CartItem(
      id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      producerId: product.producerId,
      producerName: product.producerName,
      price: product.price,
      unit: product.unit,
      quantity: quantity,
      stock: product.stock,
      minOrderQuantity: product.minOrderQuantity,
      displayEmoji: product.displayEmoji,
    );
  }
}