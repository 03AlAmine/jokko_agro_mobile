// lib/features/buyer/presentation/screens/buyer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/core/services/auth_service.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Acheteur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: FutureBuilder<Map<String, String?>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final userData = snapshot.data ?? {};
          return _buildBody(userData);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  Future<Map<String, String?>> _getUserData() async {
    final authService = AuthService();
    final fullName = await authService.getUserFullName();
    final email = await authService.getUserEmail();
    final role = await authService.getUserRole();
    
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
    };
  }

  Widget _buildBody(Map<String, String?> userData) {
    return ListView(
      children: [
        // Welcome Section
        _buildWelcomeSection(userData),
        
        // Quick Actions
        _buildQuickActions(),
        
        // Recent Products
        _buildRecentProducts(),
        
        // Espace pour le FAB
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildWelcomeSection(Map<String, String?> userData) {
    final fullName = userData['fullName'] ?? 'Acheteur';
    final greeting = fullName.isNotEmpty ? 'Bonjour, $fullName!' : 'Bonjour, Acheteur!';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Découvrez des produits agricoles certifiés',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: Icons.qr_code_scanner,
                label: 'Scanner QR',
                color: AppColors.primary,
                onTap: () => Get.toNamed('/buyer/scan'),
              ),
              _buildActionCard(
                icon: Icons.store,
                label: 'Marché',
                color: AppColors.secondary,
                onTap: () => Get.toNamed('/buyer/market'),
              ),
              _buildActionCard(
                icon: Icons.shopping_cart,
                label: 'Panier',
                color: AppColors.accent,
                onTap: () => Get.toNamed('/buyer/cart'),
              ),
              _buildActionCard(
                icon: Icons.track_changes,
                label: 'Suivi commande',
                color: AppColors.success,
                onTap: () => Get.toNamed('/buyer/tracking'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Produits récents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: List.generate(10, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.agriculture,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            title: Text(
              'Produit ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text('Certifié blockchain • Dakar'),
            trailing: Text(
              '${(index + 1) * 500} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final fullName = userData['fullName'] ?? 'Acheteur Jokko Agro';
        final email = userData['email'] ?? 'acheteur@example.com';

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Tableau de bord'),
                onTap: () {
                  // Fermer le drawer et rester sur la même page
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Marché'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/market');
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scanner QR'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/scan');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Panier'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/cart');
                },
              ),
              ListTile(
                leading: const Icon(Icons.track_changes),
                title: const Text('Mes commandes'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/tracking');
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messages'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/messages');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Aide'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/buyer/help');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService().logout();
                  Get.offAllNamed('/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}