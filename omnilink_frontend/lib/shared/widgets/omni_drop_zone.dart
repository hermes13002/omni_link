import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'omni_glass_container.dart';

class OmniDropZone extends StatelessWidget {
  const OmniDropZone({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return OmniGlassContainer(
      borderRadius: 9999,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(178),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(LucideIcons.plus, color: colorScheme.onSurface),
              onPressed: () {},
              iconSize: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type, paste link, or drop file...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.mic, color: colorScheme.onSurfaceVariant),
            onPressed: () {},
            iconSize: 20,
          ),
          IconButton(
            icon: Icon(LucideIcons.camera, color: colorScheme.onSurfaceVariant),
            onPressed: () {},
            iconSize: 20,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primaryContainer.withAlpha(102),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: IconButton(
              icon: Icon(LucideIcons.send, color: colorScheme.onPrimaryContainer),
              onPressed: () {},
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
