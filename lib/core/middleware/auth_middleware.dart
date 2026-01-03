// lib/core/routes/auth_middleware.dart - CORRIGÉ
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  final AuthService _authService = AuthService();

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    // Vérifier si l'utilisateur est authentifié
    final isAuthenticated = await _authService.isLoggedIn();
    final currentRoute = route.currentPage?.name ?? '';
    
    if (!isAuthenticated) {
      // Si non authentifié, rediriger vers login sauf pour certaines routes
      if (currentRoute != '/login' && currentRoute != '/register' && currentRoute != '/') {
        return GetNavConfig.fromRoute('/login');
      }
    } else {
      // Si authentifié, vérifier le rôle
      final role = await _authService.getUserRole();
      
      // Rediriger les utilisateurs authentifiés qui essaient d'accéder au login/register
      if (currentRoute == '/login' || currentRoute == '/register' || currentRoute == '/') {
        if (role == 'producer') {
          return GetNavConfig.fromRoute('/producer/dashboard');
        } else if (role == 'buyer') {
          return GetNavConfig.fromRoute('/buyer/dashboard');
        } else {
          return GetNavConfig.fromRoute('/role-selection');
        }
      }
    }
    
    return null;
  }
}