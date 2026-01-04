// lib/features/buyer/presentation/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/features/buyer/presentation/controllers/cart_controller.dart';
import 'package:jokko_agro/core/services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController controller = Get.put(CartController());
  final CartService cartService = Get.find<CartService>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la commande'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section informations personnelles
              _buildSectionTitle('Informations personnelles'),
              _buildPersonalInfoSection(),

              const SizedBox(height: 24),

              // Section adresse de livraison
              _buildSectionTitle('Adresse de livraison'),
              _buildDeliveryAddressSection(),

              const SizedBox(height: 24),

              // Section méthode de paiement
              _buildSectionTitle('Méthode de paiement'),
              _buildPaymentMethodSection(),

              const SizedBox(height: 24),

              // Section notes
              _buildSectionTitle('Notes supplémentaires (optionnel)'),
              _buildNotesSection(),

              const SizedBox(height: 32),

              // Résumé de la commande
              _buildOrderSummary(),

              const SizedBox(height: 32),

              // Bouton de confirmation
              _buildConfirmButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: controller.fullNameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom complet';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                prefixText: '+221 ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre numéro de téléphone';
                }
                if (value.length < 9) {
                  return 'Numéro de téléphone invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: controller.addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse complète *',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
                hintText: 'Ex: Rue 10 x Rue 11, Plateau, Dakar',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre adresse de livraison';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Nous livrons dans un rayon de 50km autour de Dakar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              children: controller.paymentMethods.map((method) {
                return RadioListTile<String>(
                  title: Row(
                    children: [
                      Text(method['icon']),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              method['description'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  value: method['id'],
                  groupValue: controller.selectedPaymentMethod.value,
                  onChanged: (value) {
                    controller.selectedPaymentMethod.value = value!;
                  },
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: controller.notesController,
          decoration: const InputDecoration(
            labelText: 'Instructions spéciales',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(),
            hintText: 'Ex: Livrer après 18h, appeler avant de venir...',
          ),
          maxLines: 3,
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif de la commande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Liste des articles
            Obx(() {
              return Column(
                children: cartService.cartItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} (x${item.quantity})',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          controller.formatPrice(item.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),

            const Divider(height: 20),

            // Totaux
            _buildSummaryRow(
                'Sous-total', cartService.subtotal), // Utiliser subtotal
            _buildSummaryRow('Frais de livraison',
                cartService.deliveryFee), // Utiliser deliveryFee
            const Divider(height: 20),
            _buildSummaryRow(
              'Total à payer',
              cartService.total, // Utiliser total
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            controller.formatPrice(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _showConfirmationDialog();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'CONFIRMER LA COMMANDE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    Get.defaultDialog(
      title: 'Confirmer la commande',
      middleText:
          'Êtes-vous sûr de vouloir passer cette commande ?\n\nTotal: ${controller.formatPrice(cartService.total)}', // Utiliser total
      textConfirm: 'Confirmer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await controller.placeOrder();
      },
    );
  }
}
