import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/money_text.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';

class ServiceDetailScreen extends ConsumerWidget {
  const ServiceDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(serviceDetailProvider(id));

    return AppScaffold(
      title: 'Service',
      body: service.when(
        data: (s) {
          if (s == null) {
            return const ErrorView(
              title: 'Service not found',
              message: 'This service may have been removed.',
            );
          }
          final period = switch (s.billingPeriod) {
            'one_time' => 'One-off',
            'daily' => 'Daily',
            'weekly' => 'Weekly',
            'fifteen_days' => '15 days',
            'monthly' => 'Monthly',
            'three_months' => '3 months',
            'six_months' => '6 months',
            'yearly' => '12 months',
            _ => s.billingPeriod,
          };
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.rMd,
                  border: Border.all(color: AppColors.outlineSoft),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(s.name, style: AppType.title)),
                        StatusPill.fromStatus(s.active ? 'active' : 'inactive'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MoneyText(s.price, style: AppType.moneyHero),
                    const SizedBox(height: 2),
                    Text('per $period', style: AppType.caption),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Details'),
              SurfaceSection(
                children: [
                  SurfaceRow(
                    title: 'Billing period',
                    subtitle: '$period · fixed after creation',
                    showChevron: false,
                  ),
                  SurfaceRow(
                    title: 'Description',
                    subtitle: s.description.isEmpty ? 'None' : s.description,
                    showChevron: false,
                  ),
                  SurfaceRow(
                    title: 'Status',
                    subtitle: s.active ? 'Active' : 'Inactive',
                    showChevron: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Actions'),
              SurfaceSection(
                children: [
                  SurfaceRow(
                    title: s.active ? 'Deactivate service' : 'Activate service',
                    subtitle: 'Deactivating stops new subscriptions; existing ones keep price and history.',
                    showChevron: false,
                    onTap: () async {
                      if (s.active) {
                        final ok = await showConfirmDialog(
                          context,
                          title: 'Deactivate ${s.name}?',
                          message: 'It will no longer be available for new subscriptions.',
                          consequence: 'Running subscriptions and all past payments are preserved.',
                          confirmLabel: 'Deactivate',
                          destructive: true,
                        );
                        if (!ok) return;
                      }
                      await ref
                          .read(servicesRepositoryProvider)
                          .setServiceActive(s.id, !s.active);
                      ref.invalidate(servicesListProvider);
                      ref.invalidate(serviceDetailProvider(s.id));
                      if (context.mounted) {
                        showAppSnack(
                          context,
                          message: s.active
                              ? '${s.name} deactivated.'
                              : '${s.name} activated.',
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => LoadingView(rows: 3),
        error: (e, _) => ErrorView(
          message: 'We could not load this service.',
          onRetry: () => ref.invalidate(serviceDetailProvider(id)),
        ),
      ),
    );
  }
}
