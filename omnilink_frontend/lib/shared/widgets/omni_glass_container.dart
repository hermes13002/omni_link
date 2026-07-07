import 'dart:ui';
import 'package:flutter/material.dart';

class OmniGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final BoxBorder? border;

  const OmniGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? Theme.of(context).colorScheme.surface.withAlpha(25),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
