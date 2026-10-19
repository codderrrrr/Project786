import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';

/// Plan state. The current state is stated once, permanently visible at the
/// top, with the concrete consequence of that state spelled out below.
class SaasScreen extends StatelessWidget {
  const SaasScreen({super.key});

  static const _states = <(String, String, String, List<String>, List<String>)>[
    (
      'ACTIVE',
      'Everything works',
      'active',
      ['Collect payments', 'Add and edit subscribers', 'Change schedules', 'Generate receipts'],
      [],
    ),
    (
      'GRACE_PERIOD',
      'Payment is late but you can still work',
      'grace_period',
      ['Collect payments', 'Manage subscribers', 'Generate receipts'],
      ['Plan renews only after payment'],
    ),
    (
      'READ_ONLY',
      'You can look, but not change anything',
      'read_only',
      ['View subscribers, payments and reports', 'Share existing receipts'],
      ['Record payments', 'Create or edit subscribers', 'Change subscriptions'],
    ),
    (
      'BLOCKED',
      'Access is suspended',
      'blocked',
      ['Sign in to settle the plan'],
      ['All business operations', 'Recording payments', 'Generating receipts'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _states[0];

    return AppScaffold(
      title: 'Plan status',
      subtitle: 'What your subscription allows',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
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
                Text('Current plan state', style: AppType.caption),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const StatusPill(
                      label: 'Active',
                      tone: PillTone.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        current.$1,
                        style: AppType.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(current.$2, style: AppType.body),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'If the plan lapses',
            subtitle: 'What changes in each state, before you reach it',
          ),
          for (var i = 1; i < _states.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StateCard(
                name: _states[i].$1,
                description: _states[i].$2,
                status: _states[i].$3,
                allowed: _states[i].$4,
                blocked: _states[i].$5,
                isCurrent: i == 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.name,
    required this.description,
    required this.status,
    required this.allowed,
    required this.blocked,
    required this.isCurrent,
  });

  final String name;
  final String description;
  final String status;
  final List<String> allowed;
  final List<String> blocked;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$name. $description. ${allowed.length} allowed, ${blocked.length} blocked.',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.rMd,
          border: Border.all(
            color: isCurrent
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.outlineSoft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Wrap, not Row: at large system text sizes the badges drop onto a
          // second line instead of being clipped.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill.fromStatus(status),
              if (isCurrent)
                Text(
                  'Current',
                  style: AppType.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: AppType.body),
          const SizedBox(height: 12),
          for (final a in allowed)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_rounded, size: 14, color: AppColors.success),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a, style: AppType.caption.copyWith(color: AppColors.textPrimary))),
                ],
              ),
            ),
          for (final b in blocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.remove_circle_outline_rounded, size: 14, color: AppColors.danger),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b, style: AppType.caption.copyWith(color: AppColors.textPrimary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
