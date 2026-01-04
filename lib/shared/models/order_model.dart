// lib/shared/models/order_model.dart
import 'package:jokko_agro/shared/models/cart_model.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userEmail;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final String paymentMethod;
  final String deliveryAddress;
  final String? notes;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? deliveryPerson;
  final String? deliveryPhone;
  
  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.notes,
    required this.orderDate,
    this.deliveryDate,
    this.deliveryPerson,
    this.deliveryPhone,
  });
  
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryPerson': deliveryPerson,
      'deliveryPhone': deliveryPhone,
    };
  }
  
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userEmail: map['userEmail'] ?? '',
      items: List<CartItem>.from(
        (map['items'] ?? []).map((x) => CartItem.fromMap(x)),
      ),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      deliveryAddress: map['deliveryAddress'] ?? '',
      notes: map['notes'],
      orderDate: DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
      deliveryDate: map['deliveryDate'] != null ? DateTime.parse(map['deliveryDate']) : null,
      deliveryPerson: map['deliveryPerson'],
      deliveryPhone: map['deliveryPhone'],
    );
  }
}