// lib/features/producer/presentation/screens/producer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/auth_service.dart';
import 'package:jokko_agro/core/themes/producer_theme.dart';
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
      title: const Text(
        'Tableau de bord',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: ProducerTheme.producerPrimary,
      foregroundColor: Colors.white,
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
          icon: const Icon(Icons.notifications_outlined, size: 22),
          onPressed: () => Get.toNamed('/producer/notifications'),
        ),
        Positioned(
          right: 10,
          top: 10,
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
          icon: const Icon(Icons.message_outlined, size: 22),
          onPressed: () => Get.toNamed('/producer/messages'),
        ),
        Positioned(
          right: 10,
          top: 10,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: ProducerTheme.bodyLarge.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.offAllNamed('/'),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final userData = snapshot.data ?? {};
        return RefreshIndicator(
          color: ProducerTheme.producerPrimary,
          onRefresh: () async {
            // Recharger les données
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Bannière de bienvenue
                _buildWelcomeBanner(userData),
                const SizedBox(height: 16),

                // Statistiques
                _buildStatsSection(),
                const SizedBox(height: 20),

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
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(Map<String, String?> userData) {
    final fullName = userData['fullName'] ?? 'Producteur';
    final firstName = fullName.split(' ').first;
    final greeting = firstName.isNotEmpty
        ? 'Bonjour, $firstName !'
        : 'Bonjour, Producteur !';

    return Container(
      decoration: BoxDecoration(
        gradient: ProducerTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 28,
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
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Producteur actif',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
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

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const ProducerSectionHeader(
            title: 'Aperçu de l\'activité',
            subtitle: 'Statistiques du mois',
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
                style: ProducerTheme.bodySmall.copyWith(
                  color: ProducerTheme.producerInfo,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: [
              const ProducerActionButton(
                label: 'Ajouter',
                icon: Icons.add,
                color: ProducerTheme.producerPrimary,
                onPressed: _goToAddProduct,
              ),
              const ProducerActionButton(
                label: 'Produits',
                icon: Icons.inventory_2_outlined,
                color: ProducerTheme.producerSecondary,
                onPressed: _goToProducts,
              ),
              const ProducerActionButton(
                label: 'Ventes',
                icon: Icons.sell_outlined,
                color: ProducerTheme.producerSuccess,
                onPressed: _goToSales,
              ),
              const ProducerActionButton(
                label: 'Messages',
                icon: Icons.message_outlined,
                color: ProducerTheme.producerInfo,
                onPressed: _goToMessages,
              ),
              const ProducerActionButton(
                label: 'Analyse',
                icon: Icons.analytics_outlined,
                color: ProducerTheme.producerPrimary,
                onPressed: _goToAnalytics,
              ),
              const ProducerActionButton(
                label: 'Certification',
                icon: Icons.verified_outlined,
                color: ProducerTheme.producerPrimary,
                onPressed: _goToCertification,
              ),
              const ProducerActionButton(
                label: 'Stock',
                icon: Icons.warehouse_outlined,
                color: ProducerTheme.producerWarning,
                onPressed: _goToInventory,
              ),
              ProducerActionButton(
                label: 'Paramètres',
                icon: Icons.settings_outlined,
                color: Colors.grey.shade700,
                onPressed: _goToSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Méthodes de navigation
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
        'rating': '4.8',
        'stock': '25 kg',
      },
      {
        'name': 'Mangues',
        'category': 'Fruits',
        'sales': '28 ventes',
        'price': '800 FCFA/kg',
        'icon': '🍎',
        'rating': '4.5',
        'stock': '15 kg',
      },
      {
        'name': 'Riz local',
        'category': 'Céréales',
        'sales': '35 ventes',
        'price': '1200 FCFA/kg',
        'icon': '🌾',
        'rating': '4.9',
        'stock': '50 kg',
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
                style: ProducerTheme.bodySmall.copyWith(
                  color: ProducerTheme.producerPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(
                    right: index < products.length - 1 ? 12 : 0,
                  ),
                  child: ProducerCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () => Get.toNamed('/producer/products'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: ProducerTheme.producerPrimary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  product['icon']!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name']!,
                                    style: ProducerTheme.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      product['category']!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                              style: const TextStyle(
                                fontSize: 11,
                                color: ProducerTheme.producerSuccess,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.attach_money_outlined,
                              size: 12,
                              color: ProducerTheme.producerWarning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product['price']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: ProducerTheme.producerWarning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product['rating']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.inventory_outlined,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product['stock']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalesSection() {
    final sales = [
      {
        'id': '#001234',
        'product': 'Tomates bio',
        'quantity': '10kg',
        'buyer': 'Bakary N.',
        'amount': '15,000 FCFA',
        'status': 'Livré',
        'statusColor': ProducerTheme.producerSuccess,
        'date': 'Aujourd\'hui',
        'icon': '🥦',
      },
      {
        'id': '#001233',
        'product': 'Mangues',
        'quantity': '5kg',
        'buyer': 'Fatou D.',
        'amount': '4,000 FCFA',
        'status': 'En cours',
        'statusColor': ProducerTheme.producerWarning,
        'date': 'Hier',
        'icon': '🍎',
      },
      {
        'id': '#001232',
        'product': 'Riz local',
        'quantity': '20kg',
        'buyer': 'Moussa S.',
        'amount': '24,000 FCFA',
        'status': 'Livré',
        'statusColor': ProducerTheme.producerSuccess,
        'date': 'Il y a 2 jours',
        'icon': '🌾',
      },
      {
        'id': '#001231',
        'product': 'Oignons',
        'quantity': '8kg',
        'buyer': 'Aminata K.',
        'amount': '6,400 FCFA',
        'status': 'Annulé',
        'statusColor': Colors.red,
        'date': 'Il y a 3 jours',
        'icon': '🧅',
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
                'Voir tout',
                style: ProducerTheme.bodySmall.copyWith(
                  color: ProducerTheme.producerPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ProducerCard(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: sales.asMap().entries.map((entry) {
                final index = entry.key;
                final sale = entry.value;
                final isLast = index == sales.length - 1;
                return _buildSaleItem(sale as Map<String, dynamic>, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItem(Map<String, dynamic> sale, bool isLast) {
    final statusColor = sale['statusColor'] as Color;

    return Container(
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              )
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ProducerTheme.producerPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              sale['icon'] as String,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        title: Text(
          sale['product'] as String,
          style: ProducerTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${sale['quantity']} • ${sale['buyer']}',
              style: ProducerTheme.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sale['date'] as String,
              style: ProducerTheme.caption.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sale['amount'] as String,
                style: ProducerTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ProducerTheme.producerPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  sale['status'] as String,
                  style: ProducerTheme.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
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
      icon: const Icon(Icons.add, size: 20),
      label: const Text(
        'Nouveau produit',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {};
        final fullName = userData['fullName'] ?? 'Producteur Jokko Agro';
        final email = userData['email'] ?? 'producteur@example.com';
        final role = userData['role'] ?? 'Producteur';

        return Drawer(
          child: Column(
            children: [
              // En-tête du drawer
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: ProducerTheme.primaryGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: ProducerTheme.producerPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                role,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.4),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified,
                                      size: 12, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Vérifié',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      icon: Icons.add_circle_outline,
                      label: 'Ajouter produit',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/add-product');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Mes produits',
                      badge: '12',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/products');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.sell_outlined,
                      label: 'Mes ventes',
                      badge: '5',
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
                      icon: Icons.star_outline,
                      label: 'Réputation',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/reputation');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics_outlined,
                      label: 'Statistiques',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/analytics');
                      },
                    ),
                    const Divider(height: 20, thickness: 1),
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
                    _buildDrawerItem(
                      icon: Icons.info_outline,
                      label: 'À propos',
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed('/producer/about');
                      },
                    ),
                  ],
                ),
              ),
              // Déconnexion
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: color ??
                    (selected
                        ? ProducerTheme.producerPrimary
                        : Colors.grey[700]),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected
                        ? ProducerTheme.producerPrimary
                        : Colors.grey[700],
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ProducerTheme.producerInfo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, String?>> _getUserData() async {
    try {
      final authService = AuthService();
      final fullName = await authService.getUserFullName() ?? 'Producteur';
      final email = await authService.getUserEmail() ?? 'non défini';
      final role = await authService.getUserRole() ?? 'Producteur';

      return {
        'fullName': fullName,
        'email': email,
        'role': role,
      };
    } catch (e) {
      return {
        'fullName': 'Producteur',
        'email': 'non défini',
        'role': 'Producteur',
      };
    }
  }
}
