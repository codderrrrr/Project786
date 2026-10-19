import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'glass_card.dart';
import 'pressable.dart';

/// A metric block: label, tabular value, optional footnote and trend line.
///
/// Flat by design — a hairline, a label and a number. No icon chip, no badge,
/// no gradient fill under the trend line.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
    this.deltaLabel,
    this.deltaPositive = true,
    this.footnote,
    this.onTap,
    this.semanticHint,
    this.spark,
    this.compact = false,
  });

  final String label;
  final String value;

  /// Retained for compatibility; metrics no longer render a leading icon.
  final IconData? icon;

  /// Tints the trend line and delta only.
  final Color? accent;
  final String? deltaLabel;
  final bool deltaPositive;
  final String? footnote;
  final VoidCallback? onTap;
  final String? semanticHint;
  final List<double>? spark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tint = accent ?? AppColors.primary;
    return GlassCard(
      padding: EdgeInsets.all(compact ? 12 : 14),
      onTap: onTap,
      semanticLabel: '$label: $value${footnote == null ? '' : ', $footnote'}',
      semanticHint: semanticHint ?? onClickHint,
      excludeChildSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.caption,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppType.moneyLarge),
          ),
          if (deltaLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              deltaLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.caption.copyWith(
                color: deltaPositive ? AppColors.success : AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 2),
            Text(
              footnote!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppType.caption,
            ),
          ],
          if (spark != null && spark!.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 24,
              child: CustomPaint(
                painter: _SparkPainter(spark!, tint),
                size: const Size(double.infinity, 24),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String get onClickHint => 'Double tap to open';
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height - ((values[i] - minV) / span) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.values != values || old.color != color;
}

/// Small outline row used for secondary promises ("Add service").
class GhostTile extends StatelessWidget {
  const GhostTile({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.accent,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  /// Retained for compatibility; outline rows use the palette accent only.
  final Color? accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tint = accent ?? AppColors.primary;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          borderRadius: AppRadii.rMd,
          border: Border.all(color: tint.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: tint, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
