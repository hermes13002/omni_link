import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'omni_web_image_stub.dart'
    if (dart.library.html) 'omni_web_image_web.dart';

class OmniWebImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final String? cacheKey;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  const OmniWebImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.cacheKey,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return buildWebImage(imageUrl, fit);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: cacheKey,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
