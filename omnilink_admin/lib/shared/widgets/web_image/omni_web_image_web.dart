import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:math';

Widget buildWebImage(String imageUrl, BoxFit fit) {
  final String viewId = 'web-img-${Random().nextInt(1000000)}';
  ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final img = html.ImageElement()
      ..src = imageUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.cover ? 'cover' : (fit == BoxFit.contain ? 'contain' : 'fill')
      ..style.border = 'none';
    return img;
  });
  return HtmlElementView(viewType: viewId);
}
