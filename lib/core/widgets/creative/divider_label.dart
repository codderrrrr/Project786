import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Divider with centered label.
class DividerLabel extends StatelessWidget {
  const DividerLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.outlineSoft)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: AppType.overline),
          ),
          Expanded(child: Divider(color: AppColors.outlineSoft)),
        ],
      ),
    );
  }
}
