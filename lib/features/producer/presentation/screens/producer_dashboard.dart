// lib/features/producer/presentation/screens/producer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/core/services/auth_service.dart';

class ProducerDashboard extends StatelessWidget {
  const ProducerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Producteur'),
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
          return _buildBody(context, userData);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/producer/add-product'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildBody(BuildContext context, Map<String, String?> userData) {
    return ListView(
      children: [
        // Stats Section
        _buildStatsSection(context, userData),

        // Quick Actions
        _buildQuickActionsSection(context),

        // Recent Sales
        _buildRecentSalesSection(context),

        // Espace pour le FAB
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatsSection(
      BuildContext context, Map<String, String?> userData) {
    final fullName = userData['fullName'] ?? 'Producteur';
    final greeting =
        fullName.isNotEmpty ? 'Bonjour, $fullName!' : 'Bonjour, Producteur!';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.agriculture,
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
                      'Gérez vos produits et ventes',
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('12', 'Produits'),
              _buildStatItem('5', 'Ventes'),
              _buildStatItem('4.8', 'Note'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0, bottom: 16),
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
                icon: Icons.add_circle_outline,
                label: 'Ajouter produit',
                color: AppColors.primary,
                onTap: () => Get.toNamed('/producer/add-product'),
              ),
              _buildActionCard(
                icon: Icons.list_alt,
                label: 'Mes produits',
                color: AppColors.secondary,
                onTap: () => Get.toNamed('/producer/products'),
              ),
              _buildActionCard(
                icon: Icons.sell,
                label: 'Ventes',
                color: AppColors.accent,
                onTap: () => Get.toNamed('/producer/sales'),
              ),
              _buildActionCard(
                icon: Icons.security,
                label: 'Certification',
                color: AppColors.blockchain,
                onTap: () {
                  Get.toNamed('/producer/certification');
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentSalesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ventes récentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/producer/sales'),
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSalesList(),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return Column(
      children: List.generate(5, (index) {
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
                color: AppColors.success.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: AppColors.success,
                size: 30,
              ),
            ),
            title: Text(
              'Vente ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text('Tomates • 10kg'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(index + 1) * 5000} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  index % 2 == 0 ? 'Livré' : 'En cours',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color:
                        index % 2 == 0 ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final fullName = userData['fullName'] ?? 'Producteur Jokko Agro';
        final email = userData['email'] ?? 'producteur@example.com';

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
                          Icons.agriculture,
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
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Ajouter produit'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/add-product');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('Mes produits'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/products');
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell),
                title: const Text('Mes ventes'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/sales');
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messages'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/messages');
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Réputation'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/reputation');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Certification Blockchain'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/certification');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Paramètres'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Aide'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/producer/help');
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
