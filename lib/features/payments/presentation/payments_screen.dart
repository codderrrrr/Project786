import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/money_text.dart';
import 'package:subscription_saas_flutter/core/widgets/more_menu.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/receipt_pdf.dart';

/// Payment history: a read-only ledger. The total sits in a single summary
/// line, then every record as an aligned row — name, date, amount — with the
/// receipt available by swipe.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  late DateTime _start;
  late DateTime _end;
  bool _descending = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Open on the trailing two months: demo data (and recent real payments)
    // sit in the previous month, and a current-month-only default renders an
    // always-empty ledger on first open.
    _start = DateTime(now.year, now.month - 1, 1);
    _end = now;
  }

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentsListProvider(null));

    return AppScaffold(
      title: 'Payments',
      subtitle: 'Read-only history',
      showBack: false,
      actions: [MoreButton(initials: 'DB')],
      bodyPadding: EdgeInsets.zero,
      pinnedHeader: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickDate(true),
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text('From ${_shortDate(_start)}'),
            ),
            OutlinedButton(
              onPressed: () => _pickDate(false),
              child: Text('To ${_shortDate(_end)}'),
            ),
            TextButton(
              onPressed: _previousMonth,
              child: const Text('Previous month'),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _descending = !_descending),
              icon: Icon(
                _descending ? Icons.south_rounded : Icons.north_rounded,
                size: 16,
              ),
              label: Text(_descending ? 'Newest first' : 'Oldest first'),
            ),
          ],
        ),
      ),
      body: payments.when(
        data: (page) {
          final filtered =
              page.items.where((payment) {
                final date = DateTime.tryParse(payment.paymentDate);
                return date != null &&
                    !date.isBefore(_start) &&
                    !date.isAfter(_end);
              }).toList()..sort(
                (a, b) => _descending
                    ? b.paymentDate.compareTo(a.paymentDate)
                    : a.paymentDate.compareTo(b.paymentDate),
              );
          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.gutter),
              child: EmptyView(
                title: 'No payments yet',
                message: 'Record a payment from Billing or the quick actions button and it will appear here with its receipt.',
                icon: Icons.receipt_long_outlined,
                actionLabel: 'Collect a payment',
                onAction: () => context.push('/payments/review'),
              ),
            );
          }
          final total = MoneyUtils.sum(filtered.map((p) => p.finalAmount));
          final months = _byMonth(filtered);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(paymentsListProvider(null)),
            child: ListView(
              padding: Gap.pageInset,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _TotalLine(total: total, count: filtered.length),
                const SizedBox(height: 24),
                for (final month in months) ...[
                  SectionHeader(
                    title: month.label,
                    count: month.payments.length,
                    figure: MoneyUtils.formatCompactPKR(month.total),
                    subtitle: months.indexOf(month) == 0
                        ? 'Swipe a row to share its receipt'
                        : null,
                  ),
                  SurfaceSection(
                    children: [
                      for (final payment in month.payments)
                        _PaymentRow(payment: payment),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingView(rows: 5),
        error: (e, _) => ErrorView(
          message: 'Your payment history could not be loaded. Check your connection and try again.',
          onRetry: () => ref.invalidate(paymentsListProvider),
        ),
      ),
    );
  }

  String _shortDate(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';

  Future<void> _pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: start ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _previousMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month - 1);
    setState(() {
      _start = first;
      _end = DateTime(now.year, now.month, 0);
    });
  }

  /// Groups the ledger by calendar month, newest first, so "how much did I
  /// collect in September?" is answered by reading the list rather than
  /// tapping through records.
  List<_MonthLedger> _byMonth(List<Payment> payments) {
    final ordered = [...payments]
      ..sort(
        (a, b) => _descending
            ? b.paymentDate.compareTo(a.paymentDate)
            : a.paymentDate.compareTo(b.paymentDate),
      );
    final buckets = <String, List<Payment>>{};
    for (final p in ordered) {
      final key = p.paymentDate.substring(0, 7); // YYYY-MM
      buckets.putIfAbsent(key, () => []).add(p);
    }
    return buckets.entries.map((entry) {
      return _MonthLedger(
        key: entry.key,
        label: BizDate.monthLabel(entry.key),
        payments: entry.value,
        total: MoneyUtils.sum(entry.value.map((p) => p.finalAmount)),
      );
    }).toList();
  }
}

class _MonthLedger {
  const _MonthLedger({
    required this.key,
    required this.label,
    required this.payments,
    required this.total,
  });

  final String key;
  final String label;
  final List<Payment> payments;
  final Decimal total;
}

/// One line, one number: the total recorded. Kept deliberately small — this is
/// history, not a headline the user acts on.
class _TotalLine extends StatelessWidget {
  const _TotalLine({required this.total, required this.count});

  final Decimal total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Recorded in history: ${MoneyUtils.formatPKR(total)} across $count ${count == 1 ? 'payment' : 'payments'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(Gap.gutter, 12, Gap.gutter, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.rMd,
          border: Border.all(color: AppColors.outlineSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recorded', style: AppType.caption),
                  const SizedBox(height: 2),
                  Text(
                    MoneyUtils.formatPKR(total),
                    style: AppType.moneyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '$count ${count == 1 ? 'payment' : 'payments'}',
              style: AppType.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('pay-${payment.id}'),
      background: Container(
        color: AppColors.surfaceAlt,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: Gap.gutter),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ios_share_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Share receipt',
              style: AppType.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        await shareReceipt(payment);
        return false;
      },
      child: SurfaceRow(
        title: payment.subscriberName,
        subtitle:
            '${BizDate.prettyYMD(payment.paymentDate)} · ${payment.items.length} ${payment.items.length == 1 ? 'item' : 'items'}',
        showChevron: false,
        onTap: () => context.push('/payments/${payment.id}'),
        semanticLabel:
            '${payment.subscriberName}, ${MoneyUtils.formatPKR(payment.finalAmount)}, ${BizDate.prettyYMD(payment.paymentDate)}, ${payment.items.length} items',
        semanticHint: 'Opens the payment record',
        trailing: RowValue(
          // Shared with the detail screen's headline amount so the value
          // visibly flies across instead of teleporting.
          value: Hero(
            tag: 'payment-amount-${payment.id}',
            child: MoneyText(payment.finalAmount, style: AppType.money),
          ),
          note: 'Paid',
          noteTone: AppColors.success,
        ),
      ),
    );
  }
}
