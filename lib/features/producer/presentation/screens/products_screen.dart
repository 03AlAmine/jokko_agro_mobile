// lib/features/producer/presentation/screens/products_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/shared/models/product_model.dart';
import 'package:jokko_agro/features/producer/presentation/controllers/products_controller.dart';
import 'package:jokko_agro/core/themes/producer_theme.dart';
import 'package:jokko_agro/core/widgets/producer_widgets.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductsController controller = Get.put(ProductsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Mes produits'),
      centerTitle: true,
      backgroundColor: ProducerTheme.producerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_outlined),
          onPressed: _showFilterDialog,
          tooltip: 'Filtres',
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Get.toNamed('/producer/add-product'),
          tooltip: 'Ajouter un produit',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: ProducerTheme.producerPrimary,
          ),
        );
      }

      return RefreshIndicator(
        color: ProducerTheme.producerPrimary,
        onRefresh: () => controller.loadProducts(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques rapides
              _buildStatsSection(),
              const SizedBox(height: 20),

              // Barre de recherche et filtres
              _buildSearchAndFiltersSection(),
              const SizedBox(height: 20),

              // En-tête de la section produits
              _buildSectionHeader(),
              const SizedBox(height: 16),

              // Liste des produits
              _buildProductsList(),

              // Conseils et astuces
              if (controller.filteredProducts.isNotEmpty) _buildTipsSection(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatsSection() {
    return SizedBox(
      height: 120, // Hauteur fixe
      child: Row(
        children: [
          Expanded(
            child: ProducerStatCard(
              value: controller.totalProductsCount.toString(),
              label: 'Produits total',
              icon: Icons.inventory_2_outlined,
              color: ProducerTheme.producerPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ProducerStatCard(
              value: controller.availableProductsCount.toString(),
              label: 'Disponibles',
              icon: Icons.check_circle_outline,
              color: ProducerTheme.producerSuccess,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ProducerStatCard(
              value: '${controller.totalValueSum.toInt()}',
              label: 'Valeur totale',
              icon: Icons.attach_money_outlined,
              color: ProducerTheme.producerWarning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFiltersSection() {
    return ProducerCard(
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search_outlined),
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide:
                    const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              controller.searchQuery.value = value;
              controller.applyFilters();
            },
          ),
          const SizedBox(height: 16),

          // Filtres rapides
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Filtre par catégorie
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.category_outlined, size: 16),
                const SizedBox(width: 4),
                Text(controller.selectedCategory.value != 'all'
                    ? controller.categories.firstWhere((c) =>
                        c['id'] ==
                        controller.selectedCategory.value)['name'] as String
                    : 'Catégorie'),
              ],
            ),
            selected: controller.selectedCategory.value != 'all',
            onSelected: (_) => _showCategoryFilter(),
            backgroundColor: Colors.grey.shade100,
            selectedColor: ProducerTheme.producerPrimary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: controller.selectedCategory.value != 'all'
                  ? ProducerTheme.producerPrimary
                  : Colors.grey[700],
              fontWeight: controller.selectedCategory.value != 'all'
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Filtre par statut
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle_outlined, size: 16),
                const SizedBox(width: 4),
                Text(controller.selectedStatus.value != 'all'
                    ? controller.statuses.firstWhere((s) =>
                            s['id'] == controller.selectedStatus.value)['name']
                        as String
                    : 'Statut'),
              ],
            ),
            selected: controller.selectedStatus.value != 'all',
            onSelected: (_) => _showStatusFilter(),
            backgroundColor: Colors.grey.shade100,
            selectedColor: ProducerTheme.producerSecondary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: controller.selectedStatus.value != 'all'
                  ? ProducerTheme.producerSecondary
                  : Colors.grey[700],
              fontWeight: controller.selectedStatus.value != 'all'
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Filtre par tri
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_outlined, size: 16),
                const SizedBox(width: 4),
                Text(controller.sortOptions.firstWhere(
                        (s) => s['id'] == controller.sortBy.value)['name']
                    as String),
              ],
            ),
            selected: controller.sortBy.value != 'recent',
            onSelected: (_) => _showSortFilter(),
            backgroundColor: Colors.grey.shade100,
            selectedColor: ProducerTheme.producerInfo.withOpacity(0.2),
            labelStyle: TextStyle(
              color: controller.sortBy.value != 'recent'
                  ? ProducerTheme.producerInfo
                  : Colors.grey[700],
              fontWeight: controller.sortBy.value != 'recent'
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Bouton réinitialiser
          if (controller.selectedCategory.value != 'all' ||
              controller.selectedStatus.value != 'all' ||
              controller.sortBy.value != 'recent' ||
              controller.searchQuery.value.isNotEmpty)
            ActionChip(
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 16),
                  SizedBox(width: 4),
                  Text('Réinitialiser'),
                ],
              ),
              onPressed: () {
                controller.selectedCategory.value = 'all';
                controller.selectedStatus.value = 'all';
                controller.sortBy.value = 'recent';
                controller.searchQuery.value = '';
                controller.applyFilters();
              },
              backgroundColor: Colors.grey.shade100,
              labelStyle: const TextStyle(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSectionHeader() {
    return ProducerSectionHeader(
      title: 'Produits (${controller.filteredProducts.length})',
      subtitle: 'Liste de tous vos produits',
      action: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadProducts(),
            tooltip: 'Actualiser',
            iconSize: 20,
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportProducts,
            tooltip: 'Exporter',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (controller.filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final category = controller.getCategoryInfo(product.category);
    final statusInfo = controller.getStatusInfo(product.status);
    final totalValue = product.price * product.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Espacement réduit
      child: ProducerCard(
        onTap: () => controller.viewProduct(product.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Important
          children: [
            // En-tête
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de catégorie
                Container(
                  width: 40, // Plus petit
                  height: 40,
                  decoration: BoxDecoration(
                    color: ProducerTheme.producerPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      category['icon'] as String? ?? '📦',
                      style: const TextStyle(fontSize: 20), // Plus petit
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: ProducerTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (statusInfo['color'] as Color?)
                                  ?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: statusInfo['color'] as Color? ??
                                    Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              statusInfo['text'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 10, // Plus petit
                                fontWeight: FontWeight.w500,
                                color: statusInfo['color'] as Color?,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      ProducerTag(
                        label: category['name'] as String? ?? product.category,
                        icon: Icons.category_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            if (product.description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  product.description!.length > 80
                      ? '${product.description!.substring(0, 80)}...'
                      : product.description!,
                  style: ProducerTheme.bodySmall.copyWith(
                    fontSize: 11, // Plus petit
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Détails prix et quantité
            _buildProductDetails(product, totalValue),
            const SizedBox(height: 8),

            // Statistiques
            _buildProductStats(product),

            // Tags
            if (product.isOrganic ||
                (product.certifications?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildProductTags(product),
              ),

            // Actions
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildProductActions(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product, double totalValue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Prix unitaire',
                    style: ProducerTheme.caption.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${product.price.toInt()} FCFA/${product.unit}',
                    style: ProducerTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quantité stock',
                    style: ProducerTheme.caption.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${product.quantity} ${product.unit}',
                    style: ProducerTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 12,
              color: Colors.grey,
            ),
            const SizedBox(width: 2),
            Text(
              'Valeur totale: ',
              style: ProducerTheme.caption.copyWith(fontSize: 10),
            ),
            Flexible(
              child: Text(
                '${totalValue.toInt()} FCFA',
                style: ProducerTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ProducerTheme.producerPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductStats(Product product) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.sell_outlined,
            value: '${product.sales}',
            label: 'Ventes',
            color: ProducerTheme.producerSuccess,
            size: 14, // Plus petit
          ),
          _buildStatItem(
            icon: Icons.star_outlined,
            value: product.rating.toStringAsFixed(1),
            label: 'Note',
            color: ProducerTheme.producerWarning,
            size: 14,
          ),
          _buildStatItem(
            icon: Icons.remove_red_eye_outlined,
            value: '${product.views}',
            label: 'Vues',
            color: ProducerTheme.producerInfo,
            size: 14,
          ),
          _buildStatItem(
            icon: Icons.calendar_today_outlined,
            value: _formatDateShort(product.updatedAt),
            label: 'Modifié',
            color: Colors.grey,
            size: 14,
          ),
        ],
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Auj.';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}sem';
    } else {
      return '${date.day}/${date.month}';
    }
  }

// Mettre à jour _buildStatItem :
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    double size = 14,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: size,
          color: color,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProductTags(Product product) {
    final tags = <Widget>[];

    if (product.isOrganic) {
      tags.add(
        const ProducerTag(
          label: 'Bio',
          icon: Icons.eco_outlined,
          color: ProducerTheme.producerSuccess,
          filled: true,
        ),
      );
    }

    if (product.certifications != null) {
      for (var cert in product.certifications!) {
        String text = '';
        IconData iconData;

        switch (cert) {
          case 'local':
            text = 'Local';
            iconData = Icons.location_on_outlined;
            break;
          case 'fairtrade':
            text = 'Équitable';
            iconData = Icons.handshake_outlined;
            break;
          case 'seasonal':
            text = 'Saison';
            iconData = Icons.wb_sunny_outlined;
            break;
          default:
            text = cert;
            iconData = Icons.verified_outlined;
        }

        tags.add(
          ProducerTag(
            label: text,
            icon: iconData,
            color: ProducerTheme.producerSecondary,
          ),
        );
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags,
    );
  }

  Widget _buildProductActions(Product product) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.editProduct(product.id),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Modifier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ProducerTheme.producerPrimary,
              side: BorderSide(
                  color: ProducerTheme.producerPrimary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.toggleProductStatus(product),
            icon: Icon(
              product.status == 'available'
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              size: 16,
            ),
            label: Text(
              product.status == 'available' ? 'Pause' : 'Activer',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: product.status == 'available'
                  ? ProducerTheme.producerWarning
                  : ProducerTheme.producerSuccess,
              side: BorderSide(
                color: product.status == 'available'
                    ? ProducerTheme.producerWarning.withOpacity(0.5)
                    : ProducerTheme.producerSuccess.withOpacity(0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_outlined),
          onSelected: (value) {
            switch (value) {
              case 'view':
                controller.viewProduct(product.id);
                break;
              case 'duplicate':
                controller.duplicateProduct(product.id);
                break;
              case 'delete':
                controller.deleteProduct(product.id);
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Voir détails'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Dupliquer'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun produit trouvé',
            style: ProducerTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            controller.products.isEmpty
                ? 'Vous n\'avez pas encore ajouté de produits.\nCommencez par ajouter votre premier produit !'
                : 'Aucun produit ne correspond à vos critères de recherche.',
            textAlign: TextAlign.center,
            style: ProducerTheme.bodyMedium.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/producer/add-product'),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProducerTheme.producerPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return ProducerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: ProducerTheme.producerWarning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseils de gestion',
                style: ProducerTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TipItem(
                '• Mettez à jour régulièrement les quantités en stock',
              ),
              _TipItem(
                '• Utilisez des photos de qualité pour attirer les acheteurs',
              ),
              _TipItem(
                '• Activez les certifications pour augmenter la confiance',
              ),
              _TipItem(
                '• Surveillez les ventes pour réapprovisionner à temps',
              ),
              _TipItem(
                '• Répondez rapidement aux questions des acheteurs',
              ),
            ],
          ),
        ],
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ProducerSectionHeader(
                title: 'Filtres avancés',
                subtitle: 'Affinez votre recherche',
              ),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 16),
              _buildSortDropdown(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.selectedCategory.value = 'all';
                        controller.selectedStatus.value = 'all';
                        controller.sortBy.value = 'recent';
                        controller.searchQuery.value = '';
                        controller.applyFilters();
                        Get.back();
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProducerTheme.producerPrimary,
                      ),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Catégorie',
            border: OutlineInputBorder(
              borderRadius: ProducerTheme.inputBorderRadius,
            ),
            prefixIcon: const Icon(Icons.category_outlined),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          value: controller.selectedCategory.value,
          items:
              controller.categories.map<DropdownMenuItem<String>>((category) {
            return DropdownMenuItem<String>(
              value: category['id'] as String,
              child: Row(
                children: [
                  Text(category['icon'] as String),
                  const SizedBox(width: 12),
                  Text(category['name'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedCategory.value = value;
            }
          },
        ));
  }

  Widget _buildStatusDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Statut',
            border: OutlineInputBorder(
              borderRadius: ProducerTheme.inputBorderRadius,
            ),
            prefixIcon: const Icon(Icons.circle_outlined),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          value: controller.selectedStatus.value,
          items: controller.statuses.map<DropdownMenuItem<String>>((status) {
            return DropdownMenuItem<String>(
              value: status['id'] as String,
              child: Text(status['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedStatus.value = value;
            }
          },
        ));
  }

  Widget _buildSortDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Trier par',
            border: OutlineInputBorder(
              borderRadius: ProducerTheme.inputBorderRadius,
            ),
            prefixIcon: const Icon(Icons.sort_outlined),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          value: controller.sortBy.value,
          items: controller.sortOptions.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option['id'] as String,
              child: Text(option['name'] as String),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.sortBy.value = value;
            }
          },
        ));
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProducerSectionHeader(
                title: 'Catégories',
                subtitle: 'Filtrer par catégorie',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.categories.map((category) {
                  final isSelected =
                      controller.selectedCategory.value == category['id'];
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category['icon'] as String),
                        const SizedBox(width: 6),
                        Text(category['name'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      controller.selectedCategory.value =
                          category['id'] as String;
                      controller.applyFilters();
                      Get.back();
                    },
                    selectedColor:
                        ProducerTheme.producerPrimary.withOpacity(0.2),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? ProducerTheme.producerPrimary
                          : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProducerSectionHeader(
                title: 'Statuts',
                subtitle: 'Filtrer par statut',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.statuses.map((status) {
                  final isSelected =
                      controller.selectedStatus.value == status['id'];
                  return FilterChip(
                    label: Text(status['name'] as String),
                    selected: isSelected,
                    onSelected: (_) {
                      controller.selectedStatus.value = status['id'] as String;
                      controller.applyFilters();
                      Get.back();
                    },
                    selectedColor:
                        ProducerTheme.producerSecondary.withOpacity(0.2),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? ProducerTheme.producerSecondary
                          : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSortFilter() {
    showModalBottomSheet(
      context: Get.context!,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ProducerSectionHeader(
                title: 'Trier par',
                subtitle: 'Sélectionnez un critère de tri',
              ),
              const SizedBox(height: 16),
              Column(
                children: controller.sortOptions.map((option) {
                  final isSelected = controller.sortBy.value == option['id'];
                  return RadioListTile<String>(
                    title: Text(option['name'] as String),
                    value: option['id'] as String,
                    groupValue: controller.sortBy.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.sortBy.value = value;
                        controller.applyFilters();
                        Get.back();
                      }
                    },
                    activeColor: ProducerTheme.producerPrimary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _exportProducts() {
    // Implémenter l'export des produits
    Get.snackbar(
      'Exportation',
      'Exportation des produits en cours...',
      backgroundColor: ProducerTheme.producerInfo,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: ProducerTheme.bodySmall.copyWith(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
