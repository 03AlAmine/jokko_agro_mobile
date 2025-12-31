// lib/features/auth/presentation/screens/role_selection_screen.dart - CORRIGÉ
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(String role) async {
    // Save role to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    
    // Navigate to appropriate dashboard
    if (role == 'buyer') {
      Get.offAllNamed('/buyer/dashboard');
    } else {
      Get.offAllNamed('/producer/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 1,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 100,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Choisissez votre profil',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Comment souhaitez-vous utiliser Jokko Agro ?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Role Cards
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Buyer Card
                    GestureDetector(
                      onTap: () => _selectRole('buyer'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            // SOLUTION 1 : Utiliser Color.fromRGBO
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1), // R, G, B, Opacity (0.1 = 10%)
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              size: 60,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Acheteur',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Achetez des produits agricoles certifiés, scannez les QR codes pour vérifier l\'origine',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                SizedBox(width: 8),
                                Text('Scan QR Code'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                SizedBox(width: 8),
                                Text('Paiement sécurisé'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Producer Card
                    GestureDetector(
                      onTap: () => _selectRole('producer'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            // SOLUTION 1 : Utiliser Color.fromRGBO
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.1), // R, G, B, Opacity (0.1 = 10%)
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.agriculture,
                              size: 60,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Producteur',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Vendez vos produits, certifiez leur origine avec la blockchain, gérez vos stocks',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                SizedBox(width: 8),
                                Text('Certification Blockchain'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                SizedBox(width: 8),
                                Text('Assistant vocal Wolof'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}