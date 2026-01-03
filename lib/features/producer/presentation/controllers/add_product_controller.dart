// lib/features/producer/presentation/controllers/add_product_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/core/services/firebase_service.dart';
import 'dart:developer' as developer;

class AddProductController extends GetxController {
  // Contrôleurs de formulaire
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController minOrderQuantityController =
      TextEditingController(text: '1');
  final TextEditingController harvestDateController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();
  final TextEditingController storageConditionsController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();

  // Variables réactives
  var selectedCategory = ''.obs;
  var selectedUnit = 'kg'.obs;
  var isOrganic = false.obs;
  var isLoading = false.obs;
  var mainImage = Rx<File?>(null);
  var additionalImages = <File>[].obs;
  var selectedCertifications = <String>[].obs;

  // Données statiques
  final List<Map<String, dynamic>> categories = [
    {'id': 'vegetables', 'name': 'Légumes', 'icon': '🥦'},
    {'id': 'fruits', 'name': 'Fruits', 'icon': '🍎'},
    {'id': 'cereals', 'name': 'Céréales', 'icon': '🌾'},
    {'id': 'tubers', 'name': 'Tubercules', 'icon': '🥔'},
    {'id': 'legumes', 'name': 'Légumineuses', 'icon': '🥜'},
    {'id': 'spices', 'name': 'Épices', 'icon': '🌶️'},
    {'id': 'dairy', 'name': 'Produits laitiers', 'icon': '🥛'},
    {'id': 'poultry', 'name': 'Volaille', 'icon': '🐔'},
  ];

  final List<Map<String, dynamic>> units = [
    {'id': 'kg', 'name': 'Kilogramme', 'symbol': 'kg'},
    {'id': 'g', 'name': 'Gramme', 'symbol': 'g'},
    {'id': 'l', 'name': 'Litre', 'symbol': 'L'},
    {'id': 'ml', 'name': 'Millilitre', 'symbol': 'ml'},
    {'id': 'piece', 'name': 'Pièce', 'symbol': 'pce'},
    {'id': 'dozen', 'name': 'Douzaine', 'symbol': 'dz'},
    {'id': 'bunch', 'name': 'Botte', 'symbol': 'bt'},
    {'id': 'bag', 'name': 'Sac', 'symbol': 'sac'},
  ];

  final List<Map<String, dynamic>> certifications = [
    {
      'id': 'organic',
      'name': 'Bio',
      'description': 'Agriculture biologique',
      'icon': '🌱'
    },
    {
      'id': 'local',
      'name': 'Local',
      'description': 'Produit local',
      'icon': '📍'
    },
    {
      'id': 'fairtrade',
      'name': 'Équitable',
      'description': 'Commerce équitable',
      'icon': '🤝'
    },
    {
      'id': 'seasonal',
      'name': 'Saison',
      'description': 'Produit de saison',
      'icon': '🌞'
    },
  ];

  final ImagePicker _picker = ImagePicker();
  final AuthService authService = Get.find<AuthService>();

  // Helper pour parser les dates
  Timestamp? _parseDateString(String dateString) {
    try {
      // Format: "dd/MM/yyyy"
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        return Timestamp.fromDate(date);
      }
    } catch (e) {
      developer.log('Erreur parsing date: $e', name: 'AddProductController');
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _prefillUserData();
  }

  void _prefillUserData() {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser;
    if (user != null) {
      contactPhoneController.text = user.phone;
      locationController.text = user.location ?? 'Dakar, Sénégal';
    }
  }

