// lib/features/buyer/presentation/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/core/services/cart_service.dart';
import 'package:jokko_agro/features/buyer/presentation/controllers/market_controller.dart';
import 'package:jokko_agro/shared/models/market_model.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketController controller = Get.put(MarketController());
  final _searchController = TextEditingController();
  final CartService cartService =
      Get.find<CartService>(); // Ajoutez cette ligne

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      controller.searchQuery.value = _searchController.text;
      controller.applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marché Agricole'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(),
          ),
          Obx(() => IconButton(
                icon: Icon(
                  controller.viewMode.value == 'grid'
                      ? Icons.grid_view
                      : Icons.list,
                ),
                onPressed: () {
                  controller.viewMode.value =
                      controller.viewMode.value == 'grid' ? 'list' : 'grid';
                },
              )),
          Obx(() => Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Get.toNamed('/buyer/cart'),
                  ),
                  if (cartService.itemCount > 0) // Sans .value
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartService.itemCount > 99
                              ? '99+'
                              : cartService.itemCount.toString(), // Sans .value
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoading();
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des produits...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Barre de recherche
        _buildSearchBar(),

        // Statistiques rapides
        _buildQuickStats(),

        // Filtres actifs
        Obx(() => _buildActiveFilters()),

        // Liste/Grid des produits
        Expanded(
          child: _buildProductsView(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un produit, producteur...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchQuery.value = '';
                    controller.applyFilters();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: _buildStatItem(
            icon: Icons.inventory,
            value: controller.totalProducts.toString(),
            label: 'Produits',
            color: AppColors.primary,
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatItem(
            icon: Icons.verified,
            value: controller.certifiedProductsCount.toString(),
            label: 'Certifiés',
            color: Colors.green,
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatItem(
            icon: Icons.agriculture,
            value: controller.uniqueProducersCount.toString(),
            label: 'Producteurs',
            color: Colors.orange,
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _buildStatItem(
            icon: Icons.star,
            value: controller.averageProductRating.toStringAsFixed(1),
            label: 'Note moy.',
            color: Colors.amber,
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final hasActiveFilters = controller.selectedCategory.value != 'all' ||
        controller.selectedCertification.value != 'all' ||
        controller.selectedSort.value != 'distance' ||
        controller.priceRange.value[0] > 0 ||
        controller.priceRange.value[1] < 100000 ||
        controller.maxDistance.value < 50;

    if (!hasActiveFilters) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActiveFilterChip(
              label:
                  controller.getCategoryName(controller.selectedCategory.value),
              onDelete: () {
                controller.selectedCategory.value = 'all';
                controller.applyFilters();
              },
            ),
            if (controller.selectedCertification.value != 'all') ...[
              const SizedBox(width: 8),
              _buildActiveFilterChip(
                label: _getCertificationName(
                    controller.selectedCertification.value),
                onDelete: () {
                  controller.selectedCertification.value = 'all';
                  controller.applyFilters();
                },
              ),
            ],
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label: '≤ ${controller.maxDistance.value.toInt()} km',
              onDelete: () {
                controller.maxDistance.value = 50.0;
                controller.applyFilters();
              },
            ),
            const SizedBox(width: 8),
            _buildActiveFilterChip(
              label:
                  '${controller.priceRange.value[0].toInt()}-${controller.priceRange.value[1].toInt()} FCFA',
              onDelete: () {
                controller.priceRange.value = [0.0, 100000.0];
                controller.applyFilters();
              },
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: controller.clearFilters,
              child: const Text('Tout effacer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCertificationName(String certId) {
    final cert = controller.certifications.firstWhere(
      (c) => c['id'] == certId,
      orElse: () => {'name': certId},
    );
    return cert['name'] as String;
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDelete,
  }) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDelete,
    );
  }

  Widget _buildProductsView() {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return _buildEmptyState();
      }

      if (controller.viewMode.value == 'grid') {
        return _buildGridView();
      } else {
        return _buildListView();
      }
    });
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return _buildProductListTile(product);
      },
    );
  }

  Widget _buildProductCard(MarketProduct product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => controller.viewProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône de catégorie
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    controller.getCategoryIcon(product.category),
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Nom du produit
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Producteur
              Text(
                product.producerName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Prix et distance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${product.price.toInt()} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Note et stock
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${product.rating.toStringAsFixed(1)} (${product.reviews})',
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 11,
                        color: product.stock < 10 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Badges de certification
              if (product.isOrganic || product.isCertified || product.isLocal)
                _buildCertificationBadges(product),

              const SizedBox(height: 12),

              // Bouton d'ajout
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  onPressed: () {
                    controller.addToCart(product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Ajouter',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListTile(MarketProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              controller.getCategoryIcon(product.category),
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              product.producerName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${product.price.toInt()} FCFA/${product.unit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${product.distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${product.rating.toStringAsFixed(1)} (${product.reviews})',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 8),
                if (product.isOrganic)
                  const Icon(Icons.eco, size: 12, color: Colors.green),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: product.stock > 0
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${product.stock}',
                style: TextStyle(
                  fontSize: 11,
                  color: product.stock > 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 70,
              height: 28,
              child: ElevatedButton(
                onPressed: () => controller.addToCart(product),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Ajouter', style: TextStyle(fontSize: 10)),
              ),
            ),
          ],
        ),
        onTap: () => controller.viewProductDetails(product),
      ),
    );
  }

  Widget _buildCertificationBadges(MarketProduct product) {
    final badges = <Widget>[];

    if (product.isOrganic) {
      badges.add(_buildBadge('Bio', Colors.green));
    }
    if (product.isCertified) {
      badges.add(_buildBadge('Certifié', Colors.blue));
    }
    if (product.isLocal) {
      badges.add(_buildBadge('Local', Colors.orange));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: badges,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aucun produit trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez de modifier vos filtres ou de rechercher autre chose',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.clearFilters,
              child: const Text('Effacer tous les filtres'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtres avancés',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Catégorie
              const Text('Catégorie',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.categories.map((category) {
                      final categoryId = category['id'] as String;
                      final categoryName = category['name'] as String;
                      final categoryIcon = category['icon'] as IconData;

                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryIcon, size: 16),
                            const SizedBox(width: 4),
                            Text(categoryName),
                          ],
                        ),
                        selected:
                            controller.selectedCategory.value == categoryId,
                        onSelected: (selected) {
                          controller.selectedCategory.value = categoryId;
                        },
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 20),

              // Certification
              const Text('Certification',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.certifications.map((cert) {
                      final certId = cert['id'] as String;
                      final certName = cert['name'] as String;

                      return FilterChip(
                        label: Text(certName),
                        selected:
                            controller.selectedCertification.value == certId,
                        onSelected: (selected) {
                          controller.selectedCertification.value = certId;
                        },
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 20),

              // Distance maximale
              const Text('Distance maximale (km)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => Column(
                    children: [
                      Slider(
                        value: controller.maxDistance.value,
                        min: 1,
                        max: 100,
                        divisions: 10,
                        label: '${controller.maxDistance.value.toInt()} km',
                        onChanged: (value) {
                          controller.maxDistance.value = value;
                        },
                      ),
                      Text(
                          'Jusqu\'à ${controller.maxDistance.value.toInt()} km'),
                    ],
                  )),

              const SizedBox(height: 20),

              // Plage de prix
              const Text('Plage de prix (FCFA)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => RangeSlider(
                    values: RangeValues(
                      controller.priceRange.value[0],
                      controller.priceRange.value[1],
                    ),
                    min: 0,
                    max: 100000,
                    divisions: 10,
                    labels: RangeLabels(
                      '${controller.priceRange.value[0].toInt()}',
                      '${controller.priceRange.value[1].toInt()}',
                    ),
                    onChanged: (values) {
                      controller.priceRange.value = [values.start, values.end];
                    },
                  )),

              const SizedBox(height: 20),

              // Options de tri
              const Text('Trier par',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Obx(() => Column(
                    children: controller.sortOptions.map((option) {
                      final optionId = option['id'] as String;
                      final optionName = option['name'] as String;

                      return RadioListTile<String>(
                        title: Text(optionName),
                        value: optionId,
                        groupValue: controller.selectedSort.value,
                        onChanged: (value) {
                          controller.selectedSort.value = value!;
                        },
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 30),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Get.back();
                      },
                      child: const Text('Tout effacer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Get.back();
                      },
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
