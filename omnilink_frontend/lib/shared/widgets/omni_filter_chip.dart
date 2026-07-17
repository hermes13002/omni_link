import 'package:flutter/material.dart';

class OmniFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? tagColor;

  const OmniFilterChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.icon,
    required this.onTap,
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final activeColor = tagColor ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? activeColor.withAlpha(51) 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive 
                ? activeColor.withAlpha(76) 
                : colorScheme.onSurface.withAlpha(25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              )
            else if (tagColor != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: tagColor!.withAlpha(128),
                  shape: BoxShape.circle,
                ),
              )
            else if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  icon,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
