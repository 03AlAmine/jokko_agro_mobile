// lib/core/middleware/auth_middleware.dart - VERSION SIMPLIFIÉE
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  final AuthService authService = Get.find<AuthService>();
  
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    try {
      final isAuthenticated = await authService.isLoggedIn;
      final currentRoute = route.currentPage?.name ?? '';
      
      // Routes publiques
      final publicRoutes = ['/login', '/register', '/', '/forgot-password'];
      
      if (!isAuthenticated) {
        // Rediriger les non-authentifiés vers login
        if (!publicRoutes.contains(currentRoute)) {
          return GetNavConfig.fromRoute('/login');
        }
      } else {
        // Rediriger les authentifiés depuis les routes publiques
        if (publicRoutes.contains(currentRoute)) {
          final role = await authService.getUserRole();
          
          if (role == 'producer') {
            return GetNavConfig.fromRoute('/producer/dashboard');
          } else if (role == 'buyer') {
            return GetNavConfig.fromRoute('/buyer/dashboard');
          }
          return GetNavConfig.fromRoute('/role-selection');
        }
      }
      
      return null;
    } catch (e) {
      return GetNavConfig.fromRoute('/');
    }
  }
}