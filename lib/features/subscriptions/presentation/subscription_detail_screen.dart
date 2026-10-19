import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/money_text.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/billing/data/providers/billing_providers.dart';
import 'package:subscription_saas_flutter/features/services/data/providers/services_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/providers/subscriptions_providers.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  const SubscriptionDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionDetailProvider(id));

    return AppScaffold(
      title: 'Subscription',
      subtitle: 'Schedule and state',
      body: sub.when(
        data: (s) {
          if (s == null) {
            return const ErrorView(
              title: 'Subscription not found',
              message: 'This subscription may have been removed.',
            );
          }
          return _Body(subscription: s);
        },
        loading: () => LoadingView(rows: 4),
        error: (e, _) => ErrorView(
          message: 'We could not load this subscription.',
          onRetry: () => ref.invalidate(subscriptionDetailProvider(id)),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = subscription;
    final services = ref.watch(servicesListProvider);
    final subscribers = ref.watch(subscriberDetailProvider(s.subscriberId));

    final serviceName = services.maybeWhen(
      data: (p) {
        final m = p.items.where((x) => x.id == s.serviceId);
        return m.isEmpty ? s.serviceId : m.first.name;
      },
      orElse: () => s.serviceId,
    );
    final subscriberName = subscribers.maybeWhen(
      data: (sub) => sub?.name ?? s.subscriberId,
      orElse: () => s.subscriberId,
    );
    final period = switch (s.billingPeriod) {
      'one_time' => 'One-off',
      'monthly' => 'Monthly',
      'quarterly' => 'Quarterly',
      'yearly' => 'Yearly',
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
                  Expanded(child: Text(serviceName, style: AppType.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  StatusPill.fromStatus(s.cancelled ? 'cancelled' : s.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(subscriberName, style: AppType.caption),
              const SizedBox(height: 10),
              MoneyText(s.price, style: AppType.moneyHero),
              const SizedBox(height: 2),
              Text('per $period', style: AppType.caption),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(
          title: 'Editable',
          subtitle: 'You can change these at any time',
        ),
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Next payment',
              subtitle: BizDate.prettyYMD(s.nextPaymentDate),
              showChevron: false,
              trailing: TextButton(
                onPressed: s.cancelled ? null : () => _changeNextDate(context, ref),
                child: const Text('Change'),
              ),
            ),
            SurfaceRow(
              title: 'Billing period',
              subtitle: '$period · locks once payments exist',
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(
          title: 'Fixed',
          subtitle: 'Set when the subscription was created',
        ),
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Subscription ID',
              subtitle: s.id,
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Subscriber ID',
              subtitle: s.subscriberId,
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Service ID',
              subtitle: s.serviceId,
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Started',
              subtitle: BizDate.prettyYMD(s.startDate),
              showChevron: false,
            ),
            if (s.endDate != null)
              SurfaceRow(
                title: 'Ended',
                subtitle: BizDate.prettyYMD(s.endDate!),
                showChevron: false,
              ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Actions'),
        SurfaceSection(
          children: [
            if (s.cancelled)
              SurfaceRow(
                title: 'Restart subscription',
                subtitle:
                    'Cancelled on ${s.endDate == null ? 'an earlier date' : BizDate.prettyYMD(s.endDate!)}. Past payments and receipts remain available.',
                showChevron: false,
                onTap: () => _cancel(context, ref),
                trailing: const Icon(Icons.play_circle_outline_rounded, size: 18),
              )
            else
              SurfaceRow(
                title: 'Cancel subscription',
                subtitle:
                    'Cancelling stops future obligations. Payments already collected and their receipts remain.',
                showChevron: false,
                onTap: () => _cancel(context, ref),
                trailing: Icon(Icons.block_rounded, size: 18, color: AppColors.danger),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _changeNextDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(subscription.nextPaymentDate) ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select the next payment date',
      fieldLabelText: 'Next payment date',
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null || !context.mounted) return;
    final ymd =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    await ref.read(subscriptionsRepositoryProvider).changeNextPaymentDate(subscription.id, ymd);
    ref.invalidate(subscriptionDetailProvider(subscription.id));
    ref.invalidate(subscriptionsListProvider);
    ref.invalidate(billingObligationsProvider);
    if (context.mounted) {
      showAppSnack(
        context,
        message: 'Next payment moved to ${BizDate.prettyYMD(ymd)}.',
        actionLabel: 'Undo',
        onAction: () async {
          await ref
              .read(subscriptionsRepositoryProvider)
              .changeNextPaymentDate(subscription.id, subscription.nextPaymentDate);
          ref.invalidate(subscriptionDetailProvider(subscription.id));
          ref.invalidate(subscriptionsListProvider);
        },
      );
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cancel this subscription?',
      message: 'No further obligations will be generated for it.',
      consequence: 'Collected payments and receipts stay available. This cannot be undone from the app yet.',
      confirmLabel: 'Cancel subscription',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    await ref.read(subscriptionsRepositoryProvider).cancelSubscription(
          subscription.id,
          endedOn: BizDate.todayYMD(),
        );
    ref.invalidate(subscriptionDetailProvider(subscription.id));
    ref.invalidate(subscriptionsListProvider);
    ref.invalidate(billingObligationsProvider);
    if (context.mounted) {
      showAppSnack(context, message: 'Subscription cancelled.');
    }
  }
}
