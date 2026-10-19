import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_palette.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/app/theme/theme_controller.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/filter_bar.dart';
import 'package:subscription_saas_flutter/core/widgets/pressable.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';

/// Appearance — choose the palette the app paints itself with.
///
/// Each row is a swatch drawn in its own colours plus the theme's name, so the
/// choice is made by looking rather than by reading a colour name. Selecting
/// applies immediately; the list is short enough to see two or three options
/// above the fold.
class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(themeControllerProvider);
    // The release surface intentionally exposes only the two supported product
    // modes. Legacy palettes remain in the palette registry for persisted IDs
    // and contrast tests, but are not offered as user-facing themes.
    final all = [AppPalettes.pixelLight, AppPalettes.nocturneBloom];
    final visible = switch (_filter) {
      'dark' => all.where((p) => p.isDark).toList(),
      'light' => all.where((p) => !p.isDark).toList(),
      _ => all,
    };

    return AppScaffold(
      title: 'Appearance',
      subtitle: 'Light and dark mode · saved on this device',
      body: ListView(
        // Clear of the system gesture area and the last row: the old trailing
        // padding was smaller than the bottom bar and hid the final option.
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 24),
        children: [
          const SectionHeader(
            title: 'Colour scheme',
            subtitle: 'Saved on this device',
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilterBar(
              options: [
                FilterOption(id: 'all', label: 'All', count: all.length),
                FilterOption(id: 'dark', label: 'Dark', count: all.where((p) => p.isDark).length),
                FilterOption(id: 'light', label: 'Light', count: all.where((p) => !p.isDark).length),
              ],
              selectedId: _filter,
              onSelected: (id) => setState(() => _filter = id),
              semanticLabel: 'Filter themes by brightness',
            ),
          ),
          _ThemeList(
            palettes: visible,
            activeId: active.id,
            onSelect: _select,
          ),
        ],
      ),
    );
  }

  void _select(AppPalette palette) {
    if (palette.id == ref.read(themeControllerProvider).id) return;
    ref.read(themeControllerProvider.notifier).select(palette);
  }
}

/// One grouped panel of theme rows rather than a stack of individual cards.
class _ThemeList extends StatelessWidget {
  const _ThemeList({
    required this.palettes,
    required this.activeId,
    required this.onSelect,
  });

  final List<AppPalette> palettes;
  final String activeId;
  final ValueChanged<AppPalette> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.rMd,
        border: Border.all(color: AppColors.outlineSoft),
      ),
      child: Column(
        children: [
          for (var i = 0; i < palettes.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: Gap.gutter,
                endIndent: Gap.gutter,
                color: AppColors.outlineSoft,
              ),
            _ThemeOption(
              palette: palettes[i],
              selected: palettes[i].id == activeId,
              onSelect: () => onSelect(palettes[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.palette,
    required this.selected,
    required this.onSelect,
  });

  final AppPalette palette;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    // The swatch is painted with the palette it describes, not the active one,
    // so a light theme looks light even while a dark theme is applied.
    final p = palette;
    return Pressable(
      onTap: onSelect,
      haptic: true,
      semanticLabel:
          '${p.name}, ${p.isDark ? 'dark' : 'light'} theme${selected ? ', selected' : ''}',
      semanticHint: selected ? 'Currently selected' : 'Double tap to apply this theme',
      excludeChildSemantics: true,
      child: Container(
        color: selected ? AppColors.primary.withValues(alpha: 0.07) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(Gap.gutter, 12, Gap.gutter, 12),
        child: Row(
          children: [
            // 3 colour stops of the palette: canvas, surface, accent.
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: AppRadii.rSm,
                border: Border.all(color: AppColors.outlineSoft),
              ),
              child: ClipRRect(
                borderRadius: AppRadii.rSm,
                child: Column(
                  children: [
                    Expanded(child: ColoredBox(color: p.canvas)),
                    Expanded(child: ColoredBox(color: p.surfaceHigh)),
                    Expanded(child: ColoredBox(color: p.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.subtitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              Icon(Icons.check_rounded, size: 20, color: AppColors.primary)
            else
              Text(
                p.isDark ? 'Dark' : 'Light',
                style: AppType.caption.copyWith(color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}
