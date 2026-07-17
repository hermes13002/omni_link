import 'dart:io' show Platform;
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

  static void showSuccess(BuildContext? context, String message) {
    toastification.show(
      context: context ?? scaffoldMessengerKey.currentContext!,
      title: message,
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      alignment: _toastAlignment,
      borderRadius: BorderRadius.circular(8),
      showProgressBar: false,
    );
  }

  static void showError(BuildContext? context, String message) {
    toastification.show(
      context: context ?? scaffoldMessengerKey.currentContext!,
      title: message,
      autoCloseDuration: const Duration(seconds: 4),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      alignment: _toastAlignment,
      borderRadius: BorderRadius.circular(8),
      showProgressBar: false,
    );
  }

  static void showInfo(BuildContext? context, String message) {
    toastification.show(
      context: context ?? scaffoldMessengerKey.currentContext!,
      title: message,
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      alignment: _toastAlignment,
      borderRadius: BorderRadius.circular(8),
      showProgressBar: false,
    );
  }

  static void showWarning(BuildContext? context, String message) {
    toastification.show(
      context: context ?? scaffoldMessengerKey.currentContext!,
      title: message,
      autoCloseDuration: const Duration(seconds: 4),
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      alignment: _toastAlignment,
      borderRadius: BorderRadius.circular(8),
      showProgressBar: false,
    );
  }
}
