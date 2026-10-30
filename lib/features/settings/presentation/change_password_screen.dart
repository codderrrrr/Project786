import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';

/// Change password.
///
/// Form state (controllers, form key, visibility toggles) lives on a state
/// object instead of being rebuilt in `build()`: controllers created inside
/// build lose their contents on every rebuild, and a submit button whose
/// enabled state is validated at build time can never become enabled when
/// validation only runs inside its own `onPressed`.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  var _obscureCurrent = true;
  var _obscureNew = true;
  var _obscureConfirm = true;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!( _formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    // Keep fields enabled during the (demo) round-trip; parity with dialog
    // flows elsewhere. A real backend call goes here.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _submitting = false);
    showAppSnack(context, message: 'Password changed successfully');
    Navigator.of(context).pop();
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return InputDecoration(
      hintText: hint,
      // Placeholder carries no data once the user types; the helper texts
      // below restate the rule where it matters.
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        onPressed: toggle,
        isSelected: !obscure,
        icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        tooltip: obscure ? 'Show password' : 'Hide password',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Change password',
      body: SafeArea(
        child: SingleChildScrollView(
          // Keeps every field reachable while the keyboard is up.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use at least 8 characters. You will stay signed in on this device.',
                  style: AppType.caption.copyWith(color: AppType.body.color),
                ),
                const SizedBox(height: 16),
                _label('Current password'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _currentController,
                  decoration: _passwordDecoration(
                    hint: 'Enter your current password',
                    obscure: _obscureCurrent,
                    toggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  obscureText: _obscureCurrent,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('New password'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _newController,
                  decoration: _passwordDecoration(
                    hint: 'At least 8 characters',
                    obscure: _obscureNew,
                    toggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New password is required';
                    }
                    if (value.length < 8) {
                      return 'Password should be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Confirm new password'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _confirmController,
                  decoration: _passwordDecoration(
                    hint: 'Re-enter the new password',
                    obscure: _obscureConfirm,
                    toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password is required';
                    }
                    if (value != _newController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: AppType.label.copyWith(fontWeight: FontWeight.w500));
}
