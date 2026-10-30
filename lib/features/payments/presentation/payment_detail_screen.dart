import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/date/biz_date.dart';
import 'package:subscription_saas_flutter/core/money/money.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/money_text.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/state_widgets.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';
import 'package:subscription_saas_flutter/features/payments/data/providers/payments_providers.dart';
import 'package:subscription_saas_flutter/features/payments/domain/models/payment.dart';
import 'package:subscription_saas_flutter/features/payments/presentation/receipt_pdf.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment = ref.watch(paymentDetailProvider(id));

    return AppScaffold(
      title: 'Payment',
      subtitle: 'Receipt detail',
      body: payment.when(
        data: (p) {
          if (p == null) {
            return const ErrorView(
              title: 'Payment not found',
              message: 'This payment record could not be found.',
            );
          }
          return _Body(payment: p);
        },
        loading: () => LoadingView(rows: 4),
        error: (e, _) => ErrorView(
          message: 'We could not load this payment.',
          onRetry: () => ref.invalidate(paymentDetailProvider(id)),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final p = payment;
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
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const StatusPill(label: 'Paid', tone: PillTone.success),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'READ-ONLY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.overline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Hero(
                tag: 'payment-amount-${p.id}',
                child: MoneyText(
                  p.finalAmount,
                  style: AppType.moneyHero,
                  tone: MoneyTone.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${p.subscriberName} · ${BizDate.prettyYMD(p.paymentDate)}',
                style: AppType.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Receipt'),
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Receipt number',
              subtitle: p.receiptId ?? '—',
              showChevron: false,
            ),
            SurfaceRow(title: 'Payment ID', subtitle: p.id, showChevron: false),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Items settled'),
        SurfaceSection(
          children: [
            for (var i = 0; i < p.items.length; i++)
              SurfaceRow(
                title: p.items[i].serviceName,
                subtitle: 'Due ${BizDate.prettyYMD(p.items[i].dueDate)}',
                showChevron: false,
                trailing: MoneyText(p.items[i].amount, style: AppType.money),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Summary'),
        SurfaceSection(
          children: [
            SurfaceRow(
              title: 'Calculated',
              subtitle: MoneyUtils.formatPKR(p.calculatedAmount),
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Billed',
              subtitle: MoneyUtils.formatPKR(p.billedAmount),
              showChevron: false,
            ),
            SurfaceRow(
              title: 'Final total',
              subtitle: MoneyUtils.formatPKR(p.finalAmount),
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => shareReceipt(p),
            icon: const Icon(Icons.ios_share_rounded, size: 18),
            label: const Text('Share receipt'),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Generated on this device from the saved receipt snapshot.',
            style: AppType.overline.copyWith(letterSpacing: 0.2),
          ),
        ),
      ],
    );
  }
}
