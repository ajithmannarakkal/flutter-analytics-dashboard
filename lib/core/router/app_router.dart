import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/create_user_screen.dart';
import '../../features/analytics/presentation/analytics_dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (authState.isLoading) return null;

      // If there is an auth error, stay on/redirect to login page
      if (authState.hasError) {
        return isLoggingIn ? null : '/login';
      }

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
        return '/analytics';
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
        path: '/admin/create-user',
        builder: (context, state) => const CreateUserScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
