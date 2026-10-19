import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/core/widgets/animated_reveal.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/filter_pills.dart';
import 'package:subscription_saas_flutter/core/widgets/initials_avatar.dart';
import 'package:subscription_saas_flutter/core/widgets/money_text.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/providers/subscriptions_providers.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final subs = ref.watch(subscriptionsListProvider(null));
    final services = ref.watch(servicesListProvider);
    final subscribers = ref.watch(subscribersListProvider(null));

    String serviceName(String id) => services.maybeWhen(
          data: (p) {
            final m = p.items.where((x) => x.id == id);
            return m.isEmpty ? id : m.first.name;
          },
          orElse: () => id,
        );

    String subscriberName(String id) => subscribers.maybeWhen(
          data: (p) {
            final m = p.items.where((x) => x.id == id);
            return m.isEmpty ? id : m.first.name;
          },
          orElse: () => id,
        );

    return AppScaffold(
      title: 'Subscriptions',
      subtitle: 'Recurring arrangements',
      actions: [
        IconButton(
          tooltip: 'New subscription',
          onPressed: () => showAppSnack(
            context,
            message: 'Creating subscriptions will be enabled once the service and subscriber pickers are wired to the API.',
          ),
          icon: const Icon(Icons.add_rounded, size: 22),
        ),
      ],
      bodyPadding: EdgeInsets.zero,
      pinnedHeader: subs.maybeWhen(
        data: (page) {
          final active = page.items.where((s) => !s.cancelled && s.status == 'active').length;
          final cancelled = page.items.where((s) => s.cancelled).length;
          return Padding(
            padding: const EdgeInsets.fromLTRB(Gap.gutter, 0, Gap.gutter, 12),
            child: FilterPills(
              selectedId: _filter,
              semanticLabel: 'Filter subscriptions by state',
              onSelected: (id) => setState(() => _filter = id),
              options: [
                FilterOption(id: 'all', label: 'All', count: page.items.length),
                FilterOption(id: 'active', label: 'Active', count: active),
                FilterOption(id: 'cancelled', label: 'Cancelled', count: cancelled),
              ],
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
      body: subs.when(
        data: (page) {
          final items = page.items.where((s) {
            switch (_filter) {
              case 'active':
                return !s.cancelled && s.status == 'active';
              case 'cancelled':
                return s.cancelled;
              default:
                return true;
            }
          }).toList();

          if (items.isEmpty) {
            return EmptyView(
              title: 'No subscriptions',
              message: 'Attach a service to a subscriber to start billing them on a schedule.',
              icon: Icons.autorenew_rounded,
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              SectionHeader(
                title: 'All subscriptions',
                count: items.length,
                subtitle: 'Service, next payment date and amount',
              ),
              SurfaceSection(
                children: [
                  for (var i = 0; i < items.length; i++)
                    AnimatedReveal(
                      index: i,
                      child: Builder(
                        builder: (context) {
                          final s = items[i];
                          final name = subscriberName(s.subscriberId);
                          return SurfaceRow(
                            title: name,
                            subtitle:
                                '${serviceName(s.serviceId)} · next ${BizDate.prettyYMD(s.nextPaymentDate)}',
                            leading: InitialsAvatar(name: name, size: 34, dimmed: s.cancelled),
                            showChevron: false,
                            onTap: () => context.push('/subscriptions/${s.id}'),
                            semanticLabel:
                                '$name, ${serviceName(s.serviceId)}, ${MoneyUtils.formatPKR(s.price)}, next payment ${BizDate.prettyYMD(s.nextPaymentDate)}, ${s.status}',
                            semanticHint: 'Opens subscription details',
                            trailing: RowValue(
                              value: MoneyText(s.price, style: AppType.money),
                              note: s.cancelled ? 'Cancelled' : (s.status == 'active' ? 'Active' : s.status),
                              noteTone: s.cancelled
                                  ? AppColors.textTertiary
                                  : s.status == 'active'
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => LoadingView(rows: 5),
        error: (e, _) => ErrorView(
          message: 'We could not load subscriptions.',
          onRetry: () => ref.invalidate(subscriptionsListProvider),
        ),
      ),
    );
  }
}
