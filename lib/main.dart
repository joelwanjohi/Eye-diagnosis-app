import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_constants.dart';
import 'firebase_options.dart'; // Import the generated Firebase options
import 'providers/admin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/dashboard/dashboard_layout.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/diagnoses_screen.dart';
import 'screens/dashboard/reports_screen.dart';
import 'screens/dashboard/statistics_screen.dart';
import 'screens/dashboard/users_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: AdminDashboardApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == AppConstants.loginRoute;
      final isSplash = state.matchedLocation == AppConstants.splashRoute;
      
      // If splash screen, don't redirect
      if (isSplash) return null;
      
      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoggingIn) return AppConstants.loginRoute;
      
      // If logged in and on login page, redirect to dashboard
      if (isLoggedIn && isLoggingIn) return AppConstants.dashboardRoute;
      
      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.dashboardRoute,
        builder: (context, state) => const DashboardLayout(
          currentRoute: AppConstants.dashboardRoute,
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.usersRoute,
        builder: (context, state) => const DashboardLayout(
          currentRoute: AppConstants.usersRoute,
          child: UsersScreen(),
        ),
      ),
      GoRoute(
        path: '${AppConstants.usersRoute}/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id'];
          // TODO: Implement user details screen
          return DashboardLayout(
            currentRoute: AppConstants.usersRoute,
            child: Scaffold(
              appBar: AppBar(title: Text('User Details: $userId')),
              body: Center(child: Text('User details for $userId')),
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.diagnosesRoute,
        builder: (context, state) => const DashboardLayout(
          currentRoute: AppConstants.diagnosesRoute,
          child: DiagnosesScreen(),
        ),
      ),
      GoRoute(
        path: '${AppConstants.diagnosesRoute}/:id',
        builder: (context, state) {
          final diagnosisId = state.pathParameters['id'];
          // TODO: Implement diagnosis details screen
          return DashboardLayout(
            currentRoute: AppConstants.diagnosesRoute,
            child: Scaffold(
              appBar: AppBar(title: Text('Diagnosis Details: $diagnosisId')),
              body: Center(child: Text('Diagnosis details for $diagnosisId')),
            ),
          );
        },
      ),
      GoRoute(
        path: AppConstants.statisticsRoute,
        builder: (context, state) => const DashboardLayout(
          currentRoute: AppConstants.statisticsRoute,
          child: StatisticsScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.reportsRoute,
        builder: (context, state) => const DashboardLayout(
          currentRoute: AppConstants.reportsRoute,
          child: ReportsScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        builder: (context, state) => const DashboardLayout(
          currentRoute: AppConstants.settingsRoute,
          child: Scaffold(
            body: Center(child: Text('Settings (Coming Soon)')),
          ),
        ),
      ),
    ],
  );
});

class AdminDashboardApp extends ConsumerWidget {
  const AdminDashboardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light, // Default to light theme
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}