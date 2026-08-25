import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';

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

class OmniLogoLoader extends StatefulWidget {
  final double size;
  const OmniLogoLoader({super.key, this.size = 100});

  @override
  State<OmniLogoLoader> createState() => _OmniLogoLoaderState();
}

class _OmniLogoLoaderState extends State<OmniLogoLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Image.asset(
              'assets/images/logo/infinity.png',
              width: widget.size,
              height: widget.size,
            ),
          ),
        );
      }
    );
  }
}

class OmniSkeletonTimeline extends StatefulWidget {
  final bool isMobile;
  const OmniSkeletonTimeline({super.key, this.isMobile = false});

  @override
  State<OmniSkeletonTimeline> createState() => _OmniSkeletonTimelineState();
}

class _OmniSkeletonTimelineState extends State<OmniSkeletonTimeline> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late List<double> _randomHeights;

  @override
  void initState() {
    super.initState();
    final random = Random(42); // fixed seed for stable layout
    _randomHeights = List.generate(12, (index) => 150.0 + random.nextInt(200));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.extent(
      maxCrossAxisExtent: widget.isMobile ? 600 : 320,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      padding: const EdgeInsets.all(24.0).copyWith(bottom: 120),
      itemCount: 12,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                height: _randomHeights[index],
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }
        );
      },
    );
  }
}
