import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/analytics/presentation/analytics_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (authState.isLoading) return null;

      final user = authState.value;

      if (isSplash) return null; // Let splash handle its own delayed redirect

      if (user == null) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn || isSplash) {
        if (user.role.name == 'admin') {
          return '/admin';
        } else {
          return '/analytics';
        }
      }

      // Role-based route guards
      if (state.matchedLocation.startsWith('/admin') && user.role.name != 'admin') {
        return '/analytics'; // Redirect non-admins trying to access admin
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
    ],
  );
});
