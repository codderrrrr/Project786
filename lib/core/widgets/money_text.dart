import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

import 'package:subscription_saas_flutter/core/money/money.dart';

enum MoneyTone { neutral, success, warning, danger, primary, accent, inherit }

/// Money display with tabular figures. The full value is always exposed to
/// assistive tech even when visually compacted.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.tone = MoneyTone.inherit,
    this.compact = false,
    this.semanticPrefix,
  });

  final Decimal amount;
  final TextStyle? style;
  final MoneyTone tone;
  final bool compact;
  final String? semanticPrefix;

  Color? get _color {
    switch (tone) {
      case MoneyTone.success:
        return AppColors.success;
      case MoneyTone.warning:
        return AppColors.warning;
      case MoneyTone.danger:
        return AppColors.danger;
      case MoneyTone.primary:
        return AppColors.primary;
      case MoneyTone.accent:
        return AppColors.accent;
      case MoneyTone.neutral:
      case MoneyTone.inherit:
        return null;
    }
  }

  static MoneyTone toneForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return MoneyTone.danger;
      case 'due':
        return MoneyTone.warning;
      case 'paid':
      case 'success':
      case 'active':
        return MoneyTone.success;
      default:
        return MoneyTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppType.money;
    final text = compact
        ? MoneyUtils.formatCompactPKR(amount)
        : MoneyUtils.formatPKR(amount);
    return Semantics(
      label: '${semanticPrefix == null ? '' : '$semanticPrefix '}${MoneyUtils.formatDecimal(amount)} Pakistani Rupees',
      excludeSemantics: true,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _color == null ? base : base.copyWith(color: _color),
      ),
    );
  }
}

/// Money value that counts up on first paint. The tween only produces a
/// progress factor; the displayed value is always computed with Decimal
/// arithmetic so no authoritative amount ever passes through `double`.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(
    this.amount, {
    super.key,
    this.style,
    this.tone = MoneyTone.inherit,
    this.duration = const Duration(milliseconds: 700),
  });

  final Decimal amount;
  final TextStyle? style;
  final MoneyTone tone;
  final Duration duration;

  Color? get _color {
    switch (tone) {
      case MoneyTone.success:
        return AppColors.success;
      case MoneyTone.warning:
        return AppColors.warning;
      case MoneyTone.danger:
        return AppColors.danger;
      case MoneyTone.primary:
        return AppColors.primary;
      case MoneyTone.accent:
        return AppColors.accent;
      case MoneyTone.neutral:
      case MoneyTone.inherit:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = style ?? AppType.moneyHero;
    final effective = _color == null ? base : base.copyWith(color: _color);
    final semantic = '${MoneyUtils.formatDecimal(amount)} Pakistani Rupees';
    return Semantics(
      label: semantic,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: AppMotion.reduced(context) ? Duration.zero : duration,
        curve: AppMotion.emphasized,
        builder: (context, t, _) {
          final factor = Decimal.parse(t.toStringAsFixed(4));
          final shown = amount * factor;
          return Text(
            MoneyUtils.formatPKR(shown),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: effective,
          );
        },
      ),
    );
  }
}
