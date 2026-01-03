// lib/features/auth/presentation/screens/register_screen.dart - MODIFIÉ
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/constants/colors.dart';
import 'package:jokko_agro/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  String _selectedRole = 'buyer';
  String _selectedLocation = ''; // Ajout pour la localisation
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Liste des régions du Sénégal
  final List<String> _locations = [
    'Sélectionnez votre région',
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Kaolack',
    'Ziguinchor',
    'Diourbel',
    'Louga',
    'Tambacounda',
    'Kolda',
    'Matam',
    'Kédougou',
    'Sédhiou',
    'Autre région'
  ];

  Future<void> _redirectBasedOnRole() async {
    final role = await _authService.getUserRole();
    if (role == 'producer') {
      Get.offAllNamed('/producer/dashboard');
    } else if (role == 'buyer') {
      Get.offAllNamed('/buyer/dashboard');
    } else {
      Get.offAllNamed('/role-selection');
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Validation de la localisation
      if (_selectedLocation.isEmpty || _selectedLocation == 'Sélectionnez votre région') {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner votre localisation',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar(
          'Erreur',
          'Les mots de passe ne correspondent pas',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        // Créer un objet utilisateur avec la localisation
        await _authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          fullName: _fullNameController.text.trim(),
          role: _selectedRole,
          location: _selectedLocation, // Ajout de la localisation
        );
        
        await _redirectBasedOnRole();
        
      } catch (e) {
        Get.snackbar(
          'Erreur',
          e.toString(),
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Créer un compte',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoignez la communauté Jokko Agro',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              
              // Nom complet
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom complet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Téléphone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone *',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                  hintText: '77 123 45 67',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre numéro de téléphone';
                  }
                  final cleanPhone = value.replaceAll(RegExp(r'\s+'), '');
                  if (!RegExp(r'^(77|78|70|76)[0-9]{7}$').hasMatch(cleanPhone)) {
                    return 'Numéro invalide (format: 77 123 45 67)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value)) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Localisation
              DropdownButtonFormField<String>(
                value: _selectedLocation.isNotEmpty 
                    ? _selectedLocation 
                    : 'Sélectionnez votre région',
                decoration: const InputDecoration(
                  labelText: 'Localisation *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && value != 'Sélectionnez votre région') {
                    setState(() {
                      _selectedLocation = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || 
                      value.isEmpty || 
                      value == 'Sélectionnez votre région') {
                    return 'Veuillez sélectionner votre localisation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Sélection du rôle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Je suis : *',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'buyer',
                        label: Text('Acheteur 🛒'),
                      ),
                      ButtonSegment<String>(
                        value: 'producer',
                        label: Text('Producteur 👨‍🌾'),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedRole = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                  hintText: '••••••••',
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Confirmation mot de passe
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                  hintText: '••••••••',
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // Bouton d'inscription
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Créer mon compte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Lien de connexion
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vous avez déjà un compte ? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed('/login'),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}