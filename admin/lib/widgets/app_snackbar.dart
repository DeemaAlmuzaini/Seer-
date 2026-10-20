import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The four kinds of messages shown at the bottom of the screen.
enum AppMessageType { success, error, warning, info }

void showAppMessage(
  BuildContext context,
  String message, {
  bool isError = true,
  AppMessageType? type,
}) {
  // Old calls only pass isError; new calls pass a type.
  final kind =
      type ?? (isError ? AppMessageType.error : AppMessageType.success);

  final (Color color, IconData icon) = switch (kind) {
    AppMessageType.success => (AppColors.success, Icons.check_circle_outline),
    AppMessageType.error => (AppColors.error, Icons.error_outline),
    AppMessageType.warning => (AppColors.warning, Icons.warning_amber_rounded),
    AppMessageType.info => (AppColors.accent, Icons.info_outline),
  };

  // White text is hard to read on orange, so warning uses dark text.
  final textColor =
      kind == AppMessageType.warning ? Colors.black87 : Colors.white;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: textColor)),
            ),
          ],
        ),
      ),
    );
}