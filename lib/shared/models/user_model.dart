// lib/shared/models/user_model.dart
class AppUser {
  final String uid;
  final String email;
  final String phone;
  final String fullName;
  final String role; // 'buyer', 'producer', 'admin'
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? location;
  final String? wolofName; // Pour l'assistant vocal

  AppUser({
    required this.uid,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.wolofName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location,
      'wolofName': wolofName,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      fullName: map['fullName'] ?? '',
      role: map['role'] ?? 'buyer',
      profileImage: map['profileImage'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      location: map['location'],
      wolofName: map['wolofName'],
    );
  }
}