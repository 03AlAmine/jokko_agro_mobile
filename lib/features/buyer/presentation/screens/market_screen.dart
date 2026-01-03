
// lib/features/buyer/presentation/screens/market_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
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
          IconButton(
            icon: Obx(() => Icon(
              controller.viewMode.value == 'grid' 
                ? Icons.grid_view 
                : Icons.list,
            )),
            onPressed: () {
              controller.viewMode.value = 
                  controller.viewMode.value == 'grid' ? 'list' : 'grid';
            },
          ),
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
        const SizedBox(height: 8),
        
        // Filtres actifs
        _buildActiveFilters(),
        const SizedBox(height: 8),
        
        // Statistiques
        _buildStatsBar(),
        const SizedBox(height: 16),
        
        // Liste/Grid des produits
        Expanded(
          child: _buildProductsView(),
        ),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un produit, producteur...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchQuery.value = '';
                    controller.applyFilters();
                  },
                )
              : null,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  
  Widget _buildActiveFilters() {
    final hasActiveFilters = 
        controller.selectedCategory.value != 'all' ||
        controller.selectedCertification.value != 'all' ||
        controller.selectedSort.value != 'distance' ||
        controller.priceRange.value[0] > 0 ||
        controller.priceRange.value[1] < 100000 ||
        controller.maxDistance.value < 50;
    
    if (!hasActiveFilters) return const SizedBox();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Chip(
            label: Text(
              controller.categories.firstWhere(
                (c) => c['id'] == controller.selectedCategory.value,
                orElse: () => {'name': 'Catégorie'},
              )['name'],
            ),
            onDeleted: () {
              controller.selectedCategory.value = 'all';
              controller.applyFilters();
            },
          ),
          const SizedBox(width: 8),
          if (controller.selectedCertification.value != 'all')
            Chip(
              label: Text(
                controller.certifications.firstWhere(
                  (c) => c['id'] == controller.selectedCertification.value,
                )['name'],
              ),
              onDeleted: () {
                controller.selectedCertification.value = 'all';
                controller.applyFilters();
              },
            ),
          const SizedBox(width: 8),
          Chip(
            label: Text('≤ ${controller.maxDistance.value.toInt()} km'),
            onDeleted: () {
              controller.maxDistance.value = 50.0;
              controller.applyFilters();
            },
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(
              '${controller.priceRange.value[0].toInt()}-${controller.priceRange.value[1].toInt()} FCFA',
            ),
            onDeleted: () {
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
    );
  }
  
  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${controller.filteredProducts.length} produits',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 4),
              Text('${controller.uniqueProducersCount} producteurs'),
              const SizedBox(width: 16),
              const Icon(Icons.verified, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text('${controller.certifiedProductsCount} certifiés'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProductsView() {
    if (controller.filteredProducts.isEmpty) {
      return _buildEmptyState();
    }
    
    return Obx(() {
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
      child: InkWell(
        onTap: () => controller.viewProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec image/emoji et distance
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      product.displayEmoji ?? '📦',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.producerName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text('${product.distance.toStringAsFixed(1)} km'),
                    backgroundColor: Colors.blue[50],
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Prix et unité
              Row(
                children: [
                  Text(
                    '${product.price.toInt()} FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${product.unit}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Stock et catégorie
              Text(
                'Stock: ${product.stock} ${product.unit}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              
              // Note et avis
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${product.reviews})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Badges de certification
              _buildCertificationBadges(product),
              
              const Spacer(),
              
              // Bouton d'action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.addToCart(product),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: AppColors.primary,
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
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            product.displayEmoji ?? '📦',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              product.producerName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${product.price.toInt()} FCFA/${product.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${product.distance.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(product.rating.toStringAsFixed(1)),
                const SizedBox(width: 4),
                Text('(${product.reviews} avis)'),
                const SizedBox(width: 8),
                if (product.isOrganic)
                  const Icon(Icons.eco, size: 14, color: Colors.green),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stock: ${product.stock}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => controller.addToCart(product),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
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
      badges.add(_buildBadge('🌱 Bio', Colors.green));
    }
    if (product.isCertified) {
      badges.add(_buildBadge('✅ Certifié', Colors.blue));
    }
    if (product.isLocal) {
      badges.add(_buildBadge('📍 Local', Colors.orange));
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
          fontSize: 10,
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
              const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: controller.categories.map((category) {
                  return ChoiceChip(
                    label: Text('${category['icon']} ${category['name']}'),
                    selected: controller.selectedCategory.value == category['id'],
                    onSelected: (selected) {
                      controller.selectedCategory.value = category['id'];
                      controller.applyFilters();
                      if (selected) Get.back();
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Certification
              const Text('Certification', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: controller.certifications.map((cert) {
                  return FilterChip(
                    label: Text(cert['name']),
                    selected: controller.selectedCertification.value == cert['id'],
                    onSelected: (selected) {
                      controller.selectedCertification.value = cert['id'];
                      controller.applyFilters();
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Distance maximale
              const Text('Distance maximale (km)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    onChangeEnd: (_) => controller.applyFilters(),
                  ),
                  Text('Jusqu\'à ${controller.maxDistance.value.toInt()} km'),
                ],
              )),
              
              const SizedBox(height: 20),
              
              // Plage de prix
              const Text('Plage de prix (FCFA)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                onChangeEnd: (_) => controller.applyFilters(),
              )),
              
              const SizedBox(height: 20),
              
              // Options de tri
              const Text('Trier par', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: controller.sortOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option['name']),
                    value: option['id'],
                    groupValue: controller.selectedSort.value,
                    onChanged: (value) {
                      controller.selectedSort.value = value!;
                      controller.applyFilters();
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 30),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.clearFilters,
                      child: const Text('Tout effacer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: Get.back,
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

