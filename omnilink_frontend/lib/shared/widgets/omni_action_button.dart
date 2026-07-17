import 'package:flutter/material.dart';

enum OmniActionButtonVariant {
  primary,
  secondary,
  tertiary,
  error,
}

class OmniActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final OmniActionButtonVariant variant;

  const OmniActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = OmniActionButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color fgColor;

    switch (variant) {
      case OmniActionButtonVariant.primary:
        bgColor = colorScheme.primaryContainer;
        fgColor = colorScheme.onPrimaryContainer;
        break;
      case OmniActionButtonVariant.secondary:
        bgColor = colorScheme.secondary;
        fgColor = colorScheme.onSecondary;
        break;
      case OmniActionButtonVariant.tertiary:
        bgColor = colorScheme.tertiaryContainer;
        fgColor = colorScheme.onTertiaryContainer;
        break;
      case OmniActionButtonVariant.error:
        bgColor = colorScheme.errorContainer;
        fgColor = colorScheme.onErrorContainer;
        break;
    }

    return Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: fgColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
