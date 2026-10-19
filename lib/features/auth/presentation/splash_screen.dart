import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:subscription_saas_flutter/app/theme/app_colors.dart';
import 'package:subscription_saas_flutter/app/theme/app_radii.dart';
import 'package:subscription_saas_flutter/app/theme/app_motion.dart';
import 'package:subscription_saas_flutter/app/theme/app_type.dart';
import 'package:subscription_saas_flutter/core/widgets/app_background.dart';

/// Brand moment while the session is restored. In demo mode this forwards
/// straight to Home, so the owner never has to log in to evaluate the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: AuroraBackground(
        intensity: 1.2,
        child: Center(
          child: Semantics(
            label: 'Subscription Manager, starting up',
            liveRegion: true,
            excludeSemantics: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: reduced ? Duration.zero : AppMotion.bloom,
                  curve: AppMotion.overshoot,
                  builder: (context, t, child) => Transform.scale(
                    scale: 0.7 + (0.3 * t),
                    child: Opacity(opacity: t.clamp(0, 1), child: child),
                  ),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadii.rXl,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.32),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Icon(Icons.grid_view_rounded, color: AppColors.onAccent, size: 40),
                  ),
                ),
                const SizedBox(height: 26),
                Text('Subscription Manager', style: AppType.title),
                const SizedBox(height: 6),
                Text('Your business, in one console', style: AppType.caption),
                const SizedBox(height: 32),
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: AppRadii.rXs,
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
