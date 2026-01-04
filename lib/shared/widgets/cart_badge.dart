// lib/shared/widgets/cart_badge.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jokko_agro/core/services/cart_service.dart';

class CartBadge extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color? badgeColor;
  final Color? textColor;
  
  const CartBadge({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
  });
  
  @override
  Widget build(BuildContext context) {
    return GetX<CartService>(
      builder: (cartService) {
        final itemCount = cartService.itemCount; // Sans .value
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: icon,
              onPressed: onPressed,
            ),
            if (itemCount > 0)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    itemCount > 99 ? '99+' : itemCount.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}