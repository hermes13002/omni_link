import 'package:flutter/material.dart';

class OmniTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final bool isSearch;
  final bool autofocus;
  final int? maxLength;

  const OmniTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.autofocus = false,
    this.maxLength,
  }) : isSearch = false;

  const OmniTextField.search({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.onChanged,
  })  : isPassword = false,
        keyboardType = TextInputType.text,
        validator = null,
        labelText = null,
        prefixIcon = Icons.search_rounded,
        suffixIcon = null,
        onSuffixPressed = null,
        autofocus = false,
        maxLength = null,
        isSearch = true;

  @override
  State<OmniTextField> createState() => _OmniTextFieldState();
}

class _OmniTextFieldState extends State<OmniTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final outlineColor = widget.isSearch 
        ? colorScheme.outlineVariant.withValues(alpha: 0.5) 
        : colorScheme.outlineVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null && !widget.isSearch) ...[
          Text(
            widget.labelText!,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          autofocus: widget.autofocus,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          cursorColor: colorScheme.primaryContainer,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: colorScheme.onSurfaceVariant)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(widget.suffixIcon, color: colorScheme.onSurfaceVariant),
                        onPressed: widget.onSuffixPressed,
                      )
                    : null,
            filled: true,
            fillColor: widget.isSearch ? colorScheme.surfaceContainerLow : colorScheme.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isSearch ? 24 : 8),
              borderSide: BorderSide(color: outlineColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isSearch ? 24 : 8),
              borderSide: BorderSide(color: outlineColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isSearch ? 24 : 8),
              borderSide: BorderSide(color: colorScheme.primaryContainer),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isSearch ? 24 : 8),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.isSearch ? 24 : 8),
              borderSide: BorderSide(color: colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
