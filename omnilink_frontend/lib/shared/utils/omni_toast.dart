import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../core/globals.dart';

class OmniToast {
  static bool get _isDesktop {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      return false;
    }
  }

  static Alignment get _toastAlignment => 
      _isDesktop ? Alignment.topRight : Alignment.topCenter;

  static void _showCustomToast(
    BuildContext? context, 
    String message, 
    IconData icon, 
    Color color,
  ) {
    final ctx = context ?? scaffoldMessengerKey.currentContext!;
    final theme = Theme.of(ctx);

    toastification.showCustom(
      context: ctx,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: _toastAlignment,
      builder: (BuildContext context, ToastificationItem holder) {
        return Align(
          alignment: _toastAlignment,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha(180),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(80), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  static void showSuccess(BuildContext? context, String message) {
    _showCustomToast(context, message, Icons.check_circle_rounded, Colors.greenAccent);
  }

  static void showError(BuildContext? context, String message) {
    _showCustomToast(context, message, Icons.error_rounded, Colors.redAccent);
  }

  static void showInfo(BuildContext? context, String message) {
    _showCustomToast(context, message, Icons.info_rounded, Colors.blueAccent);
  }

  static void showWarning(BuildContext? context, String message) {
    _showCustomToast(context, message, Icons.warning_rounded, Colors.orangeAccent);
  }
}
