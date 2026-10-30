import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/money_text.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/billing/data/providers/billing_providers.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';
import 'package:subscription_saas_flutter/core/widgets/trailing_cluster.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/receipt_pdf.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/providers/subscriptions_providers.dart';

/// Payment review — the most important journey in the app.
///
/// The screen commits to a single dominant action, makes the financial
/// consequence explicit before anything is charged, and only offers the
/// receipt/share step after the payment is recorded.
class PaymentReviewScreen extends ConsumerWidget {
  const PaymentReviewScreen({super.key, this.subscriberId});

  final String? subscriberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = subscriberId ?? _firstOverdueSubscriberId(ref);

    if (resolved == null) {
      return AppScaffold(
        title: 'Collect payment',
        subtitle: 'Nothing to settle',
        body: EmptyView(
          title: 'Nothing to collect',
          message: 'There are no due or overdue obligations right now.',
          icon: Icons.task_alt_rounded,
          tone: AppColors.success,
        ),
      );
    }

    final subscriber = ref.watch(subscriberDetailProvider(resolved));
    final name = subscriber.maybeWhen(data: (s) => s?.name, orElse: () => null);

    return AppScaffold(
      title: 'Collect payment',
      subtitle: name ?? 'Loading subscriber…',
      body: _ReviewBody(subscriberId: resolved),
    );
  }

  String? _firstOverdueSubscriberId(WidgetRef ref) {
    final obligations = ref.watch(billingObligationsProvider);
    return obligations.maybeWhen(
      data: (page) {
        if (page.items.isEmpty) return null;
        final overdue = page.items.where((o) => o.status == 'overdue');
        return overdue.isEmpty
            ? page.items.first.subscriberId
            : overdue.first.subscriberId;
      },
      orElse: () => null,
    );
  }
}

class _ReviewBody extends ConsumerStatefulWidget {
  const _ReviewBody({required this.subscriberId});

  final String subscriberId;

