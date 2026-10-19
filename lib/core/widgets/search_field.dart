import 'package:flutter/material.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';

/// Search input with a clear affordance that only appears once there is text,
/// so the control does not imply an action that is unavailable.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
    this.initialValue,
    this.trailing,
    this.autofocus = false,
    this.semanticLabel,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final String? initialValue;
  final Widget? trailing;
  final bool autofocus;
  final String? semanticLabel;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initialValue ?? '');
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _c.text.isNotEmpty;
    return AnimatedContainer(
      duration: AppMotion.scale(context, AppMotion.fast),
      curve: AppMotion.emphasized,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rPill,
        border: Border.all(
          color: _focused ? AppColors.primary.withValues(alpha: 0.7) : AppColors.outlineSoft,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: _focused ? AppColors.primary : AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _c,
              focusNode: _focus,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              style: AppType.bodyStrong,
              onChanged: (v) {
                setState(() {});
                widget.onChanged(v);
              },
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                hintText: widget.hintText,
                hintStyle: AppType.body.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          AnimatedSize(
            duration: AppMotion.scale(context, AppMotion.fast),
            curve: AppMotion.emphasized,
            child: hasText
                ? IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _c.clear();
                      setState(() {});
                      widget.onChanged('');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  )
                : const SizedBox(width: 12, height: 48),
          ),
          if (widget.trailing != null) ...[
            widget.trailing!,
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
