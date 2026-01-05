// lib/features/producer/presentation/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/features/producer/presentation/controllers/add_product_controller.dart';
import 'package:jokko_agro/core/themes/producer_theme.dart';
import 'package:jokko_agro/core/widgets/producer_widgets.dart';


class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final AddProductController controller = Get.put(AddProductController());
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau produit'),
        centerTitle: true,
        backgroundColor: ProducerTheme.producerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () => controller.saveAsDraft(),
            tooltip: 'Sauvegarder comme brouillon',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Barre de progression
            _buildProgressBar(),
            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section informations de base
                    const ProducerSectionHeader(
                      title: 'Informations de base',
                      subtitle: 'Renseignez les informations principales',
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Section prix et quantité
                    const ProducerSectionHeader(
                      title: 'Prix et stock',
                      subtitle: 'Définissez votre tarif et disponibilité',
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    _buildPriceSection(),
                    const SizedBox(height: 24),

                    // Section images
                    const ProducerSectionHeader(
                      title: 'Photos du produit',
                      subtitle: 'Ajoutez des photos attractives',
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Section certifications
                    const ProducerSectionHeader(
                      title: 'Certifications',
                      subtitle: 'Valorisez votre produit',
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    _buildCertificationsSection(),
                    const SizedBox(height: 24),

                    // Section détails supplémentaires
                    const ProducerSectionHeader(
                      title: 'Détails supplémentaires',
                      subtitle: 'Informations complémentaires',
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    _buildAdditionalDetailsSection(),
                    const SizedBox(height: 32),

                    // Boutons d'action
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ProducerTheme.producerPrimary.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey.shade200,
              color: ProducerTheme.producerPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '70%',
            style: ProducerTheme.bodySmall.copyWith(
              color: ProducerTheme.producerPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return ProducerCard(
      child: Column(
        children: [
          // Nom du produit
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nom du produit *',
              hintText: 'Ex: Tomates bio fraîches',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom est requis';
              }
              if (value.length < 3) {
                return 'Minimum 3 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Catégorie
          Obx(() => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Catégorie *',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.category_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            value: controller.selectedCategory.value.isEmpty 
                ? null 
                : controller.selectedCategory.value,
            items: controller.categories.map<DropdownMenuItem<String>>((category) {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Sélectionnez une catégorie';
              }
              return null;
            },
          )),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description *',
              hintText: 'Décrivez votre produit avec précision...',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.descriptionController,
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La description est requise';
              }
              if (value.length < 10) {
                return 'Minimum 10 caractères';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return ProducerCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Prix (FCFA) *',
                    border: OutlineInputBorder(
                      borderRadius: ProducerTheme.inputBorderRadius,
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: ProducerTheme.inputBorderRadius,
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: ProducerTheme.inputBorderRadius,
                      borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
                    ),
                    floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
                    prefixIcon: const Icon(Icons.attach_money_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  controller: controller.priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prix est requis';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 100) {
                      return 'Minimum 100 FCFA';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Quantité *',
                    border: OutlineInputBorder(
                      borderRadius: ProducerTheme.inputBorderRadius,
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: ProducerTheme.inputBorderRadius,
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: ProducerTheme.inputBorderRadius,
                      borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
                    ),
                    floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
                    prefixIcon: const Icon(Icons.scale_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  controller: controller.quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La quantité est requise';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 1) {
                      return 'Minimum 1';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Unité de mesure
          Obx(() => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Unité *',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.straighten_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            value: controller.selectedUnit.value,
            items: controller.units.map<DropdownMenuItem<String>>((unit) {
              return DropdownMenuItem<String>(
                value: unit['id'] as String,
                child: Text('${unit['symbol']} (${unit['name']})'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedUnit.value = value;
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Sélectionnez une unité';
              }
              return null;
            },
          )),
          const SizedBox(height: 16),

          // Quantité minimale
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Quantité minimale de commande',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.shopping_cart_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.minOrderQuantityController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final minQuantity = int.tryParse(value);
                if (minQuantity != null && minQuantity < 1) {
                  return 'Minimum 1';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        ProducerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Image principale',
                style: ProducerTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez une photo de haute qualité de votre produit',
                style: ProducerTheme.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final hasMainImage = controller.mainImage.value != null;
                return GestureDetector(
                  onTap: () => controller.pickMainImage(),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: hasMainImage
                            ? ProducerTheme.producerPrimary
                            : Colors.grey.shade300,
                        width: hasMainImage ? 2 : 1,
                      ),
                      borderRadius: ProducerTheme.inputBorderRadius,
                      color: Colors.grey.shade50,
                    ),
                    child: hasMainImage
                        ? ClipRRect(
                            borderRadius: ProducerTheme.inputBorderRadius,
                            child: Stack(
                              children: [
                                Image.file(
                                  controller.mainImage.value!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: ProducerTheme.cardShadow,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () => controller.removeMainImage(),
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'Cliquez pour ajouter une photo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ProducerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photos additionnelles',
                style: ProducerTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez jusqu\'à 4 photos supplémentaires (optionnel)',
                style: ProducerTheme.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final images = controller.additionalImages;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: images.length < 4 ? images.length + 1 : images.length,
                  itemBuilder: (context, index) {
                    if (index == images.length && images.length < 4) {
                      return GestureDetector(
                        onTap: () => controller.pickAdditionalImages(),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 24, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                'Ajouter',
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (index < images.length) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              images[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeAdditionalImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return ProducerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certifications disponibles',
            style: ProducerTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez les certifications de votre produit',
            style: ProducerTheme.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.certifications.map((cert) {
                final certId = cert['id'] as String;
                final isSelected = controller.selectedCertifications.contains(certId);
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cert['icon'] as String),
                      const SizedBox(width: 6),
                      Text(cert['name'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.toggleCertification(certId);
                  },
                  selectedColor: ProducerTheme.producerPrimary.withOpacity(0.2),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? ProducerTheme.producerPrimary
                        : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Agriculture biologique 🌱',
                style: ProducerTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Produit certifié bio',
                style: ProducerTheme.bodySmall.copyWith(color: Colors.grey[600]),
              ),
              value: controller.isOrganic.value,
              onChanged: (value) => controller.isOrganic.value = value,
              activeColor: ProducerTheme.producerPrimary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return ProducerCard(
      child: Column(
        children: [
          // Date de récolte
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Date de récolte',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.harvestDateController,
            readOnly: true,
            onTap: () => controller.pickHarvestDate(context),
          ),
          const SizedBox(height: 16),

          // Date d'expiration
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Date d\'expiration',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.timer_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.expirationDateController,
            readOnly: true,
            onTap: () => controller.pickExpirationDate(context),
          ),
          const SizedBox(height: 16),

          // Conditions de conservation
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Conditions de conservation',
              hintText: 'Ex: Conserver au frais entre 2°C et 8°C',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.ac_unit_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.storageConditionsController,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Lieu de production
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Lieu de production',
              hintText: 'Ex: Région de Thiès, Sénégal',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.locationController,
          ),
          const SizedBox(height: 16),

          // Contact téléphonique
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Contact téléphonique',
              hintText: '77 123 45 67',
              border: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ProducerTheme.inputBorderRadius,
                borderSide: const BorderSide(color: ProducerTheme.producerPrimary),
              ),
              floatingLabelStyle: const TextStyle(color: ProducerTheme.producerPrimary),
              prefixIcon: const Icon(Icons.phone_outlined),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            controller: controller.contactPhoneController,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton principal
        Obx(() {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : () => _submitForm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ProducerTheme.producerPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: ProducerTheme.buttonBorderRadius,
                ),
                elevation: 2,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 8),
                        Text(
                          'PUBLIER LE PRODUIT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Bouton secondaire
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => controller.saveAsDraft(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: ProducerTheme.buttonBorderRadius,
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Sauvegarder comme brouillon',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.submitProduct();
      if (success) {
        // Animation de succès
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: ProducerTheme.producerSuccess,
              size: 48,
            ),
            title: const Text('Produit publié !'),
            content: const Text(
              'Votre produit a été publié avec succès. Il est maintenant visible par les acheteurs.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.offNamed('/producer/dashboard'),
                child: const Text('Retour au tableau de bord'),
              ),
              ElevatedButton(
                onPressed: () => _formKey.currentState!.reset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProducerTheme.producerPrimary,
                ),
                child: const Text('Ajouter un autre produit'),
              ),
            ],
          ),
        );
      }
    } else {
      // Afficher une alerte d'erreur
      Get.snackbar(
        'Formulaire incomplet',
        'Veuillez corriger les erreurs dans le formulaire',
        backgroundColor: ProducerTheme.producerError,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      
      // Faire défiler jusqu'au premier champ invalide
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _formKey.currentContext;
        if (context != null) {
          final focus = Focus.of(context);
          focus.unfocus();
        }
      });
    }
  }
}