  @override
  ConsumerState<_ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends ConsumerState<_ReviewBody> {
  /// One key per logical payment. Retrying the same confirmation reuses it, so
  /// a double tap can never record two payments.
  late final String _idempotencyKey =
      'idem_${DateTime.now().microsecondsSinceEpoch}';

  final Set<String> _selection = {};
  bool _selectionInitialised = false;
  bool _adjusting = false;
  bool _submitting = false;
  bool _retrying = false;
  Payment? _committed;

  final _billed = TextEditingController();
  String? _billedError;

  @override
  void dispose() {
    _billed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(
      subscriptionsListProvider(widget.subscriberId),
    );
    final services = ref.watch(servicesListProvider);

    return subscriptions.when(
      data: (page) {
        final active = page.items
            .where((s) => !s.cancelled && s.status == 'active')
            .toList();

        String serviceName(String id) => services.maybeWhen(
          data: (sp) {
            final m = sp.items.where((x) => x.id == id);
            return m.isEmpty ? id : m.first.name;
          },
          orElse: () => id,
        );

        if (!_selectionInitialised && active.isNotEmpty) {
          final due = active.where(
            (s) =>
                BizDate.daysBetween(BizDate.todayYMD(), s.nextPaymentDate) <= 7,
          );
          _selection.addAll((due.isEmpty ? active : due).map((s) => s.id));
          _selectionInitialised = true;
        }

        final selected = active
            .where((s) => _selection.contains(s.id))
            .toList();
        final calculated = MoneyUtils.sum(selected.map((s) => s.price));

        Decimal billed;
        if (_adjusting) {
          try {
            billed = MoneyUtils.parseDecimal(_billed.text.trim());
          } catch (_) {
            billed = calculated;
          }
        } else {
          billed = calculated;
        }

        final items = selected
            .map(
              (s) => PaymentItem(
                subscriptionId: s.id,
                serviceName: serviceName(s.serviceId),
                amount: s.price,
                dueDate: s.nextPaymentDate,
              ),
            )
            .toList();

        if (_committed != null) {
          return _SuccessView(
            payment: _committed!,
            onDone: () => context.go('/billing'),
            onShare: () => shareReceipt(_committed!),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _TotalHero(amount: billed, count: selected.length),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Settling',
                    subtitle: 'Untick anything you are not collecting today',
                    count: selected.length,
                  ),
                  if (active.isEmpty)
                    const InlineError(
                      message: 'This subscriber has no active subscriptions to collect.',
                    )
                  else
                    SurfaceSection(
                      children: [
                        for (var i = 0; i < active.length; i++)
                          Builder(
                            builder: (context) {
                              final sub = active[i];
                              final overdue = BizDate.isBefore(
                                sub.nextPaymentDate,
                                BizDate.todayYMD(),
                              );
                              final selected = _selection.contains(sub.id);
                              return SurfaceRow(
                                title: serviceName(sub.serviceId),
                                subtitle: overdue
                                    ? 'Overdue since ${BizDate.prettyYMD(sub.nextPaymentDate)}'
                                    : 'Due ${BizDate.prettyYMD(sub.nextPaymentDate)}',
                                selected: selected,
                                showChevron: false,
                                onTap: () => setState(() {
                                  if (selected) {
                                    _selection.remove(sub.id);
                                  } else {
                                    _selection.add(sub.id);
                                  }
                                }),
                                trailing: MoneyText(
                                  sub.price,
                                  style: AppType.money,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  SurfaceSection(
                    children: [
                      SurfaceRow(
                        title: 'Calculated amount',
                        subtitle: MoneyUtils.formatPKR(calculated),
                        showChevron: false,
                      ),
                      if (_adjusting)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Gap.gutter,
                            6,
                            Gap.gutter,
                            6,
                          ),
                          child: TextField(
                            controller: _billed,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Billed amount (PKR)',
                              helperText: 'Override the calculated amount if you agreed a different figure',
                              errorText: _billedError,
                              prefixIcon: const Icon(Icons.edit_outlined),
                            ),
                            onChanged: (v) {
                              setState(() {
                                final raw = v.trim();
                                if (raw.isEmpty) {
                                  _billedError = null;
                                  return;
                                }
                                try {
                                  final parsed = MoneyUtils.parseDecimal(raw);
                                  _billedError = parsed < Decimal.zero
                                      ? 'Amount cannot be negative'
                                      : null;
                                } catch (_) {
                                  _billedError = 'Enter a number, for example 3500 or 3500.50';
                                }
                              });
                            },
                          ),
                        )
                      else
                        SurfaceRow(
                          title: 'Billed amount',
                          subtitle: MoneyUtils.formatPKR(billed),
                          showChevron: false,
                        ),
                      SurfaceRow(
                        title: _adjusting
                            ? 'Use calculated amount'
                            : 'Adjust billed amount',
                        subtitle: _adjusting
                            ? 'Revert to the calculated total'
                            : 'Set a different billed figure',
                        showChevron: false,
                        onTap: () => setState(() {
                          _adjusting = !_adjusting;
                          if (!_adjusting) {
                            _billed.clear();
                            _billedError = null;
                          } else {
                            _billed.text = MoneyUtils.formatDecimal(calculated);
                          }
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _retrying
                              ? 'Retrying the same payment — the original reference is reused.'
                              : 'Confirmed payments cannot be edited. A receipt is created for each one.',
                          style: AppType.overline.copyWith(letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _PinnedBar(
              total: billed,
              enabled:
                  selected.isNotEmpty && _billedError == null && !_submitting,
              busy: _submitting,
              onConfirm: () => _confirm(items, calculated, billed),
            ),
          ],
        );
      },
      loading: () => LoadingView(rows: 4, withStats: true),
      error: (e, _) => ErrorView(
        message: 'We could not load this subscriber’s obligations.',
        onRetry: () {
          ref.invalidate(subscriptionsListProvider(widget.subscriberId));
          ref.invalidate(servicesListProvider);
        },
      ),
    );
  }

  Future<void> _confirm(
    List<PaymentItem> items,
    Decimal calculated,
    Decimal billed,
  ) async {
    if (items.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _submitting = true;
      _retrying = _committed == null;
    });
    try {
      final payment = await ref
          .read(paymentsRepositoryProvider)
          .createPayment(
            subscriberId: widget.subscriberId,
            items: items,
            calculatedAmount: calculated,
            billedAmount: billed,
            idempotencyKey: _idempotencyKey,
          );

      // Move each settled subscription's schedule forward so the obligation
      // genuinely clears. One-off services are completed instead.
      final repo = ref.read(subscriptionsRepositoryProvider);
      for (final item in items) {
        final sub = ref
            .read(subscriptionsListProvider(widget.subscriberId))
            .maybeWhen(
              data: (p) =>
                  p.items.where((s) => s.id == item.subscriptionId).firstOrNull,
              orElse: () => null,
            );
        if (sub == null) continue;
        final months = BizDate.monthsForPeriod(sub.billingPeriod);
        if (months == null) {
          await repo.cancelSubscription(sub.id, endedOn: BizDate.todayYMD());
        } else {
          await repo.changeNextPaymentDate(
            sub.id,
            BizDate.addMonths(sub.nextPaymentDate, months),
          );
        }
      }

      ref.invalidate(paymentsListProvider);
      ref.invalidate(subscriptionsListProvider);
      ref.invalidate(billingObligationsProvider);

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() {
        _submitting = false;
        _committed = payment;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showAppSnack(
        context,
        message: 'The payment was not recorded. Nothing was charged — please try again.',
        error: true,
        actionLabel: 'Retry',
        onAction: () => _confirm(items, calculated, billed),
      );
    }
  }
}

class _TotalHero extends StatelessWidget {
  const _TotalHero({required this.amount, required this.count});

  final Decimal amount;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'You will collect ${MoneyUtils.formatPKR(amount)} for $count subscriptions',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.rMd,
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You will collect', style: AppType.caption),
            const SizedBox(height: 4),
            Text(
              MoneyUtils.formatPKR(amount),
              style: AppType.moneyHero,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Across $count ${count == 1 ? 'subscription' : 'subscriptions'} · nothing is charged until you confirm',
              style: AppType.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedBar extends StatelessWidget {
  const _PinnedBar({
    required this.total,
    required this.enabled,
    required this.busy,
    required this.onConfirm,
  });

  final Decimal total;
  final bool enabled;
  final bool busy;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final amount = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The figure being approved is never allowed to show as "PKR 3,5…":
        // it scales down instead of being ellipsised.
        FitWidth(
          child: MoneyText(
            total,
            style: AppType.moneyLarge.copyWith(fontSize: 21),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Fixed once confirmed',
          style: AppType.overline.copyWith(letterSpacing: 0.2),
        ),
      ],
    );

    final confirm = SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: enabled && !busy ? onConfirm : null,
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Confirm payment'),
      ),
    );

    return BottomActionBar(
      note: 'Final total · PKR',
      // On a narrow phone the amount and the button must not compete for the
      // same line: the amount is the thing being approved, so it keeps the full
      // width and the button moves under it.
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 300) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [amount, const SizedBox(height: 12), confirm],
            );
          }
          return Row(
            children: [
              Expanded(child: amount),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 176, minWidth: 132),
                child: confirm,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.payment,
    required this.onDone,
    required this.onShare,
  });

  final Payment payment;
  final VoidCallback onDone;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Semantics(
          liveRegion: true,
          label:
              'Payment recorded. ${MoneyUtils.formatPKR(payment.finalAmount)} collected from ${payment.subscriberName}',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.rMd,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: reduced ? Duration.zero : AppMotion.slow,
                  curve: AppMotion.overshoot,
                  builder: (context, t, child) =>
                      Transform.scale(scale: t, child: child),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Payment recorded',
                  style: AppType.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  MoneyUtils.formatPKR(payment.finalAmount),
                  style: AppType.moneyHero,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Receipt ${payment.receiptId ?? payment.id} · ${payment.items.length} ${payment.items.length == 1 ? 'item' : 'items'}',
                  style: AppType.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SizedBox(height: 16),
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Receipt number',
              subtitle: payment.receiptId ?? '—',
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Payment ID',
              subtitle: payment.id,
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Calculated',
              subtitle: MoneyUtils.formatPKR(payment.calculatedAmount),
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Billed',
              subtitle: MoneyUtils.formatPKR(payment.billedAmount),
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Date',
              subtitle: BizDate.prettyYMD(payment.paymentDate),
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share receipt'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(onPressed: onDone, child: const Text('Done')),
        ),
      ],
    );
  }
}
