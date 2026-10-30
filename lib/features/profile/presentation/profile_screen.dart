import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/glass_card.dart';
import 'package:subscription_saas_flutter/core/widgets/initials_avatar.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController(text: 'Demo Owner');
  final _email = TextEditingController(text: 'owner@demobusiness.pk');
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  double get _strength {
    final v = _next.text;
    if (v.isEmpty) return 0;
    var score = 0.0;
    if (v.length >= 8) score += 0.35;
    if (RegExp(r'[A-Z]').hasMatch(v)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(v)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) score += 0.25;
    return score.clamp(0, 1);
  }

  String get _strengthLabel {
    final s = _strength;
    if (s == 0) return 'Enter a password';
    if (s < 0.5) return 'Weak';
    if (s < 0.8) return 'Fair';
    return 'Strong';
  }

  Color get _strengthColor {
    final s = _strength;
    if (s == 0) return AppColors.textTertiary;
    if (s < 0.5) return AppColors.danger;
    if (s < 0.8) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Your profile',
      subtitle: 'Owner account',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                InitialsAvatar(name: _name.text, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name.text,
                        style: AppType.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('Owner · Demo Business', style: AppType.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Details'),
          GlassCard(
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Change password'),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _current,
                  obscureText: !_showPassword,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _next,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    helperText:
                        'At least 8 characters, with a number and a symbol',
                    suffixIcon: IconButton(
                      tooltip: _showPassword
                          ? 'Hide passwords'
                          : 'Show passwords',
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: AppRadii.rXs,
                  child: LinearProgressIndicator(
                    value: _strength,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceHigh,
                    valueColor: AlwaysStoppedAnimation(_strengthColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _strengthLabel,
                  style: AppType.overline.copyWith(
                    letterSpacing: 0.2,
                    color: _strengthColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_current.text.isEmpty || _next.text.isEmpty) {
                        showAppSnack(
                          context,
                          message: 'Fill in both password fields first.',
                          error: true,
                        );
                        return;
                      }
                      showAppSnack(
                        context,
                        message: 'Password changes are not connected yet.',
                        error: true,
                      );
                    },
                    child: const Text('Update password'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: 'Sign out?',
                  message: 'You will need your business username and password to return.',
                  consequence: 'Other signed-in devices stay signed in until you revoke them under Active devices.',
                  confirmLabel: 'Sign out',
                  destructive: true,
                );
                if (!ok || !context.mounted) return;
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }
}
