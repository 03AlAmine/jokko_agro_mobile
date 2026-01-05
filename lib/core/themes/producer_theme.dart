// lib/core/constants/producer_theme.dart
import 'package:flutter/material.dart';

class ProducerTheme {
  // Couleurs spécifiques aux producteurs
  static const Color producerPrimary = Color(0xFF2E7D32); // Vert agricole
  static const Color producerSecondary = Color(0xFFFF9800); // Orange
  static const Color producerSuccess = Color(0xFF4CAF50); // Vert succès
  static const Color producerWarning = Color(0xFFFF9800); // Orange avertissement
  static const Color producerError = Color(0xFFF44336); // Rouge erreur
  static const Color producerInfo = Color(0xFF2196F3); // Bleu info
  
  // Gradients
  static Gradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [producerPrimary, Color(0xFF4CAF50)],
  );
  
  // Ombre pour les cartes
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Bordures
  static BorderRadius cardBorderRadius = BorderRadius.circular(16);
  static BorderRadius buttonBorderRadius = BorderRadius.circular(12);
  static BorderRadius inputBorderRadius = BorderRadius.circular(10);
  
  // Typographie
  static TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.grey[800],
  );
  
  static TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.grey[800],
  );
  
  static TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.grey[800],
  );
  
  static TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.grey[700],
  );
  
  static TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.grey[600],
  );
  
  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: Colors.grey[500],
  );
  
  static TextStyle caption = TextStyle(
    fontSize: 11,
    color: Colors.grey[400],
  );
}