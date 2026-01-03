// lib/shared/models/user_model.dart - MODIFIÉ
class AppUser {
  final String uid;
  final String email;
  final String phone;
  final String fullName;
  final String role; // 'buyer', 'producer', 'admin'
  final String? location; // Changé de Map<String, dynamic>? à String?
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? wolofName; // Pour l'assistant vocal

  AppUser({
    required this.uid,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    this.location, // Ajouté ici
    this.profileImage,
    required this.createdAt,
    this.updatedAt,
    this.wolofName,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'fullName': fullName,
      'role': role,
      'location': location, // Ajouté ici
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
      location: map['location'], // Ajouté ici
      profileImage: map['profileImage'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      wolofName: map['wolofName'],
    );
  }
}