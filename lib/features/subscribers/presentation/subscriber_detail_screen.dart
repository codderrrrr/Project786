import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/initials_avatar.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/features/subscriptions/domain/models/subscription.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment_item.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/subscriptions/data/providers/subscriptions_providers.dart';
import 'package:subscription_saas_flutter/features/subscribers/data/providers/subscribers_providers.dart';

class SubscriberDetailScreen extends ConsumerWidget {
  const SubscriberDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriber = ref.watch(subscriberDetailProvider(id));

    return AppScaffold(
      title: 'Subscriber',
      actions: [
        IconButton(
          tooltip: 'Edit subscriber',
          onPressed: () => showAppSnack(
            context,
            message: 'Editing subscribers is not connected yet.',
          ),
          icon: const Icon(Icons.edit_outlined, size: 20),
        ),
      ],
      body: subscriber.when(
        data: (s) {
          if (s == null) {
            return ErrorView(
              title: 'Subscriber not found',
              message: 'This subscriber may have been removed. Go back and pick another one.',
              onRetry: () => context.pop(),
              retryLabel: 'Back to list',
            );
          }
          return DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(
                  subscriberId: s.id,
                  name: s.name,
                  active: s.active,
                  phone: s.phone,
                ),
                const SizedBox(height: 16),
                const TabBar(
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Subscriptions'),
                    Tab(text: 'Payments'),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(
                        subscriberId: s.id,
                        name: s.name,
                        phone: s.phone,
                        active: s.active,
                        createdAt: s.createdAt,
                      ),
                      _SubscriptionsTab(subscriberId: s.id),
                      _PaymentsTab(subscriberId: s.id),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => LoadingView(rows: 4),
        error: (e, _) => ErrorView(
          message: 'We could not load this subscriber. Check your connection and try again.',
          onRetry: () => ref.invalidate(subscriberDetailProvider(id)),
        ),
      ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({
    required this.subscriberId,
    required this.name,
    required this.active,
    required this.phone,
  });

  final String subscriberId;
  final String name;
  final bool active;
  final String phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rMd,
        border: Border.all(color: AppColors.outlineSoft),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'subscriber-avatar-$subscriberId',
                child: InitialsAvatar(name: name, size: 56, dimmed: !active),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppType.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    StatusPill.fromStatus(active ? 'active' : 'inactive'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(
                    '/payments/review?subscriberId=$subscriberId',
                  ),
                  icon: const Icon(Icons.payments_rounded, size: 18),
                  label: const Text('Collect payment'),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({
    required this.subscriberId,
    required this.name,
    required this.phone,
    required this.active,
    required this.createdAt,
  });

  final String subscriberId;
  final String name;
  final String phone;
  final bool active;
  final String createdAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Name',
              subtitle: name,
              showChevron: false,
              onTap: null,
              // Removed phone field and caller button per review guidelines
            ),
            SurfaceRow(
              title: 'Phone',
              subtitle: phone.isEmpty ? 'Not provided' : phone,
              showChevron: false,
              onTap: null,
              // Removed caller button Icon(Icons.call_outlined) per review guidelines
            ),
            SurfaceRow(
              title: 'Added',
              subtitle: BizDate.prettyYMD(createdAt),
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Status',
              subtitle: active
                  ? 'Active · appears in billing'
                  : 'Inactive · excluded from new billing',
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Actions'),
        SurfaceSection(
          children: [
            SurfaceRow(
              title: active ? 'Deactivate subscriber' : 'Reactivate subscriber',
              subtitle: active
                  ? 'Keeps records and history; subscriptions remain running.'
                  : 'Let this subscriber be billed again.',
              showChevron: false,
              onTap: () async {
                if (active) {
                  final ok = await showConfirmDialog(
                    context,
                    title: 'Deactivate $name?',
                    message:
                        'They stay in your records with all history intact.',
                    consequence: 'Subscriptions keep running and payments are not deleted. You can reactivate at any time.',
                    confirmLabel: 'Deactivate',
                    destructive: true,
                  );
                  if (!ok) return;
                }
                await ref
                    .read(subscribersRepositoryProvider)
                    .setSubscriberActive(subscriberId, !active);
                ref.invalidate(subscribersListProvider);
                ref.invalidate(subscriberDetailProvider(subscriberId));
                if (context.mounted) {
                  showAppSnack(
                    context,
                    message: active
                        ? '$name deactivated.'
                        : '$name reactivated.',
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SubscriptionsTab extends ConsumerWidget {
  const _SubscriptionsTab({required this.subscriberId});

  final String subscriberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionsListProvider(subscriberId));

    return subs.when(
      data: (subsList) {
        final items = subsList.items;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No subscriptions found', style: AppType.body),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (var i = 0; i < items.length; i++)
              _SubscriptionItem(subscription: items[i]),
          ],
        );
      },
      loading: () => const LoadingView(rows: 4),
      error: (e, _) => ErrorView(
        message: 'We could not load subscriptions. Check your connection and try again.',
        onRetry: () => ref.invalidate(subscriptionsListProvider(subscriberId)),
      ),
    );
  }
}

class _SubscriptionItem extends ConsumerWidget {
  const _SubscriptionItem({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = switch (subscription.billingPeriod) {
      'monthly' => 'monthly',
      'yearly' => 'yearly',
      'weekly' => 'weekly',
      'daily' => 'daily',
      _ => subscription.billingPeriod,
    };
    return SurfaceRow(
      title: period[0].toUpperCase() + period.substring(1) + ' service',
      subtitle:
          'PKR ${MoneyUtils.formatPKR(subscription.price)} · next due ${subscription.nextPaymentDate}',
      showChevron: true,
      onTap: () => context.push('/subscriptions/${subscription.id}'),
      trailing: StatusPill.fromStatus(subscription.status),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.subscriberId});

  final String subscriberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsListProvider(subscriberId));

    return payments.when(
      data: (paymentsList) {
        final items = paymentsList.items;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No payments found', style: AppType.body),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (var i = 0; i < items.length; i++)
              _PaymentItem(payment: items[i]),
          ],
        );
      },
      loading: () => const LoadingView(rows: 4),
      error: (e, _) => ErrorView(
        message:
            'We could not load payments. Check your connection and try again.',
        onRetry: () => ref.invalidate(paymentsListProvider(subscriberId)),
      ),
    );
  }
}

class _PaymentItem extends ConsumerWidget {
  const _PaymentItem({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = payment.items
        .map((PaymentItem i) => i.serviceName)
        .toList();
    final title = services.isEmpty
        ? 'Payment'
        : services.length == 1
        ? services.first
        : '${services.length} services';
    return SurfaceRow(
      title: title,
      subtitle:
          '${payment.paymentDate} · PKR ${MoneyUtils.formatPKR(payment.finalAmount)}',
      showChevron: true,
      onTap: () => context.push('/payments/${payment.id}'),
      trailing: StatusPill.fromStatus(payment.status),
    );
  }
}
