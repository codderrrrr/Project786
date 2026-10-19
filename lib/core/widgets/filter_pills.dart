import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

class FilterOption {
  const FilterOption({required this.id, required this.label, this.count});

  final String id;
  final String label;
  final int? count;
}

/// Segmented control. Selected state is a solid accent fill — no gradient, no
/// glow — so the only colour on screen is the one that carries meaning.
class FilterPills extends StatelessWidget {
  const FilterPills({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.semanticLabel = 'Filter',
  });

  final List<FilterOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final index = options.indexWhere((o) => o.id == selectedId).clamp(0, options.length - 1);
    final n = options.length;
    final alignX = n == 1 ? 0.0 : -1.0 + (2 * index / (n - 1));

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        height: 40 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: AppRadii.rSm,
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedAlign(
                alignment: Alignment(alignX, 0),
                duration: AppMotion.scale(context, AppMotion.base),
                curve: AppMotion.emphasized,
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.rXs,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: options.map((o) {
                final selected = o.id == selectedId;
                return Expanded(
                  child: Semantics(
                    selected: selected,
                    button: true,
                    label: o.count == null ? o.label : '${o.label}, ${o.count} items',
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (selected) return;
                        HapticFeedback.selectionClick();
                        onSelected(o.id);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppMotion.scale(context, AppMotion.fast),
                          style: AppType.label.copyWith(
                            color: selected ? AppColors.onAccent : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    o.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (o.count != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${o.count}',
                                    style: AppType.label.copyWith(
                                      color: selected
                                          ? AppColors.onAccent.withValues(alpha: 0.7)
                                          : AppColors.textTertiary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
