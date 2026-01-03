// lib/features/producer/presentation/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/features/producer/presentation/controllers/add_product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final AddProductController controller = Get.put(AddProductController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nom du produit
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nom du produit *',
                hintText: 'Ex: Tomates bio fraîches',
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Catégorie *',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedCategory.value.isEmpty ? null : controller.selectedCategory.value,
              items: controller.categories.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['id'] as String,
                  child: Text('${category['icon']} ${category['name']}'),
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
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Décrivez votre produit avec précision...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
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
            const SizedBox(height: 16),

            // Prix et Quantité
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Prix (FCFA) *',
                      border: OutlineInputBorder(),
                      prefixText: 'FCFA ',
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
                    decoration: const InputDecoration(
                      labelText: 'Quantité *',
                      border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Unité *',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 24),

            // Section Images (facultative)
            _buildImageSection(),
            const SizedBox(height: 24),

            // Certifications
            _buildCertificationsSection(),
            const SizedBox(height: 24),

            // Détails supplémentaires
            _buildAdditionalDetailsSection(),
            const SizedBox(height: 32),

            // Bouton de soumission
            Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => _submitForm(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'PUBLIER LE PRODUIT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
            }),

            // Bouton brouillon
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => controller.saveAsDraft(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Sauvegarder comme brouillon',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos du produit (facultatif)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ajoutez des photos de qualité pour votre produit',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Image principale
        Obx(() {
          final hasMainImage = controller.mainImage.value != null;
          return GestureDetector(
            onTap: () => controller.pickMainImage(),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade50,
              ),
              child: hasMainImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () => controller.removeMainImage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Photo principale (facultative)'),
                        Text('Cliquez pour ajouter', style: TextStyle(fontSize: 12)),
                      ],
                    ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // Images additionnelles
        Obx(() {
          final images = controller.additionalImages;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () => controller.pickAdditionalImages(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 30, color: Colors.grey),
                        Text('Ajouter', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }
              final imageIndex = index - 1;
              if (imageIndex < images.length) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.file(
                        images[imageIndex],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.removeAdditionalImage(imageIndex),
                          child: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        }),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certifications (facultatif)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sélectionnez les certifications de votre produit',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Liste des certifications
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.certifications.map((cert) {
              final certId = cert['id'] as String;
              final isSelected = controller.selectedCertifications.contains(certId);
              return FilterChip(
                label: Text('${cert['icon']} ${cert['name']}'),
                selected: isSelected,
                onSelected: (selected) {
                  controller.toggleCertification(certId);
                },
                selectedColor: AppColors.secondary.withOpacity(0.2),
                checkmarkColor: AppColors.secondary,
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          );
        }),

        // Option Bio
        const SizedBox(height: 16),
        Obx(() {
          return SwitchListTile(
            title: const Text('Produit biologique 🌱'),
            subtitle: const Text('Certification biologique (facultatif)'),
            value: controller.isOrganic.value,
            onChanged: (value) => controller.isOrganic.value = value,
          );
        }),
      ],
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails supplémentaires (facultatif)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Informations complémentaires pour les acheteurs',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Date de récolte
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Date de récolte',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
          ),
          controller: controller.harvestDateController,
          readOnly: true,
          onTap: () => controller.pickHarvestDate(context),
        ),
        const SizedBox(height: 16),

        // Date d'expiration
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Date d\'expiration',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
          ),
          controller: controller.expirationDateController,
          readOnly: true,
          onTap: () => controller.pickExpirationDate(context),
        ),
        const SizedBox(height: 16),

        // Conditions de conservation
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Conditions de conservation',
            hintText: 'Ex: Conserver au frais entre 2°C et 8°C',
            border: OutlineInputBorder(),
          ),
          controller: controller.storageConditionsController,
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Lieu de production
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Lieu de production',
            hintText: 'Ex: Région de Thiès, Sénégal',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          controller: controller.locationController,
        ),
        const SizedBox(height: 16),

        // Téléphone de contact
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Contact téléphonique',
            hintText: '77 123 45 67',
            border: OutlineInputBorder(),
            prefixText: '+221 ',
          ),
          controller: controller.contactPhoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.submitProduct();
      if (success) {
        Get.snackbar(
          'Succès',
          'Produit publié avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Attendre un peu avant de retourner
        await Future.delayed(const Duration(seconds: 2));
        Get.offNamed('/producer/dashboard');
      }
    } else {
      Get.snackbar(
        'Erreur',
        'Veuillez corriger les erreurs dans le formulaire',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}