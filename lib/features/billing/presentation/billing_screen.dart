import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/filter_bar.dart';
import 'package:subscription_saas_flutter/core/widgets/search_field.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/section_header_artistic.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/aurora_card.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/minimal_card.dart';
import 'package:subscription_saas_flutter/core/widgets/creative/gradient_chip.dart';
import 'package:subscription_saas_flutter/features/billing/data/providers/billing_providers.dart';
import 'package:subscription_saas_flutter/features/billing/domain/models/obligation.dart';

/// Billing: simple UI with search bar and 3 filters on top.
/// The UI consists of a search bar and enlist the billing with 3 filters on the top
/// and headings i.e. overdue, due today, upcoming (and 4th filter is all where all 3 are shown).
/// - Searchbar will search a person.
/// - Overdue contain one week prior to today.
/// - Due today contain due today
/// - Upcoming contain one week after today.
class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String _query = '';
  String _filter = 'all'; // 'all', 'overdue', 'today', 'upcoming'

  bool _matchesQuery(Obligation obligation, String query) {
    if (query.trim().isEmpty) return true;
    final needle = query.trim().toLowerCase();
    return obligation.subscriberName.toLowerCase().contains(needle) ||
        obligation.serviceNames.any((service) => service.toLowerCase().contains(needle));
  }

  @override
  Widget build(BuildContext context) {
    final obligations = ref.watch(billingObligationsProvider);

    return AppScaffold(
      title: 'Billing',
      subtitle: obligations.maybeWhen(
        data: (page) {
          final total = MoneyUtils.sum(page.items.map((o) => o.amountDue));
          final overdue = page.items.where((o) => o.status == 'overdue').length;
          if (page.items.isEmpty) return 'Nothing outstanding';
          return '${MoneyUtils.formatPKR(total)} outstanding · '
              '$overdue ${overdue == 1 ? 'record' : 'records'} overdue';
        },
        orElse: () => 'Due and overdue obligations',
      ),
      showBack: false,
      actions: [
        // Floating search icon action - could be used for search reset
      ],
      bodyPadding: EdgeInsets.zero,
      body: obligations.when(
        data: (page) {
          // Compute filter groups per review definitions:
          // - Overdue: one week prior to today
          // - Due today: due today
          // - Upcoming: one week after today
          final overdueItems = page.items
              .where((o) => o.status == 'overdue')
              .toList()
            ..sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
          final dueTodayItems = page.items
              .where((o) =>
                  o.status != 'overdue' && o.daysDue == 0)
              .toList();
          final upcomingItems = page.items
              .where((o) =>
                  o.status != 'overdue' &&
                  o.daysDue > 0 &&
                  o.daysDue <= 7)
              .toList();
          final allItems = List.of(page.items);

          // Apply search filter
          final filteredItems = _query.isNotEmpty
              ? allItems
                  .where((o) =>
                      o.subscriberName
                          .toLowerCase()
                          .contains(_query.toLowerCase()))
              .toList()
              : allItems;

          final visibleOverdueItems = overdueItems
              .where((o) => _matchesQuery(o, _query))
              .toList();
          final visibleDueTodayItems = dueTodayItems
              .where((o) => _matchesQuery(o, _query))
              .toList();
          final visibleUpcomingItems = upcomingItems
              .where((o) => _matchesQuery(o, _query))
              .toList();

          // Apply filter selection
          final filtered = _filter == 'all'
              ? filteredItems
              : _filter == 'overdue'
                  ? visibleOverdueItems
                  : _filter == 'today'
                      ? visibleDueTodayItems
                      : visibleUpcomingItems;

          // Compute group headings
          final overdueCount = visibleOverdueItems.length;
          final todayCount = visibleDueTodayItems.length;
          final upcomingCount = visibleUpcomingItems.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.gutter, Gap.gutter, Gap.gutter, 8),
                child: MinimalCard(
                  padding: const EdgeInsets.all(8),
                  child: AppSearchField(
                    hintText: 'Search name or phone number',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              // Filter bar with 3 filters + All
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, 4),
                child: AuroraCard(
                  padding: const EdgeInsets.all(8),
                  glow: true,
                  child: FilterBar(
                    selectedId: _filter,
                    semanticLabel: 'Filter obligations by urgency',
                    onSelected: (id) => setState(() => _filter = id),
                    onReset: () => setState(() => _filter = 'all'),
                    summary: Text(
                      '${filtered.length} ${filtered.length == 1 ? 'record' : 'records'}',
                    ),
                    options: [
                      FilterOption(id: 'all', label: 'All', count: allItems.length),
                      FilterOption(
                        id: 'overdue',
                        label: 'Overdue ($overdueCount)',
                        count: overdueCount,
                      ),
                      FilterOption(
                        id: 'today',
                        label: 'Due today ($todayCount)',
                        count: todayCount,
                      ),
                      FilterOption(
                        id: 'upcoming',
                        label: 'Upcoming ($upcomingCount)',
                        count: upcomingCount,
                      ),
                    ],
                  ),
                ),
              ),

              // Body with grouped lists
              Expanded(
                child: ListView(
                  padding: Gap.pageInset,
                  children: [
                    // Overdue section
                    if (visibleOverdueItems.isNotEmpty && (_filter == 'all' || _filter == 'overdue')) ...[
                      SectionHeaderArtistic(
                        title: 'Overdue',
                        subtitle: 'One week prior to today',
                      ),
                      SurfaceSection(
                        children: [
                          for (final o in visibleOverdueItems)
                            _ObligationRow(
                              obligation: o,
                              onCollect: () => context.push(
                                '/payments/review?obligationId=${o.id}',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Due today section
                    if (visibleDueTodayItems.isNotEmpty &&
                        (_filter == 'all' || _filter == 'today')) ...[
                      SectionHeaderArtistic(
                        title: 'Due today',
                        subtitle: 'Due today',
                      ),
                      SurfaceSection(
                        children: [
                          for (final o in visibleDueTodayItems)
                            _ObligationRow(
                              obligation: o,
                              onCollect: () => context.push(
                                '/payments/review?obligationId=${o.id}',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Upcoming section
                    if (visibleUpcomingItems.isNotEmpty &&
                        (_filter == 'all' || _filter == 'upcoming')) ...[
                      SectionHeaderArtistic(
                        title: 'Upcoming',
                        subtitle: 'One week after today',
                      ),
                      SurfaceSection(
                        children: [
                          for (final o in visibleUpcomingItems)
                            _ObligationRow(
                              obligation: o,
                              onCollect: () => context.push(
                                '/payments/review?obligationId=${o.id}',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (filtered.isEmpty)
                      const EmptyView(
                        title: 'No billing matches',
                        message: 'Try another subscriber name or choose a different billing filter.',
                        icon: Icons.search_off_rounded,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(rows: 6),
        error: (e, _) => ErrorView(
          message: 'We could not load your billing. Check your connection and try again.',
          onRetry: () => ref.invalidate(billingObligationsProvider),
        ),
      ),
    );
  }
}

/// A row displaying a billing obligation with collect action.
class _ObligationRow extends ConsumerWidget {
  const _ObligationRow({
    required this.obligation,
    required this.onCollect,
  });

  final Obligation obligation;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = obligation.daysOverdue;
    final isOverdue = days > 0;

    return SurfaceRow(
      title: obligation.subscriberName,
      subtitle: '${MoneyUtils.formatPKR(obligation.amountDue)} '
          '${isOverdue ? '($days days overdue)' : 'due ${obligation.daysDue} days'}',
      showChevron: true,
      onTap: onCollect,
    );
  }
}
