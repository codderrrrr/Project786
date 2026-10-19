import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'skeletons.dart';

/// Full-screen loading state built from skeletons rather than a bare spinner.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.rows = 5, this.withStats = false});

  final int rows;
  final bool withStats;

  @override
  Widget build(BuildContext context) {
    // Scrollable, not a Column: on a short screen the placeholder is taller
    // than the viewport while data loads, and a bare Column would overflow.
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.gutter, 8, Gap.gutter, 24),
      children: [
        if (withStats) ...[const StatSkeleton(), const SizedBox(height: 20)],
        ListSkeleton(rows: rows),
      ],
    );
  }
}

/// Empty state with a plain-language explanation and the relevant action, so
/// the user is never left at a dead end.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_rounded,
    this.tone,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? title;
  final IconData icon;

  /// Defaults to the palette's primary accent when omitted.
  final Color? tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tint = tone ?? AppColors.primary;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: tint, size: 28),
            const SizedBox(height: 12),
            if (title != null) ...[
              Text(title!, style: AppType.title, textAlign: TextAlign.center),
              const SizedBox(height: 4),
            ],
            Text(message, style: AppType.body, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
    // Centred when the viewport can hold the message; scrollable when it
    // cannot (landscape, small phones, large text) — a fixed centred column
    // overflows its box by hundreds of pixels instead.
    //
    // The maxWidth cap must sit *outside* IntrinsicHeight: intrinsic queries
    // pass the parent's width straight to the text, so a wide landscape
    // viewport would measure the message unwrapped, underestimate the height,
    // and clip the wrapped content at layout time. The outer Center recentres
    // the capped block in the full-width viewport.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Center(child: content);
        }
        return Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxWidth: 360,
              ),
              child: IntrinsicHeight(child: Center(child: content)),
            ),
          ),
        );
      },
    );
  }
}

/// Error state that states what happened, what it means, and what to do next —
/// without leaking technical detail.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.title = 'Could not load',
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, color: AppColors.danger, size: 28),
              const SizedBox(height: 12),
              Text(title, style: AppType.title, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(message, style: AppType.body, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact inline placeholder for a section that failed inside a screen that
/// otherwise loaded.
class InlineError extends StatelessWidget {
  const InlineError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: AppRadii.rSm,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppType.caption.copyWith(color: AppColors.textPrimary),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
