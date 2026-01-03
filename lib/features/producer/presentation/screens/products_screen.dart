// lib/features/producer/presentation/screens/products_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/shared/models/product_model.dart';
import 'package:jokko_agro/features/producer/presentation/controllers/products_controller.dart';

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
      appBar: AppBar(
        title: const Text('Mes produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/producer/add-product'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques rapides
          _buildStatsSection(),
          const SizedBox(height: 20),

          // Barre de filtres
          _buildFiltersSection(),
          const SizedBox(height: 20),

          // En-tête de la section
          _buildSectionHeader(),
          const SizedBox(height: 16),

          // Liste des produits
          _buildProductsList(),

          // Conseils
          const SizedBox(height: 30),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: '📦',
            value: controller.totalProductsCount.toString(),
            label: 'Produits au total',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: '✅',
            value: controller.availableProductsCount.toString(),
            label: 'Disponibles',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: '💰',
            value: '${controller.totalValueSum.toInt()} FCFA',
            label: 'Valeur totale',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              isDense: true, // AJOUTEZ CECI
            ),
            onChanged: (value) {
              controller.searchQuery.value = value;
              controller.applyFilters();
            },
          ),
          const SizedBox(height: 16),

          // Filtres - version responsive
          LayoutBuilder(
            builder: (context, constraints) {
              // Sur mobile, afficher en colonne
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildCategoryDropdown(),
                    const SizedBox(height: 12),
                    _buildStatusDropdown(),
                    const SizedBox(height: 12),
                    _buildSortDropdown(),
                  ],
                );
              }
              // Sur tablette/desktop, afficher en ligne
              return Row(
                children: [
                  Expanded(child: _buildCategoryDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSortDropdown()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

// Méthodes séparées pour chaque dropdown
  Widget _buildCategoryDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Catégorie',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          value: controller.selectedCategory.value,
          items: controller.categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id'],
              child: Text(
                '${category['icon']} ${category['name']}',
                overflow: TextOverflow.ellipsis, // AJOUTEZ CECI
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedCategory.value = value;
              controller.applyFilters();
            }
          },
          isExpanded: true, // TRÈS IMPORTANT: permet au dropdown de s'adapter
        ));
  }

  Widget _buildStatusDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Statut',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          value: controller.selectedStatus.value,
          items: controller.statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status['id'],
              child: Text(
                status['name'],
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedStatus.value = value;
              controller.applyFilters();
            }
          },
          isExpanded: true,
        ));
  }

  Widget _buildSortDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Trier par',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          value: controller.sortBy.value,
          items: controller.sortOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['id'],
              child: Text(
                option['name'],
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.sortBy.value = value;
              controller.applyFilters();
            }
          },
          isExpanded: true,
        ));
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Produits (${controller.filteredProducts.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => controller.loadProducts(),
        ),
      ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de catégorie
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      category['icon'] ?? '📦',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusInfo['color']?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: statusInfo['color'] ?? Colors.grey,
                              ),
                            ),
                            child: Text(
                              statusInfo['text'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: statusInfo['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category['name'] ?? product.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            if (product.description != null)
              Text(
                product.description!.length > 100
                    ? '${product.description!.substring(0, 100)}...'
                    : product.description!,
                style: const TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 12),

            // Détails
            _buildProductDetails(product, totalValue),
            const SizedBox(height: 12),

            // Stats
            _buildProductStats(product),
            const SizedBox(height: 12),

            // Tags
            _buildProductTags(product),
            const SizedBox(height: 16),

            // Actions
            _buildProductActions(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product, double totalValue) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prix unitaire',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${product.price.toInt()} FCFA/${product.unit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quantité',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${product.quantity} ${product.unit}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Valeur totale: ',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${totalValue.toInt()} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductStats(Product product) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Icon(Icons.sell, size: 20, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              '${product.sales}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'ventes',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        Column(
          children: [
            const Icon(Icons.star, size: 20, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'note',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        Column(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              controller.formatDate(product.updatedAt),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'modifié',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductTags(Product product) {
    final tags = <Widget>[];

    if (product.isOrganic) {
      tags.add(_buildTag('🌱 Bio', AppColors.success));
    }

    if (product.certifications != null) {
      for (var cert in product.certifications!) {
        String text = '';
        switch (cert) {
          case 'local':
            text = '📍 Local';
            break;
          case 'fairtrade':
            text = '⚖️ Équitable';
            break;
          case 'seasonal':
            text = '🌞 Saison';
            break;
          default:
            text = cert;
        }
        tags.add(_buildTag(text, AppColors.secondary));
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags,
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductActions(Product product) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.editProduct(product.id),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Modifier'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.viewProduct(product.id),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Voir'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'duplicate':
                controller.duplicateProduct(product.id);
                break;
              case 'toggle_status':
                controller.toggleProductStatus(product);
                break;
              case 'delete':
                controller.deleteProduct(product.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 18),
                  SizedBox(width: 8),
                  Text('Dupliquer'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    product.status == 'available'
                        ? Icons.pause
                        : Icons.check_circle,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(product.status == 'available'
                      ? 'Marquer épuisé'
                      : 'Réactiver'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Supprimer'),
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
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('📦', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.products.isEmpty
                ? 'Vous n\'avez pas encore ajouté de produits.'
                : 'Aucun produit ne correspond à vos critères de recherche.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Get.toNamed('/producer/add-product'),
            child: const Text('➕ Ajouter votre premier produit'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Conseils de gestion',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipItem(
                  '• Mettez à jour régulièrement les quantités en stock'),
              _buildTipItem(
                  '• Utilisez des descriptions détaillées pour vos produits'),
              _buildTipItem(
                  '• Activez les certifications pour augmenter la confiance'),
              _buildTipItem(
                  '• Surveillez les ventes pour réapprovisionner à temps'),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}
