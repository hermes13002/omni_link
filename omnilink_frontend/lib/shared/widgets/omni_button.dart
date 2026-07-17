import 'package:flutter/material.dart';

enum OmniButtonVariant {
  primary,
  secondary,
  inverted,
  outlined,
}

class OmniButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OmniButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const OmniButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = OmniButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  });

  const OmniButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = OmniButtonVariant.primary;

  const OmniButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = OmniButtonVariant.secondary;

  const OmniButton.inverted({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = OmniButtonVariant.inverted;

  const OmniButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = OmniButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;

    switch (variant) {
      case OmniButtonVariant.primary:
        backgroundColor = colorScheme.primaryContainer; // ADC6FF
        foregroundColor = colorScheme.onPrimaryContainer;
        break;
      case OmniButtonVariant.secondary:
        backgroundColor = colorScheme.secondary; // D0BCFF
        foregroundColor = colorScheme.onSecondary;
        break;
      case OmniButtonVariant.inverted:
        backgroundColor = colorScheme.onSurface; // Usually white/light on dark
        foregroundColor = colorScheme.surface;
        break;
      case OmniButtonVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(color: colorScheme.outlineVariant);
        break;
    }

    if (onPressed == null) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
      if (borderSide != null) {
        borderSide = BorderSide(color: borderSide.color.withValues(alpha: 0.5));
      }
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor,
      disabledForegroundColor: foregroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: borderSide ?? BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    Widget child = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: child,
    );
  }
}
