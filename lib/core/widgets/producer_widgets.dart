// lib/features/producer/core/widgets/producer_widgets.dart
import 'package:flutter/material.dart';
import 'package:jokko_agro/core/themes/producer_theme.dart';

class ProducerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool elevated;

  const ProducerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: ProducerTheme.cardBorderRadius,
          boxShadow: elevated ? ProducerTheme.cardShadow : null,
          border: !elevated ? Border.all(color: Colors.grey.shade200) : null,
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

class ProducerSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry margin;

  const ProducerSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ProducerTheme.headlineSmall,
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: ProducerTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class ProducerStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color? iconColor;

  const ProducerStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = ProducerTheme.producerPrimary,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ProducerCard(
      elevated: true,
      child: SizedBox(
        height: 100, // Hauteur fixe
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, // Plus petit
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? color,
                    size: 20, // Plus petit
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18, // Plus petit
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style:
                  ProducerTheme.bodySmall.copyWith(fontSize: 11), // Plus petit
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class ProducerActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool fullWidth;

  const ProducerActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ProducerTheme.buttonBorderRadius,
        boxShadow: ProducerTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: ProducerTheme.buttonBorderRadius,
          child: SizedBox(
            height: 90, // Hauteur fixe pour éviter l'overflow
            child: Padding(
              padding: const EdgeInsets.all(12), // Padding réduit
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40, // Taille réduite
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.9),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 22, // Taille réduite
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: ProducerTheme.bodySmall.copyWith(
                      // Plus petit
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2, // Limiter à 2 lignes
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class ProducerTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;

  const ProducerTag({
    super.key,
    required this.label,
    this.icon,
    this.color = ProducerTheme.producerPrimary,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: !filled ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                icon,
                size: 14,
                color: filled ? Colors.white : color,
              ),
            ),
          Text(
            label,
            style: ProducerTheme.caption.copyWith(
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
