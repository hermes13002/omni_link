import 'package:flutter/material.dart';

class OmniSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const OmniSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: colorScheme.onSurface,
      activeTrackColor: activeColor ?? colorScheme.tertiaryContainer, // Uses #4EDEA3 (greenish) by default for active state
      inactiveThumbColor: colorScheme.onSurfaceVariant,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return colorScheme.outlineVariant;
      }),
    );
  }
}
