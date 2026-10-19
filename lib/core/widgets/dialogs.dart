import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Confirmation dialog for consequential actions.
///
/// [consequence] states in plain language what will happen, and the
/// destructive action is never the default-highlighted choice without being
/// explicitly labelled — this is error prevention, not a speed bump.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? consequence,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceHigh,
      // Scrollable + stackable actions: a long consequence sentence must never
      // push the choices off-screen at large system text sizes.
      scrollable: true,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.rXl),
      icon: Icon(
        destructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
        color: destructive ? AppColors.danger : AppColors.primary,
        size: 28,
      ),
      title: Text(title, textAlign: TextAlign.center, style: AppType.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: AppType.body),
          if (consequence != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (destructive ? AppColors.danger : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: AppRadii.rMd,
                border: Border.all(
                  color: (destructive ? AppColors.danger : AppColors.primary).withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: destructive ? AppColors.danger : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      consequence,
                      style: AppType.caption.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: AppColors.onDanger)
              : null,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop(true);
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Bottom sheet with a drag handle, title, optional subtitle and a close
/// affordance. Content scrolls and respects the keyboard inset.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext context) builder,
  bool isScrollControlled = true,
  bool dismissible = true,
  double maxHeightFactor = 0.92,
}) {
  final media = MediaQuery.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: dismissible,
    enableDrag: dismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * maxHeightFactor),
          child: Container(
            // A rounded border must be painted with one uniform side colour,
            // so the brighter top edge is a separate hairline below instead.
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: AppRadii.rSheet,
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: AppRadii.rPill,
                  ),
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: AppColors.outline.withValues(alpha: 0.5)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppType.title),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(subtitle, style: AppType.caption),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(child: builder(context)),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Toast-like feedback that offers an undo affordance for reversible actions.
void showAppSnack(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  bool error = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: error ? AppColors.danger.withValues(alpha: 0.16) : AppColors.surfaceHigh,
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              size: 18,
              color: error ? AppColors.danger : AppColors.success,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: AppType.bodyStrong)),
          ],
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}
