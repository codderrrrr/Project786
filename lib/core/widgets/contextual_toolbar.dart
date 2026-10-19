import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// The toolbar that appears while rows are selected.
///
/// It states the selection's real figures (how many, how much), offers the one
/// commit action, and stays out of the way otherwise — it is not rendered at
/// all when nothing is selected, so it can never cover a row that matters.
class ContextualToolbar extends StatelessWidget {
  const ContextualToolbar({
    super.key,
    required this.count,
    required this.totalLabel,
    required this.actionLabel,
    required this.onAction,
    required this.onClear,
    this.onSelectAll,
    this.selectAllLabel = 'Select all',
    this.secondary,
  });

  final int count;
  final String totalLabel;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onClear;

  /// Optional bulk shortcut; hidden when the caller has nothing to select.
  final VoidCallback? onSelectAll;
  final String selectAllLabel;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    // Announce the selection once for screen readers; appearance is the
    // caller's business, so this widget stays pure layout.
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$count selected, $totalLabel',
      child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: AppRadii.rMd,
            border: Border.all(color: AppColors.outline),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count selected',
                          style: AppType.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalLabel,
                          style: AppType.moneyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  secondary ?? const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
                ],
              ),
              if (onSelectAll != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onSelectAll,
                    child: Text(selectAllLabel),
                  ),
                ),
            ],
          ),
        ),
    );
  }
}
