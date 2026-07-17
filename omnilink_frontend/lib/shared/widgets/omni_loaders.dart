import 'package:flutter/material.dart';

class OmniDotsLoader extends StatefulWidget {
  final Color? color;
  final double size;

  const OmniDotsLoader({
    super.key,
    this.color,
    this.size = 8.0,
  });

  @override
  State<OmniDotsLoader> createState() => _OmniDotsLoaderState();
}

class _OmniDotsLoaderState extends State<OmniDotsLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primaryContainer;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = (index * 0.2);
            final value = (_controller.value + offset) % 1.0;
            final scale = 1.0 - (value < 0.5 ? value : 1.0 - value) * 0.5;
            final opacity = 0.5 + (value < 0.5 ? value : 1.0 - value);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