  // Gestion des images
  Future<void> pickMainImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        mainImage.value = File(image.path);
      }
    } catch (e) {
      developer.log('Erreur lors de la sélection de l\'image: $e',
          name: 'AddProductController');
      Get.snackbar('Erreur', 'Impossible de sélectionner l\'image');
    }
  }

  Future<void> pickAdditionalImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        for (var image in images) {
          if (additionalImages.length < 4) {
            additionalImages.add(File(image.path));
          } else {
            break; // Maximum 4 images
          }
        }
      }
    } catch (e) {
      developer.log('Erreur lors de la sélection des images: $e',
          name: 'AddProductController');
      Get.snackbar('Erreur', 'Impossible de sélectionner les images');
    }
  }

  void removeMainImage() {
    mainImage.value = null;
  }

  void removeAdditionalImage(int index) {
    if (index >= 0 && index < additionalImages.length) {
      additionalImages.removeAt(index);
    }
  }

  void toggleCertification(String certId) {
    if (selectedCertifications.contains(certId)) {
      selectedCertifications.remove(certId);
    } else {
      selectedCertifications.add(certId);
    }
  }

  // Sélection de dates
  Future<void> pickHarvestDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        harvestDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      }
    } catch (e) {
      developer.log('Erreur lors de la sélection de la date: $e',
          name: 'AddProductController');
    }
  }

  Future<void> pickExpirationDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 30)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        expirationDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      }
    } catch (e) {
      developer.log('Erreur lors de la sélection de la date: $e',
          name: 'AddProductController');
    }
  }

  // Soumission du formulaire
  Future<bool> submitProduct() async {
    try {
      isLoading.value = true;

      final user = authService.currentUser;
      if (user == null) {
        Get.snackbar('Erreur', 'Utilisateur non connecté');
        return false;
      }

      // Validation
      if (nameController.text.isEmpty || selectedCategory.value.isEmpty) {
        Get.snackbar('Erreur', 'Veuillez remplir les champs obligatoires');
        return false;
      }

      final price = double.tryParse(priceController.text);
      final quantity = int.tryParse(quantityController.text);
      final minOrderQuantity = int.tryParse(minOrderQuantityController.text);

      if (price == null || price <= 0) {
        Get.snackbar('Erreur', 'Prix invalide');
        return false;
      }

      if (quantity == null || quantity <= 0) {
        Get.snackbar('Erreur', 'Quantité invalide');
        return false;
      }

      // Préparer les données du produit
      final productData = {
        'name': nameController.text.trim(),
        'category': selectedCategory.value,
        'description': descriptionController.text.trim(),
        'price': price,
        'quantity': quantity,
        'unit': selectedUnit.value,
        'certifications': selectedCertifications.toList(),
        'isOrganic': isOrganic.value,
        // Convertir les dates en Timestamp si elles existent
        'harvestDate': harvestDateController.text.isNotEmpty
            ? _parseDateString(harvestDateController.text)
            : null,
        'expirationDate': expirationDateController.text.isNotEmpty
            ? _parseDateString(expirationDateController.text)
            : null,
        'storageConditions': storageConditionsController.text.isNotEmpty
            ? storageConditionsController.text.trim()
            : null,
        'location': locationController.text.isNotEmpty
            ? locationController.text.trim()
            : null,
        'contactPhone': contactPhoneController.text.isNotEmpty
            ? contactPhoneController.text.trim()
            : null,
        'producerId': user.uid,
        'producerName': user.fullName,
        'producerPhone': user.phone,
        'status': 'available',
        'views': 0,
        'sales': 0,
        'rating': 0.0,
        'ratingCount': 0,
        'isActive': true,
        'images': [], // Images facultatives pour l'instant
        'featuredImage': '', // Image principale facultative
        'minOrderQuantity': minOrderQuantity ?? 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Sauvegarder dans Firestore
      try {
        await FirebaseService.firestore.collection('products').add(productData);

        developer.log('Produit ajouté avec succès',
            name: 'AddProductController');

        // Réinitialiser le formulaire
        _resetForm();

        return true;
      } catch (e) {
        developer.log('Erreur Firebase: $e', name: 'AddProductController');
        Get.snackbar(
            'Erreur', 'Impossible de sauvegarder dans la base de données');
        return false;
      }
    } catch (e) {
      developer.log('Erreur lors de l\'ajout du produit: $e',
          name: 'AddProductController');
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    minOrderQuantityController.clear();
    minOrderQuantityController.text = '1';
    harvestDateController.clear();
    expirationDateController.clear();
    storageConditionsController.clear();
    locationController.clear();
    contactPhoneController.clear();
    selectedCategory.value = '';
    selectedUnit.value = 'kg';
    isOrganic.value = false;
    mainImage.value = null;
    additionalImages.clear();
    selectedCertifications.clear();
  }

  void saveAsDraft() {
    // Sauvegarde les données dans le stockage local
    final draftData = {
      'name': nameController.text,
      'category': selectedCategory.value,
      'description': descriptionController.text,
      'price': priceController.text,
      'quantity': quantityController.text,
      'unit': selectedUnit.value,
      'certifications': selectedCertifications.toList(),
      'isOrganic': isOrganic.value,
      'harvestDate': harvestDateController.text,
      'expirationDate': expirationDateController.text,
      'storageConditions': storageConditionsController.text,
      'location': locationController.text,
      'contactPhone': contactPhoneController.text,
      'savedAt': DateTime.now().toIso8601String(),
    };

    developer.log('Brouillon sauvegardé: $draftData',
        name: 'AddProductController');

    Get.snackbar(
      'Brouillon',
      'Produit sauvegardé comme brouillon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    minOrderQuantityController.dispose();
    harvestDateController.dispose();
    expirationDateController.dispose();
    storageConditionsController.dispose();
    locationController.dispose();
    contactPhoneController.dispose();
    super.onClose();
  }
}