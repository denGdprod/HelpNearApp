import 'package:go_router/go_router.dart';
import 'package:helpnear_app/features/map/root_screen.dart';
import 'package:helpnear_app/features/profile/account_screen.dart';
import 'package:helpnear_app/features/auth/login_screen.dart';
import 'package:helpnear_app/features/auth/signup_screen.dart';
import 'package:helpnear_app/features/auth/reset_password_screen.dart';
import 'package:helpnear_app/features/auth/verify_email_screen.dart';
import 'package:helpnear_app/features/errors/error_screen.dart';
import 'package:helpnear_app/features/auth/unauthenticated_screen.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';
import 'package:helpnear_app/features/map/map_screen.dart';
import 'package:helpnear_app/features/map/widgets/sos_dialog.dart';

GoRouter createRouter(AuthStateNotifier auth) {
  return GoRouter(
    initialLocation: '/map',
    refreshListenable: auth,
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            RootScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                name: 'map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sos_dialog',
                name: 'sos_dialog',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                name: 'account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/reset_password',
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/verify_email',
        name: 'verify_email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/unauthenticated',
        name: 'unauthenticated',
        builder: (context, state) => const UnauthenticatedScreen(),
      ),
    ],
    redirect: (context, state) {
      if (auth.isLoading) return null;

      final isAuth = auth.isAuthenticated;
      final isEmailVerified = auth.isEmailVerified;
      final currentLocation = state.uri.toString();
      final authRoutes = [
        '/login',
        '/signup',
        '/reset_password',
        '/verify_email',
        '/unauthenticated',
      ];

      final isInAuthFlow =
          authRoutes.any((route) => currentLocation.startsWith(route));

      if (!isAuth && !isInAuthFlow) {
        return '/unauthenticated';
      }

      if (isAuth && !isEmailVerified && currentLocation != '/verify_email') {
        return '/verify_email';
      }

      if (isAuth && isInAuthFlow) {
        return '/map';
      }

      return null;
    },
  );
}
