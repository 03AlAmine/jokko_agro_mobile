// lib/features/buyer/presentation/controllers/cart_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/cart_service.dart';
import 'package:jokko_agro/shared/models/cart_model.dart';

class CartController extends GetxController {
  final CartService cartService = Get.find<CartService>();
  
  // Variables pour le formulaire de checkout
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final RxString selectedPaymentMethod = 'cash'.obs;
  
  // Options de paiement
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'cash',
      'name': 'Paiement à la livraison',
      'icon': '💵',
      'description': 'Payez en espèces lors de la livraison'
    },
    {
      'id': 'orange_money',
      'name': 'Orange Money',
      'icon': '🟠',
      'description': 'Paiement via Orange Money'
    },
    {
      'id': 'wave',
      'name': 'Wave',
      'icon': '🌊',
      'description': 'Paiement via Wave'
    },
    {
      'id': 'free_money',
      'name': 'Free Money',
      'icon': '🟢',
      'description': 'Paiement via Free Money'
    },
  ];
  
  @override
  void onInit() {
    super.onInit();
    // Pré-remplir les informations utilisateur si disponibles
    _prefillUserInfo();
  }
  
  void _prefillUserInfo() {
    // À remplacer par les informations de l'utilisateur connecté
    fullNameController.text = 'Client Jokko Agro';
    phoneController.text = '77 123 45 67';
    emailController.text = 'client@jokkoagro.com';
    addressController.text = 'Dakar, Sénégal';
  }
  
  void incrementQuantity(CartItem item) {
    cartService.updateQuantity(item.productId, item.quantity + 1);
  }
  
  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      cartService.updateQuantity(item.productId, item.quantity - 1);
    }
  }
  
  void removeItem(CartItem item) {
    Get.defaultDialog(
      title: 'Confirmer la suppression',
      middleText: 'Êtes-vous sûr de vouloir retirer ${item.productName} du panier ?',
      textConfirm: 'Supprimer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      onConfirm: () {
        cartService.removeFromCart(item.productId);
        Get.back();
      },
    );
  }
  
  void clearAllItems() {
    Get.defaultDialog(
      title: 'Vider le panier',
      middleText: 'Êtes-vous sûr de vouloir vider tout le panier ?',
      textConfirm: 'Vider',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      onConfirm: () {
        cartService.clearCart();
        Get.back();
      },
    );
  }
  
  Future<void> proceedToCheckout() async {
    // Validation du formulaire
    if (fullNameController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer votre nom complet');
      return;
    }
    
    if (phoneController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer votre numéro de téléphone');
      return;
    }
    
    if (addressController.text.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer votre adresse de livraison');
      return;
    }
    
    // Passer à l'écran de confirmation
    Get.toNamed('/checkout');
  }
  
  Future<void> placeOrder() async {
    try {
      await cartService.checkout(
        userName: fullNameController.text,
        userPhone: phoneController.text,
        userEmail: emailController.text,
        deliveryAddress: addressController.text,
        paymentMethod: selectedPaymentMethod.value,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la commande: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  String formatPrice(double price) {
    return '${price.toInt()} FCFA';
  }
  
  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }
}