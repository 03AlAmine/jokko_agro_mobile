// lib/shared/widgets/filter_chip.dart
import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final bool showCheckmark;

  const FilterChip({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    required this.onSelected,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.selectedTextColor,
    this.elevation,
    this.padding,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation ?? 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (selectedColor ?? Theme.of(context).primaryColor.withOpacity(0.1))
                : (backgroundColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? (selectedColor ?? Theme.of(context).primaryColor)
                  : Colors.grey[300]!,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? (selectedTextColor ?? Theme.of(context).primaryColor)
                      : (textColor ?? Colors.grey[700]),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? (selectedTextColor ?? Theme.of(context).primaryColor)
                      : (textColor ?? Colors.grey[700]),
                ),
              ),
              if (selected && showCheckmark) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check,
                  size: 16,
                  color: selectedTextColor ?? Theme.of(context).primaryColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Variantes spécialisées
class CategoryFilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onSelected;
  final int count;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onSelected,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: selected ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200]!,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (count > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BadgeFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  const BadgeFilterChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : color.withOpacity(0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? Colors.white : color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}