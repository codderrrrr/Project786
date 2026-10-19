import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'pressable.dart';

class FilterOption {
  const FilterOption({required this.id, required this.label, this.count});

  final String id;
  final String label;
  final int? count;
}

/// The bar above a list: what you are looking at, how much of it there is, and
/// a way back to everything.
///
/// The chips scroll horizontally when they do not fit, the summary states the
/// active filter's real figures, and **Reset** appears only when a filter is
/// actually narrowing the list — so the control never claims an action that
/// would do nothing.
class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.summary,
    this.onReset,
    this.allId = 'all',
    this.semanticLabel = 'Filter',
  });

  final List<FilterOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  /// Live description of the visible set, e.g. "3 overdue · PKR 84,500".
  final Widget? summary;

  /// Clears every filter. Shown only while [selectedId] is not [allId].
  final VoidCallback? onReset;
  final String allId;
  final String semanticLabel;

  bool get _filtered => selectedId != allId && onReset != null;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final scaler = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34 * scaler,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _FilterChip(
              option: options[i],
              selected: options[i].id == selectedId,
              onTap: () {
                if (options[i].id == selectedId) return;
                HapticFeedback.selectionClick();
                onSelected(options[i].id);
              },
            ),
          ),
        ),
        if (summary != null || _filtered) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: AppType.caption,
                  child: summary ?? const SizedBox.shrink(),
                ),
              ),
              if (_filtered)
                Pressable(
                  onTap: onReset!,
                  semanticLabel: 'Clear the filter',
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 32, minWidth: 48),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Show all',
                      style: AppType.label.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final FilterOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onAccent : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: option.count == null ? option.label : '${option.label}, ${option.count}',
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.scale(context, AppMotion.fast),
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? null : AppColors.surface,
            gradient: selected
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: AppRadii.rPill,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineSoft,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.label.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (option.count != null) ...[
                const SizedBox(width: 6),
                Text(
                  '${option.count}',
                  style: AppType.moneySmall.copyWith(
                    color: selected
                        ? AppColors.onAccent.withValues(alpha: 0.75)
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
