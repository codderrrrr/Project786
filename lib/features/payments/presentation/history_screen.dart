import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/core/components/surface_card.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';

/// History screen showing payment history with date filtering.
/// - Filter on top: date [Start date] [End date]
/// - Default: this month's 1st to current date
/// - Below: list of all payments made in ascending order (by default)
/// - Button to toggle between ascending and descending order
/// - Filter previous month to set filter to 1st to last date of previous month
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _startDate = '';
  String _endDate = '';
  bool _showAscending = true;
  String _currentFilter =
      'this_month'; // 'this_month', 'previous_month', 'custom'

  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _initDateRange();
    _startController = TextEditingController(text: _startDate);
    _endController = TextEditingController(text: _endDate);
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  /// Applies a date range to both the filter state and the visible fields.
  void _applyRange(String start, String end, String filter) {
    setState(() {
      _currentFilter = filter;
      _startDate = start;
      _endDate = end;
      _startController.text = start;
      _endController.text = end;
    });
  }

  void _initDateRange() {
    final now = BizDate.todayYMD();
    final monthStart =
        '${now.substring(0, 7)}-01'; // First day of current month

    _startDate = monthStart;
    _endDate = now;
  }

  int _getMonthLastDay(int year, int month) {
    final monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && _isLeapYear(year)) return 29;
    return monthDays[month - 1];
  }

  bool _isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  List<Payment> _filterByDate(List<Payment> allPayments) {
    if (_currentFilter == 'this_month') {
      final now = BizDate.todayYMD();
      final monthStart = '${now.substring(0, 7)}-01';
      return allPayments.where((p) {
        final datePart = p.paymentDate.split('T').first;
        return datePart.compareTo(monthStart) >= 0 &&
            datePart.compareTo(now) <= 0;
      }).toList();
    } else if (_currentFilter == 'previous_month') {
      final now = BizDate.todayYMD();
      final monthParts = now.split('-');
      final year = int.parse(monthParts[0]);
      final month = int.parse(monthParts[1]);
      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevMonthEndDay = _getMonthLastDay(prevYear, prevMonth);
      final prevMonthStart =
          '$prevYear-${prevMonth.toString().padLeft(2, '0')}-01';
      final prevMonthEnd =
          '$prevYear-${prevMonth.toString().padLeft(2, '0')}-$prevMonthEndDay';

      return allPayments.where((p) {
        final datePart = p.paymentDate.split('T').first;
        return datePart.compareTo(prevMonthStart) >= 0 &&
            datePart.compareTo(prevMonthEnd) <= 0;
      }).toList();
    } else {
      // Custom range
      return allPayments.where((p) {
        final datePart = p.paymentDate.split('T').first;
        return datePart.compareTo(_startDate) >= 0 &&
            datePart.compareTo(_endDate) <= 0;
      }).toList();
    }
  }

  List<Payment> _sortPayments(List<Payment> payments) {
    if (_showAscending) {
      return List.of(payments)
        ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    } else {
      return List.of(payments)
        ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentsState = ref.watch(paymentsListProvider(null));
    if (paymentsState.isLoading) {
      return AppScaffold(
        title: 'Payment History',
        showBack: false,
        body: const LoadingView(rows: 5),
      );
    }
    if (paymentsState.hasError) {
      return AppScaffold(
        title: 'Payment History',
        showBack: false,
        body: ErrorView(
          message: 'We could not load payment history. Check your connection and try again.',
          onRetry: () => ref.invalidate(paymentsListProvider(null)),
        ),
      );
    }
    final allPayments = paymentsState.value?.items ?? const <Payment>[];
    final filtered = _filterByDate(allPayments);
    final sorted = _sortPayments(filtered);

    return AppScaffold(
      title: 'Payment History',
      showBack: false,
      actions: [
        // Previous month filter button
        TextButton(
          onPressed: () {
            final now = BizDate.todayYMD();
            final parts = now.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final prevMonth = month == 1 ? 12 : month - 1;
            final prevYear = month == 1 ? year - 1 : year;
            final endDay = _getMonthLastDay(prevYear, prevMonth);
            final mm = prevMonth.toString().padLeft(2, '0');
            _applyRange(
              '$prevYear-$mm-01',
              '$prevYear-$mm-$endDay',
              'previous_month',
            );
          },
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          child: const Text('Prev month'),
        ),
      ],
      bodyPadding: EdgeInsets.zero,
      body: Column(
        children: [
          // Date filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Gap.gutter,
              Gap.gutter,
              Gap.gutter,
              8,
            ),
            child: SurfaceCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Start date
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(_startDate) ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) {
                          final s = d.toIso8601String().split('T').first;
                          _applyRange(s, _endDate, 'custom');
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startController.text.isEmpty
                              ? 'YYYY-MM-DD'
                              : _startController.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // End date
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(_endDate) ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) {
                          final s = d.toIso8601String().split('T').first;
                          _applyRange(_startDate, s, 'custom');
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endController.text.isEmpty
                              ? 'YYYY-MM-DD'
                              : _endController.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sort direction button
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, 4),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    _showAscending
                        ? 'Showing oldest first'
                        : 'Showing newest first',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.caption,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    setState(() => _showAscending = !_showAscending);
                  },
                  child: Text(_showAscending ? 'Descending' : 'Ascending'),
                ),
              ],
            ),
          ),

          // Payment list
          Expanded(
            child: sorted.isEmpty
                ? const Center(child: Text('No payments found'))
                : ListView(
                    padding: Gap.pageInset,
                    children: [
                      for (var i = 0; i < sorted.length; i++)
                        _PaymentRow(payment: sorted[i]),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A single payment row showing payment details.
class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = payment.paymentDate.isNotEmpty
        ? BizDate.dayName(payment.paymentDate)
        : '';

    return SurfaceRow(
      title: payment.items.isNotEmpty
          ? payment.items.first.serviceName
          : 'Payment',
      subtitle: '${MoneyUtils.formatPKR(payment.finalAmount)} ($date)',
      showChevron: true,
      onTap: () => context.push('/payments/${payment.id}'),
    );
  }
}
