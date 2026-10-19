import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_scaffold.dart';
import 'package:subscription_saas_flutter/core/widgets/dialogs.dart';
import 'package:subscription_saas_flutter/core/widgets/section_header.dart';

/// Change password screen.
/// - Enter current password
/// - Wait for confirmation of the password
/// - Replace with Enter new password and confirm password
/// - Password should be at least 8 chars long
class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AppScaffold(
      title: 'Change password',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Change password'),

              // Current password
              Text(
                'Current password',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: currentController,
                decoration: const InputDecoration(
                  hintText: 'Enter your current password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New password
              Text(
                'New password',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: newController,
                decoration: const InputDecoration(
                  hintText: 'Enter new password (min 8 chars)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
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

              // Confirm password
              Text(
                'Confirm password',
                style: AppType.label.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: confirmController,
                decoration: const InputDecoration(
                  hintText: 'Confirm new password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm password is required';
                  }
                  if (value != newController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: formKey.currentState?.validate() == true
                      ? () {
                          // TODO: Implement password change
                          showAppSnack(
                            context,
                            message: 'Password changed successfully',
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
