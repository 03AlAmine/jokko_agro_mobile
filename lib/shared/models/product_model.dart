// lib/shared/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String? description;
  final double price;
  final int quantity;
  final String unit;
  final List<String>? certifications;
  final bool isOrganic;
  final DateTime? harvestDate;
  final DateTime? expirationDate;
  final String? storageConditions;
  final String? location;
  final String? contactPhone;
  final int minOrderQuantity;
  final String producerId;
  final String producerName;
  final String producerPhone;
  final List<String> images;
  final String status;
  final int views;
  final int sales;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    this.certifications,
    this.isOrganic = false,
    this.harvestDate,
    this.expirationDate,
    this.storageConditions,
    this.location,
    this.contactPhone,
    this.minOrderQuantity = 1,
    required this.producerId,
    required this.producerName,
    required this.producerPhone,
    this.images = const [],
    this.status = 'available',
    this.views = 0,
    this.sales = 0,
    this.rating = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory pour créer depuis Map (Firestore)
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    // Fonction helper pour convertir les dates
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        try {
          // Essayer différents formats de date
          final formats = [
            'dd/MM/yyyy',
            'yyyy-MM-dd',
            'MM/dd/yyyy',
            'dd-MM-yyyy',
          ];
          
          for (var format in formats) {
            try {
              // Simple parsing pour le format dd/MM/yyyy
              if (format == 'dd/MM/yyyy' && dateValue.contains('/')) {
                final parts = dateValue.split('/');
                if (parts.length == 3) {
                  final day = int.tryParse(parts[0]);
                  final month = int.tryParse(parts[1]);
                  final year = int.tryParse(parts[2]);
                  if (day != null && month != null && year != null) {
                    return DateTime(year, month, day);
                  }
                }
              }
            } catch (_) {}
          }
          
          // Essayer le parsing ISO
          return DateTime.tryParse(dateValue);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    // Fonction helper pour les dates requises
    DateTime parseRequiredDate(dynamic dateValue, {DateTime? defaultValue}) {
      final parsed = parseDate(dateValue);
      return parsed ?? defaultValue ?? DateTime.now();
    }

    return Product(
      id: id,
      name: data['name']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      description: data['description']?.toString(),
      price: (data['price'] is int ? data['price'].toDouble() : data['price'] ?? 0.0).toDouble(),
      quantity: (data['quantity'] ?? 0).toInt(),
      unit: data['unit']?.toString() ?? 'kg',
      certifications: data['certifications'] != null 
          ? List<String>.from(data['certifications'])
          : null,
      isOrganic: data['isOrganic'] == true,
      harvestDate: parseDate(data['harvestDate']),
      expirationDate: parseDate(data['expirationDate']),
      storageConditions: data['storageConditions']?.toString(),
      location: data['location']?.toString(),
      contactPhone: data['contactPhone']?.toString(),
      minOrderQuantity: (data['minOrderQuantity'] ?? 1).toInt(),
      producerId: data['producerId']?.toString() ?? '',
      producerName: data['producerName']?.toString() ?? '',
      producerPhone: data['producerPhone']?.toString() ?? '',
      images: data['images'] != null
          ? List<String>.from(data['images'])
          : [],
      status: data['status']?.toString() ?? 'available',
      views: (data['views'] ?? 0).toInt(),
      sales: (data['sales'] ?? 0).toInt(),
      rating: (data['rating'] is int ? data['rating'].toDouble() : data['rating'] ?? 0.0).toDouble(),
      isActive: data['isActive'] != false,
      createdAt: parseRequiredDate(data['createdAt']),
      updatedAt: parseRequiredDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'certifications': certifications,
      'isOrganic': isOrganic,
      'harvestDate': harvestDate != null 
          ? Timestamp.fromDate(harvestDate!)
          : null,
      'expirationDate': expirationDate != null 
          ? Timestamp.fromDate(expirationDate!)
          : null,
      'storageConditions': storageConditions,
      'location': location,
      'contactPhone': contactPhone,
      'minOrderQuantity': minOrderQuantity,
      'producerId': producerId,
      'producerName': producerName,
      'producerPhone': producerPhone,
      'images': images,
      'status': status,
      'views': views,
      'sales': sales,
      'rating': rating,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}