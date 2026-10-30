import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/mini_charts.dart';
import 'package:subscription_saas_flutter/core/widgets/rate_track.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/core/components/surface_card.dart';
import 'package:subscription_saas_flutter/features/billing/data/providers/billing_providers.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/providers/subscriptions_providers.dart';

/// Read-only reporting. Every figure here is derived from recorded data; the
/// screen never becomes the source of truth for a financial value.
///
/// The layout answers three questions in order: how much has been collected,
/// how much is still out, and how the balance has moved month to month.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsListProvider(null));
    final subscriptions = ref.watch(subscriptionsListProvider(null));
    final subscribers = ref.watch(subscribersListProvider(null));
    final obligations = ref.watch(billingObligationsProvider);

    return AppScaffold(
      title: 'Analytics',
      subtitle: 'From recorded payments',
      body: payments.when(
        data: (paymentsPage) {
          final collected = MoneyUtils.sum(
            paymentsPage.items.map((p) => p.finalAmount),
          );
          final paymentCount = paymentsPage.items.length;

          final activeSubs = subscriptions.maybeWhen(
            data: (p) => p.items
                .where((s) => !s.cancelled && s.status == 'active')
                .length,
            orElse: () => 0,
          );
          final totalSubs = subscriptions.maybeWhen(
            data: (p) => p.items.length,
            orElse: () => 0,
          );
          final activePeople = subscribers.maybeWhen(
            data: (p) => p.items.where((s) => s.active).length,
            orElse: () => 0,
          );
          final totalPeople = subscribers.maybeWhen(
            data: (p) => p.items.length,
            orElse: () => 0,
          );
          final outstanding = obligations.maybeWhen(
            data: (p) => MoneyUtils.sum(p.items.map((o) => o.amountDue)),
            orElse: () => Decimal.zero,
          );

          final expected = outstanding + collected;
          final collectionRate = expected == Decimal.zero
              ? 0.0
              : (collected / expected)
                    .toDecimal(scaleOnInfinitePrecision: 4)
                    .toDouble();
          // Six-month trend built from recorded payments; zero-filled months
          // are shown honestly as zero rather than interpolated.
          final now = DateTime.now();
          final buckets = <BarDatum>[];
          for (var i = 5; i >= 0; i--) {
            final month = DateTime(now.year, now.month - i, 1);
            final label = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ][month.month - 1];
            final total = MoneyUtils.sum(
              paymentsPage.items
                  .where((p) {
                    final d = DateTime.tryParse(p.paymentDate);
                    return d != null &&
                        d.year == month.year &&
                        d.month == month.month;
                  })
                  .map((p) => p.finalAmount),
            );
            buckets.add(
              BarDatum(label, double.parse(total.toStringAsFixed(2))),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Summary: no ring, no gradient — value, rate and the remainder.
              SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Collected', style: AppType.caption),
                    const SizedBox(height: 4),
                    Text(
                      MoneyUtils.formatPKR(collected),
                      style: AppType.moneyHero,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      label: 'Collection rate',
                      value: '${(collectionRate * 100).round()}%',
                    ),
                    _SummaryLine(
                      label: 'Payments recorded',
                      value: '$paymentCount',
                    ),
                    _SummaryLine(
                      label: 'Outstanding',
                      value: MoneyUtils.formatPKR(outstanding),
                      tone: outstanding == Decimal.zero
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Capacity'),
              SurfaceSection(
                children: [
                  SurfaceRow(
                    title: 'Active subscriptions',
                    subtitle: '$activeSubs of $totalSubs running',
                    showChevron: false,
                    trailing: Text('$activeSubs', style: AppType.moneyLarge),
                  ),
                  SurfaceRow(
                    title: 'Active subscribers',
                    subtitle: '$activePeople of $totalPeople can be billed',
                    showChevron: false,
                    trailing: Text('$activePeople', style: AppType.moneyLarge),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Collected by month',
                subtitle: 'Six months, from recorded payments',
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.rMd,
                  border: Border.all(color: AppColors.outlineSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MiniBarChart(
                      data: buckets,
                      height: 132,
                      valueFormatter: (v) => v == 0
                          ? '—'
                          : MoneyUtils.formatPKRFromDouble(v)
                                .replaceAll('PKR ', ''),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        LegendDot(color: AppColors.primary, label: 'Collected'),
                        LegendDot(
                          color: AppColors.outline,
                          label: 'No payments',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Utilisation'),
              SurfaceSection(
                children: [
                  RateTrack(
                    active: activeSubs,
                    total: totalSubs,
                    label: 'Subscriptions running',
                    detail:
                        '$activePeople of $totalPeople subscribers now on a live plan',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'As of ${BizDate.todayLabel()} · figures come from recorded payments',
                style: AppType.caption,
              ),
            ],
          );
        },
        loading: () => const LoadingView(rows: 4),
        error: (e, _) => ErrorView(
          message: 'The analytics view could not be built. Check your connection and try again.',
          onRetry: () => ref.invalidate(paymentsListProvider),
        ),
      ),
    );
  }
}

/// Label left, value right, on a shared baseline — the numbers form a column.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value, this.tone});

  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppType.caption)),
          Text(
            value,
            style: AppType.bodyStrong.copyWith(
              color: tone ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
