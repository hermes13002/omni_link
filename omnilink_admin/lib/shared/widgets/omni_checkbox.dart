import 'package:flutter/material.dart';

class OmniCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const OmniCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: colorScheme.tertiaryContainer, // 4EDEA3
      checkColor: colorScheme.onTertiaryContainer,
      side: BorderSide(
        color: colorScheme.outlineVariant,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
