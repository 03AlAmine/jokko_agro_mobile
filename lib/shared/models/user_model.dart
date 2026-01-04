// lib/shared/models/user_model.dart
// ignore_for_file: prefer_null_aware_operators

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String phone;
  final String fullName;
  final String role; // 'buyer' ou 'producer'
  final String? location;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double? rating;
  final int? totalSales;
  final int? totalOrders;
  
  AppUser({
    required this.uid,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    this.location,
    this.profileImageUrl,
    required this.createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.rating,
    this.totalSales,
    this.totalOrders,
  }) : updatedAt = updatedAt ?? createdAt;
  
  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'buyer',
      location: data['location'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] is Timestamp 
              ? data['createdAt'].toDate() 
              : DateTime.parse(data['createdAt']))
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp 
              ? data['updatedAt'].toDate() 
              : DateTime.parse(data['updatedAt']))
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
      rating: data['rating'] != null ? data['rating'].toDouble() : null,
      totalSales: data['totalSales'] != null ? data['totalSales'].toInt() : null,
      totalOrders: data['totalOrders'] != null ? data['totalOrders'].toInt() : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'role': role,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'rating': rating,
      'totalSales': totalSales,
      'totalOrders': totalOrders,
    };
  }
  
  AppUser copyWith({
    String? uid,
    String? email,
    String? phone,
    String? fullName,
    String? role,
    String? location,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? rating,
    int? totalSales,
    int? totalOrders,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
  
  bool get isProducer => role == 'producer';
  bool get isBuyer => role == 'buyer';
  
  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, fullName: $fullName, role: $role)';
  }
}