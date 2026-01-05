// lib/features/producer/presentation/screens/producer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/core/constants/producer_theme.dart';
import 'package:jokko_agro/core/widgets/producer_widgets.dart';
class ProducerDashboard extends StatelessWidget {
  const ProducerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Mon Espace Producteur',
        style: ProducerTheme.headlineSmall.copyWith(color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: ProducerTheme.producerPrimary,
      elevation: 0,
      actions: [
        _buildNotificationButton(),
        _buildMessagesButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Get.toNamed('/producer/notifications'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessagesButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.message_outlined, color: Colors.white),
          onPressed: () => Get.toNamed('/producer/messages'),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: ProducerTheme.producerInfo,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: ProducerTheme.producerPrimary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur de chargement',
              style: ProducerTheme.bodyLarge.copyWith(color: Colors.red),
            ),
          );
        }

        final userData = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Column(
            children: [
              // Bannière de bienvenue
              _buildWelcomeBanner(userData),
              const SizedBox(height: 16),

              // Statistiques
              _buildStatsSection(),
              const SizedBox(height: 24),

              // Actions rapides
              _buildQuickActionsSection(),
              const SizedBox(height: 24),

              // Produits populaires
              _buildTopProductsSection(),
              const SizedBox(height: 24),

              // Ventes récentes
              _buildRecentSalesSection(),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(Map<String, String?> userData) {
    final fullName = userData['fullName'] ?? 'Producteur';
    final greeting = fullName.isNotEmpty 
        ? 'Bonjour, $fullName!' 
        : 'Bonjour, Producteur!';

    return Container(
      decoration: BoxDecoration(
        gradient: ProducerTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Que souhaitez-vous faire aujourd\'hui ?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const ProducerSectionHeader(
            title: 'Aperçu de l\'activité',
            subtitle: 'Statistiques du mois',
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: const [
              ProducerStatCard(
                value: '12',
                label: 'Produits actifs',
                icon: Icons.inventory_2_outlined,
                color: ProducerTheme.producerPrimary,
              ),
              ProducerStatCard(
                value: '5',
                label: 'Ventes du mois',
                icon: Icons.sell_outlined,
                color: ProducerTheme.producerSecondary,
              ),
              ProducerStatCard(
                value: '24K',
                label: 'Revenus FCFA',
                icon: Icons.monetization_on_outlined,
                color: ProducerTheme.producerSuccess,
              ),
              ProducerStatCard(
                value: '4.8',
                label: 'Note moyenne',
                icon: Icons.star_outlined,
                color: ProducerTheme.producerWarning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ProducerSectionHeader(
            title: 'Actions rapides',
            subtitle: 'Gérez votre activité',
            action: TextButton(
              onPressed: () => Get.toNamed('/producer/help'),
              child: Text(
                'Aide ?',
                style: ProducerTheme.bodyMedium.copyWith(
                  color: ProducerTheme.producerInfo,
                ),
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: const [
              ProducerActionButton(
                label: 'Ajouter',
                icon: Icons.add,
                color: ProducerTheme.producerPrimary,
                onPressed: _goToAddProduct,
              ),
              ProducerActionButton(
                label: 'Produits',
                icon: Icons.inventory_2_outlined,
                color: ProducerTheme.producerSecondary,
                onPressed: _goToProducts,
              ),
              ProducerActionButton(
                label: 'Ventes',
                icon: Icons.sell_outlined,
                color: ProducerTheme.producerSuccess,
                onPressed: _goToSales,
              ),
              ProducerActionButton(
                label: 'Messages',
                icon: Icons.message_outlined,
                color: ProducerTheme.producerInfo,
                onPressed: _goToMessages,
              ),
              ProducerActionButton(
                label: 'Analyse',
                icon: Icons.analytics_outlined,
                color: ProducerTheme.producerPrimary,
                onPressed: _goToAnalytics,
              ),
              ProducerActionButton(
                label: 'Certification',
                icon: Icons.verified_outlined,
                color: ProducerTheme.producerPrimary,
                onPressed: _goToCertification,
              ),
              ProducerActionButton(
                label: 'Stock',
                icon: Icons.warehouse_outlined,
                color: ProducerTheme.producerWarning,
                onPressed: _goToInventory,
              ),
              ProducerActionButton(
                label: 'Paramètres',
                icon: Icons.settings_outlined,
                color: Colors.grey,
                onPressed: _goToSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Méthodes de navigation statiques
  static void _goToAddProduct() => Get.toNamed('/producer/add-product');
  static void _goToProducts() => Get.toNamed('/producer/products');
  static void _goToSales() => Get.toNamed('/producer/sales');
  static void _goToMessages() => Get.toNamed('/producer/messages');
  static void _goToAnalytics() => Get.toNamed('/producer/analytics');
  static void _goToCertification() => Get.toNamed('/producer/certification');
  static void _goToInventory() => Get.toNamed('/producer/inventory');
  static void _goToSettings() => Get.toNamed('/producer/settings');

  Widget _buildTopProductsSection() {
    final products = [
      {
        'name': 'Tomates bio',
        'category': 'Légumes',
        'sales': '42 ventes',
        'price': '1500 FCFA/kg',
        'icon': '🥦',
      },
      {
        'name': 'Mangues',
        'category': 'Fruits',
        'sales': '28 ventes',
        'price': '800 FCFA/kg',
        'icon': '🍎',
      },
      {
        'name': 'Riz local',
        'category': 'Céréales',
        'sales': '35 ventes',
        'price': '1200 FCFA/kg',
        'icon': '🌾',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ProducerSectionHeader(
            title: 'Produits populaires',
            subtitle: 'Les plus vendus cette semaine',
            action: TextButton(
              onPressed: () => Get.toNamed('/producer/products'),
              child: Text(
                'Tout voir',
                style: ProducerTheme.bodyMedium.copyWith(
                  color: ProducerTheme.producerPrimary,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Map<String, String> product) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      child: ProducerCard(
        onTap: () => Get.toNamed('/producer/products'),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ProducerTheme.producerPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  product['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['name']!,
                    style: ProducerTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ProducerTag(
                    label: product['category']!,
                    icon: Icons.category_outlined,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.sell_outlined,
                        size: 12,
                        color: ProducerTheme.producerSuccess,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product['sales']!,
                        style: ProducerTheme.caption.copyWith(
                          color: ProducerTheme.producerSuccess,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.attach_money_outlined,
                        size: 12,
                        color: ProducerTheme.producerWarning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product['price']!,
                        style: ProducerTheme.caption.copyWith(
                          color: ProducerTheme.producerWarning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSalesSection() {
    final sales = [
      {
        'product': 'Tomates bio',
        'quantity': '10kg',
        'buyer': 'Bakary N.',
        'amount': '15,000 FCFA',
        'status': 'livré',
        'color': ProducerTheme.producerSuccess,
      },
      {
        'product': 'Mangues',
        'quantity': '5kg',
        'buyer': 'Fatou D.',
        'amount': '4,000 FCFA',
        'status': 'en cours',
        'color': ProducerTheme.producerWarning,
      },
      {
        'product': 'Riz local',
        'quantity': '20kg',
        'buyer': 'Moussa S.',
        'amount': '24,000 FCFA',
        'status': 'livré',
        'color': ProducerTheme.producerSuccess,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ProducerSectionHeader(
            title: 'Ventes récentes',
            subtitle: 'Dernières transactions',
            action: TextButton(
              onPressed: () => Get.toNamed('/producer/sales'),
              child: Text(
                'Voir l\'historique',
                style: ProducerTheme.bodyMedium.copyWith(
                  color: ProducerTheme.producerPrimary,
                ),
              ),
            ),
          ),
          ProducerCard(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: sales.asMap().entries.map((entry) {
                final index = entry.key;
                final sale = entry.value;
                final isLast = index == sales.length - 1;
                return _buildSaleItem(sale, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItem(Map<String, dynamic> sale, bool isLast) {
    final color = sale['color'] as Color;
    
    return Container(
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              )
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ProducerTheme.producerPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.shopping_cart_outlined,
            color: ProducerTheme.producerPrimary,
            size: 20,
          ),
        ),
        title: Text(
          sale['product'] as String,
          style: ProducerTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${sale['quantity']} • ${sale['buyer']}',
          style: ProducerTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              sale['amount'] as String,
              style: ProducerTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: ProducerTheme.producerPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                sale['status'] as String,
                style: ProducerTheme.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed('/producer/add-product'),
      backgroundColor: ProducerTheme.producerPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Nouveau produit'),
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
          child: Column(
            children: [
              // En-tête du drawer
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: ProducerTheme.primaryGradient,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: ProducerTheme.producerPrimary,
                          size: 32,
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
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const ProducerTag(
                        label: 'Producteur certifié',
                        icon: Icons.verified,
                        color: Colors.white,
                        filled: true,
                      ),
                    ],
                  ),
                ),
              ),
              // Menu
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Tableau de bord',
                      onTap: () {
                        Navigator.pop(context);
                      },
                      selected: true,
                    ),
                    _buildDrawerItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Mes produits',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/products');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.sell_outlined,
                      label: 'Mes ventes',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/sales');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.message_outlined,
                      label: 'Messages',
                      badge: '3',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/messages');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_outlined,
                      label: 'Analyses',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/analytics');
                      },
                    ),
                    const Divider(height: 20),
                    _buildDrawerItem(
                      icon: Icons.verified_outlined,
                      label: 'Certification',
                      color: Colors.grey[800],
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/certification');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Paramètres',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/settings');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help_outline,
                      label: 'Centre d\'aide',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/help');
                      },
                    ),
                  ],
                ),
              ),
              // Déconnexion
              Container(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await AuthService().logout();
                    Get.offAllNamed('/login');
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Déconnexion'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ProducerTheme.producerError,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    String? badge,
    VoidCallback? onTap,
    bool selected = false,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? (selected ? ProducerTheme.producerPrimary : Colors.grey[700]),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? ProducerTheme.producerPrimary : Colors.grey[700],
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ProducerTheme.producerInfo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      selected: selected,
      onTap: onTap,
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
}