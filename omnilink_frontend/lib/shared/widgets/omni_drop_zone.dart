import 'package:flutter/material.dart';
import 'omni_glass_container.dart';

class OmniDropZone extends StatefulWidget {
  const OmniDropZone({super.key});

  @override
  State<OmniDropZone> createState() => _OmniDropZoneState();
}

class _OmniDropZoneState extends State<OmniDropZone> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

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
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: _rotateAnimation,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: colorScheme.onSurface),
                      onPressed: _toggleMenu,
                      iconSize: 20,
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axis: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: colorScheme.onSurface),
                        onPressed: () {},
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: Icon(Icons.image, color: colorScheme.onSurface),
                        onPressed: () {},
                        iconSize: 20,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type, paste link...',
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
            icon: Icon(Icons.mic, color: colorScheme.onSurfaceVariant),
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
              icon: Icon(Icons.send, color: colorScheme.onPrimaryContainer),
              onPressed: () {},
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
