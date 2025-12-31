// lib/core/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:jokko_agro/features/auth/presentation/screens/login_screen.dart';
import 'package:jokko_agro/features/auth/presentation/screens/register_screen.dart';
import 'package:jokko_agro/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/buyer_dashboard.dart';
import 'package:jokko_agro/features/producer/presentation/screens/producer_dashboard.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: '/role-selection',
      page: () => const RoleSelectionScreen(),
    ),
    GetPage(
      name: '/buyer/dashboard',
      page: () => const BuyerDashboard(),
    ),
    GetPage(
      name: '/producer/dashboard',
      page: () => const ProducerDashboard(),
    ),
  ];
}