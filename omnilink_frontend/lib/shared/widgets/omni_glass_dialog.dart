import 'dart:ui';
import 'package:flutter/material.dart';
import 'omni_glass_container.dart';

class OmniGlassDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  const OmniGlassDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: OmniGlassContainer(
          padding: const EdgeInsets.all(24.0),
          borderRadius: 24.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              DefaultTextStyle(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ) ?? const TextStyle(),
                child: title,
              ),
              const SizedBox(height: 16),
              
              // Content
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ) ?? const TextStyle(),
                child: content,
              ),
              const SizedBox(height: 24),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((a) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: a,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
