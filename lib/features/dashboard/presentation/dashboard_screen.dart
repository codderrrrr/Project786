import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/pagination/cursor.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/app_shell.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/aurora_card.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/minimal_card.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/section_header_artistic.dart';
import 'package:subscription_saas_flutter/features/billing/data/providers/billing_providers.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';
import 'package:subscription_saas_flutter/features/dashboard/presentation/hide_amounts_provider.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obligations = ref.watch(billingObligationsProvider);
    final payments = ref.watch(paymentsListProvider(null));
    final subscribers = ref.watch(subscribersListProvider(null));
    final services = ref.watch(servicesListProvider);
    final amountsHidden = ref.watch(hideAmountsProvider);

    return AppScaffold(
      title: 'Demo Business',
      subtitle: BizDate.todayLabel(),
      showBack: false,
      onMenu: AppShell.openDrawer,
      bodyPadding: EdgeInsets.zero,
      body: obligations.when(
        loading: () => const LoadingView(rows: 5),
        error: (error, _) => ErrorView(
          message: 'Your dashboard could not be loaded. Check your connection and try again.',
          onRetry: () {
            ref.invalidate(billingObligationsProvider);
            ref.invalidate(paymentsListProvider(null));
            ref.invalidate(subscribersListProvider(null));
            ref.invalidate(servicesListProvider);
          },
        ),
        data: (page) {
          final items = page.items;
          final overdue = items.where((item) => item.status == 'overdue').toList();
          final expected = MoneyUtils.sum(items.map((item) => item.amountDue));
          final overdueTotal = MoneyUtils.sum(overdue.map((item) => item.amountDue));
          final paidThisMonth = _paymentsThisMonth(payments);
          final collected = MoneyUtils.sum(paidThisMonth.map((item) => item.finalAmount));
          final paidSubscriberCount = paidThisMonth.map((item) => item.subscriberId).toSet().length;
          final activeSubscribers = subscribers.maybeWhen(
            data: (value) => value.items.where((subscriber) => subscriber.active).length,
            orElse: () => 0,
          );
          final totalSubscribers = subscribers.maybeWhen(
            data: (value) => value.items.length,
            orElse: () => 0,
          );
          final serviceItems = services.maybeWhen(
            data: (value) => value.items,
            orElse: () => const [],
          );
          final mostUsedService = _mostUsedService(items);
          final Decimal averagePerUser = activeSubscribers == 0
              ? Decimal.zero
              : (expected / Decimal.fromInt(activeSubscribers)).toDecimal(scaleOnInfinitePrecision: 2);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(billingObligationsProvider);
              ref.invalidate(paymentsListProvider(null));
              ref.invalidate(subscribersListProvider(null));
              ref.invalidate(servicesListProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gap.gutter, 8, Gap.gutter, 116),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _CollectionHeroApple(
                  amount: collected,
                  subscriberCount: paidSubscriberCount,
                  hidden: amountsHidden,
                  onTap: () => context.go('/history'),
                ),
                const SizedBox(height: 24),
                SectionHeaderArtistic(
                  title: 'Business pulse',
                  subtitle: 'A clear view of today\'s numbers',
                ),
                const SizedBox(height: 10),
                MinimalCard(
                  padding: const EdgeInsets.all(12),
                  child: _MetricGridApple(
                    cards: [
                      _MetricCardDataApple(
                        label: 'Expected revenue',
                        value: _money(expected, amountsHidden),
                        detail: '${_money(averagePerUser, amountsHidden)} avg. per active user',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.primary,
                        onTap: () => context.go('/billing'),
                      ),
                      _MetricCardDataApple(
                        label: 'Overdue payments',
                        value: _money(overdueTotal, amountsHidden),
                        detail: '${overdue.length} ${overdue.length == 1 ? 'subscriber' : 'subscribers'} need attention',
                        icon: Icons.schedule_rounded,
                        color: overdue.isEmpty ? AppColors.success : AppColors.danger,
                        onTap: () => context.go('/billing'),
                      ),
                      _MetricCardDataApple(
                        label: 'Services offered',
                        value: '${serviceItems.length}',
                        detail: mostUsedService == null ? 'No usage data yet' : 'Most used · $mostUsedService',
                        icon: Icons.layers_rounded,
                        color: AppColors.info,
                        onTap: () => context.go('/services'),
                      ),
                      _MetricCardDataApple(
                        label: 'Active subscribers',
                        value: '$activeSubscribers',
                        detail: '$totalSubscribers total subscribers',
                        icon: Icons.people_alt_rounded,
                        color: AppColors.success,
                        onTap: () => context.go('/subscribers'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeaderArtistic(
                  title: 'Recent activity',
                  subtitle: 'Latest payments recorded',
                  actionLabel: 'See all',
                  onAction: () => context.go('/history'),
                ),
                const SizedBox(height: 8),
                MinimalCard(
                  padding: const EdgeInsets.all(12),
                  child: _RecentActivityApple(payments: payments, hidden: amountsHidden),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static List<Payment> _paymentsThisMonth(AsyncValue<CursorPage<Payment>> payments) {
    final month = BizDate.todayYMD().substring(0, 7);
    return payments.maybeWhen(
      data: (page) => page.items.where((payment) => payment.paymentDate.startsWith(month)).toList(),
      orElse: () => const [],
    );
  }

  static String? _mostUsedService(List<Obligation> items) {
    final counts = <String, int>{};
    for (final item in items) {
      for (final service in item.serviceNames) {
        counts[service] = (counts[service] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static String _money(Decimal value, bool hidden) => hidden ? '••••' : MoneyUtils.formatCompactPKR(value);
}

class _CollectionHeroApple extends StatelessWidget {
  const _CollectionHeroApple({
    required this.amount,
    required this.subscriberCount,
    required this.hidden,
    required this.onTap,
  });

  final Decimal amount;
  final int subscriberCount;
  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.onAccent;
    final amountLabel = hidden ? 'hidden' : MoneyUtils.formatPKR(amount);

    return Semantics(
      button: true,
      label: 'Collected this month $amountLabel from $subscriberCount subscribers',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.rXl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadii.rXl,              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 48,
                  offset: const Offset(0, 20),
                ),
              ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.16),
                      borderRadius: AppRadii.rPill,
                    ),
                    child: Text(
                      'THIS MONTH',
                      style: AppType.overline.copyWith(color: foreground, letterSpacing: 1.1),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, color: foreground, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              Text('Collected', style: AppType.body.copyWith(color: foreground.withValues(alpha: 0.78))),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amountLabel,
                  style: AppType.moneyHero.copyWith(color: foreground, fontSize: 36, height: 1.1),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.verified_rounded, color: foreground, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$subscriberCount ${subscriberCount == 1 ? 'subscriber' : 'subscribers'} made a payment',
                      style: AppType.caption.copyWith(color: foreground.withValues(alpha: 0.84)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricGridApple extends StatelessWidget {
  const _MetricGridApple({required this.cards});

  final List<_MetricCardDataApple> cards;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surface : Colors.white;
    final cardBorder = isDark ? AppColors.outline : AppColors.outlineSoft;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadii.rLg,
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < cards.length; i += 2)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _MetricCardApple(data: cards[i])),
                  if (i + 1 < cards.length) ...[
                    const VerticalDivider(width: 1),
                    Expanded(child: _MetricCardApple(data: cards[i + 1])),
                  ] else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCardApple extends StatelessWidget {
  const _MetricCardApple({required this.data});

  final _MetricCardDataApple data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: data.onTap,
      borderRadius: AppRadii.rLg,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          borderRadius: AppRadii.rLg,
          border: Border.all(color: isDark ? AppColors.outline : AppColors.outlineSoft),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: AppRadii.rSm,
              ),
              child: Icon(data.icon, color: data.color, size: 19),
            ),
            const SizedBox(height: 10),
            Text(
              data.label,
              style: AppType.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(data.value),
            const SizedBox(height: 3),
            Text(
              data.detail,
              style: AppType.overline.copyWith(color: isDark ? AppColors.textTertiary : AppColors.textTertiary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCardDataApple {
  const _MetricCardDataApple({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _RecentActivityApple extends StatelessWidget {
  const _RecentActivityApple({required this.payments, required this.hidden});

  final AsyncValue<CursorPage<Payment>> payments;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return payments.when(
      loading: () => const _ActivitySkeletonApple(),
      error: (error, _) => const _ActivityMessageApple(
        icon: Icons.cloud_off_rounded,
        text: 'Recent payments are unavailable right now.',
      ),
      data: (page) {
        if (page.items.isEmpty) {
          return const _ActivityMessageApple(
            icon: Icons.receipt_long_rounded,
            text: 'Payments will appear here once you collect one.',
          );
        }
        final latest = page.items.take(3).toList();
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.surface : Colors.white,
            borderRadius: AppRadii.rLg,
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.outline : AppColors.outlineSoft,
            ),
          ),
          child: Column(
            children: [
              for (var index = 0; index < latest.length; index++) ...[
                _PaymentActivityRowApple(payment: latest[index], hidden: hidden),
                if (index != latest.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PaymentActivityRowApple extends StatelessWidget {
  const _PaymentActivityRowApple({required this.payment, required this.hidden});

  final Payment payment;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? AppColors.textTertiary : AppColors.textTertiary;

    return InkWell(
      onTap: () => context.push('/payments/${payment.id}'),
      borderRadius: AppRadii.rLg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: AppColors.success, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.subscriberName,
                    style: AppType.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateLabel(payment.paymentDate),
                    style: AppType.caption.copyWith(color: subtitleColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                hidden ? '••••' : MoneyUtils.formatCompactPKR(payment.finalAmount),
                style: AppType.label.copyWith(color: AppColors.success),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(String value) {
    if (value.isEmpty) return 'Payment recorded';
    return BizDate.dayName(value);
  }
}

class _ActivitySkeletonApple extends StatelessWidget {
  const _ActivitySkeletonApple();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: AppRadii.rLg,
        border: Border.all(color: isDark ? AppColors.outline : AppColors.outlineSoft),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ActivityMessageApple extends StatelessWidget {
  const _ActivityMessageApple({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceAlt : Colors.white;
    final borderColor = isDark ? AppColors.outline : AppColors.outline;
    final textColor = isDark ? AppColors.textSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadii.rLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppType.body.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}