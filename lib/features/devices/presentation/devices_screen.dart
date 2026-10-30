import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';
import 'package:subscription_saas_flutter/core/widgets/status_pill.dart';
import 'package:subscription_saas_flutter/core/widgets/surface_rows.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final List<_Device> _devices = [
    const _Device(
      id: 'dev_001',
      name: 'Infinix X6810',
      detail: 'Android · this device',
      lastActive: 'Active now',
      current: true,
    ),
    const _Device(
      id: 'dev_002',
      name: 'Android Tablet',
      detail: 'Android 14',
      lastActive: '2 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Active devices',
      subtitle: 'Where this business is signed in',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          const SectionHeader(
            title: 'Signed in',
            subtitle: 'Revoking a device signs it out immediately',
          ),
          SurfaceSection(
            children: [
              for (final d in _devices)
                SurfaceRow(
                  title: d.name,
                  subtitle: '${d.detail} · ${d.lastActive}',
                  leading: Icon(
                    d.current
                        ? Icons.phone_android_rounded
                        : Icons.tablet_android_rounded,
                    size: 20,
                    color: d.current ? AppColors.success : AppColors.primary,
                  ),
                  showChevron: false,
                  semanticLabel:
                      '${d.name}. ${d.detail}. Last active ${d.lastActive}.${d.current ? ' This device.' : ''}',
                  trailing: d.current
                      ? const StatusPill(
                          label: 'This device',
                          tone: PillTone.success,
                          compact: true,
                        )
                      : TextButton(
                          onPressed: () => _revoke(d),
                          child: const Text('Revoke'),
                        ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.rMd,
              border: Border.all(color: AppColors.outlineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How device limits work', style: AppType.subtitle),
                const SizedBox(height: 6),
                Text(
                  'Signing in on a new device does not sign you out elsewhere automatically. '
                  'If you reach your device limit you will be asked which device to remove — '
                  'nothing is revoked silently.',
                  style: AppType.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _revoke(_Device d) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Revoke ${d.name}?',
      message:
          'That device will be signed out and will need the password again.',
      consequence: 'You stay signed in here. Business data and payment history are unaffected.',
      confirmLabel: 'Revoke',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _devices.removeWhere((x) => x.id == d.id);
    });
    showAppSnack(
      context,
      message: '${d.name} revoked.',
      actionLabel: 'Undo',
      onAction: () => setState(() => _devices.add(d)),
    );
  }
}

class _Device {
  const _Device({
    required this.id,
    required this.name,
    required this.detail,
    required this.lastActive,
    this.current = false,
  });

  final String id;
  final String name;
  final String detail;
  final String lastActive;
  final bool current;
}
