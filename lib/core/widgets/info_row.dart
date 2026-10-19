import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Label/value row for detail screens. `locked` marks a field the business
/// rules do not allow the owner to change, which is shown explicitly rather
/// than implied by a disabled control.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.locked = false,
    this.hint,
    this.trailing,
  });

  final String label;
  final String value;
  final bool locked;
  final String? hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                if (locked)
                  Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textTertiary),
                  ),
                Expanded(
                  child: Text(
                    label,
                    style: AppType.caption.copyWith(
                      color: locked ? AppColors.textTertiary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppType.bodyStrong,
                ),
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(hint!, textAlign: TextAlign.right, style: AppType.overline.copyWith(letterSpacing: 0.2)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
