import 'package:admin_dashboard/services/admin_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Delay for splash screen animation
    await Future.delayed(AppConstants.splashDuration);
    
    if (!mounted) return;
    
    // Check if user is already logged in
    final isLoggedIn = ref.read(adminFirebaseServiceProvider).isLoggedIn();
    
    if (isLoggedIn) {
      // Navigate to dashboard if logged in
      context.go(AppConstants.dashboardRoute);
    } else {
      // Navigate to login if not logged in
      context.go(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.visibility_rounded,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'EyeCheckAI Admin',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin Dashboard',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 48),
            const SpinKitPulse(
              color: AppTheme.primaryColor,
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}