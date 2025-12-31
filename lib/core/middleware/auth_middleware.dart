// lib/core/middleware/auth_middleware.dart
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  final AuthService authService = AuthService();

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final isLoggedIn = await authService.isLoggedIn();
    
    if (!isLoggedIn && route.currentPage!.name != '/login') {
      return GetNavConfig.fromRoute('/login');
    }
    
    if (isLoggedIn && route.currentPage!.name == '/login') {
      final role = await authService.getUserRole();
      if (role == null) {
        return GetNavConfig.fromRoute('/role-selection');
      } else if (role == 'buyer') {
        return GetNavConfig.fromRoute('/buyer/dashboard');
      } else if (role == 'producer') {
        return GetNavConfig.fromRoute('/producer/dashboard');
      }
    }
    
    return await super.redirectDelegate(route);
  }
}

// Guard spécifique pour producteur
class ProducerGuard extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final role = await AuthService().getUserRole();
    if (role != 'producer') {
      return GetNavConfig.fromRoute('/buyer/dashboard');
    }
    return await super.redirectDelegate(route);
  }
}

// Guard spécifique pour acheteur
class BuyerGuard extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final role = await AuthService().getUserRole();
    if (role != 'buyer') {
      return GetNavConfig.fromRoute('/producer/dashboard');
    }
    return await super.redirectDelegate(route);
  }
}