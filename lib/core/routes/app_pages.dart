// lib/core/routes/app_pages.dart - VERSION FINALE
import 'package:get/get.dart';
import 'package:jokko_agro/features/auth/presentation/screens/login_screen.dart';
import 'package:jokko_agro/features/auth/presentation/screens/register_screen.dart';
import 'package:jokko_agro/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/buyer_dashboard.dart';
import 'package:jokko_agro/features/producer/presentation/screens/producer_dashboard.dart';
import 'package:jokko_agro/features/producer/presentation/screens/add_product_screen.dart';
import 'package:jokko_agro/features/producer/presentation/screens/products_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/market_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/cart_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/checkout_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/order_confirmation_screen.dart';
import 'package:jokko_agro/shared/models/order_model.dart';

/*/ You'll need to create these screens or use placeholders
import 'package:jokko_agro/features/buyer/presentation/screens/qr_scan_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/order_tracking_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/messages_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/settings_screen.dart';
import 'package:jokko_agro/features/buyer/presentation/screens/help_screen.dart';
*/
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
    GetPage(
      name: '/producer/add-product',
      page: () => const AddProductScreen(),
    ),
    GetPage(
      name: '/producer/products',
      page: () => const ProductsScreen(),
    ),
    GetPage(
      name: '/buyer/market',
      page: () => const MarketScreen(),
    ),
    GetPage(
      name: '/buyer/cart',
      page: () => const CartScreen(),
    ),
    GetPage(
      name: '/buyer/checkout',
      page: () => const CheckoutScreen(),
    ),
    GetPage(
      name: '/buyer/order-confirmation',
      page: () => OrderConfirmationScreen(order: Get.arguments as Order),
    ),
    /*/ Add these missing routes:
    GetPage(
      name: '/buyer/scan',
      page: () => QrScanScreen(), // Create this screen
    ),
    GetPage(
      name: '/buyer/tracking',
      page: () => OrderTrackingScreen(), // Create this screen
    ),
    GetPage(
      name: '/buyer/messages',
      page: () => MessagesScreen(), // Create this screen
    ),
    GetPage(
      name: '/buyer/settings',
      page: () => SettingsScreen(), // Create this screen
    ),
    GetPage(
      name: '/buyer/help',
      page: () => HelpScreen(), // Create this screen
    ),*/
  ];
}