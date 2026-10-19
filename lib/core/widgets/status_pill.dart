import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

enum PillTone { success, warning, danger, info, neutral, primary, accent }

/// Status label. A small filled dot plus a word — status is never carried by
/// colour alone, and never needs a bordered chip competing with the row's
/// primary action.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.icon,
    this.compact = false,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;
  final bool compact;

  static (PillTone, IconData, String) describe(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return (PillTone.danger, Icons.error_outline_rounded, 'Overdue');
      case 'due':
        return (PillTone.warning, Icons.schedule_rounded, 'Due');
      case 'paid':
      case 'success':
        return (PillTone.success, Icons.check_circle_outline_rounded, 'Paid');
      case 'active':
        return (PillTone.success, Icons.check_circle_outline_rounded, 'Active');
      case 'inactive':
        return (PillTone.neutral, Icons.pause_circle_outline_rounded, 'Inactive');
      case 'cancelled':
      case 'canceled':
        return (PillTone.neutral, Icons.block_rounded, 'Cancelled');
      case 'expired':
        return (PillTone.neutral, Icons.history_rounded, 'Expired');
      case 'grace_period':
      case 'grace period':
        return (PillTone.warning, Icons.hourglass_bottom_rounded, 'Grace period');
      case 'read_only':
      case 'read only':
        return (PillTone.info, Icons.visibility_outlined, 'Read-only');
      case 'blocked':
        return (PillTone.danger, Icons.lock_outline_rounded, 'Blocked');
      default:
        return (PillTone.neutral, Icons.circle_outlined, status);
    }
  }

  static StatusPill fromStatus(String status, {bool compact = false}) {
    final (tone, icon, text) = describe(status);
    return StatusPill(label: text, tone: tone, icon: icon, compact: compact);
  }

  Color get _fg {
    switch (tone) {
      case PillTone.success:
        return AppColors.success;
      case PillTone.warning:
        return AppColors.warning;
      case PillTone.danger:
        return AppColors.danger;
      case PillTone.info:
      case PillTone.primary:
        return AppColors.primary;
      case PillTone.accent:
        return AppColors.accent;
      case PillTone.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fg;
    return Semantics(
      label: label,
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
