import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'pressable.dart';

/// Label above a group of rows. Deliberately plain: a title, an optional count
/// in the same visual weight as body text, and at most one text action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.figure,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final int? count;

  /// A right-aligned total for the group, in the display face — this is what
  /// turns a label into a ledger heading.
  final String? figure;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // The title yields space first; the count and the group
                    // total keep their figures intact.
                    Expanded(
                      child: Text(
                        title,
                        style: AppType.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: AppType.label.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                    if (figure != null) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          figure!,
                          style: AppType.moneySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppType.caption),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            Pressable(
              onTap: onAction,
              semanticLabel: actionLabel,
              // 48dp tall target: a section action is still a control, even
              // when it is written as a link.
              child: Container(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  actionLabel!,
                  style: AppType.label.copyWith(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
