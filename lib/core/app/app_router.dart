import 'package:go_router/go_router.dart';
import 'package:helpnear_app/features/map/root_screen.dart';
import 'package:helpnear_app/features/auth/login_screen.dart';
import 'package:helpnear_app/features/auth/signup_screen.dart';
import 'package:helpnear_app/features/auth/reset_password_screen.dart';
import 'package:helpnear_app/features/auth/verify_email_screen.dart';
import 'package:helpnear_app/features/errors/error_screen.dart';
import 'package:helpnear_app/features/auth/unauthenticated_screen.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';
import 'package:helpnear_app/features/map/map_screen.dart';
import 'package:helpnear_app/features/profile/create_profile/create_profile_screen.dart';
import 'package:helpnear_app/features/auth/email_verified.dart';
import 'package:helpnear_app/features/profile/profile_screen.dart';
import 'package:helpnear_app/features/profile/edit_profile/edit_profile_screen.dart';

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
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(), // Свой профиль
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'edit_profile',
                    builder: (context, state) => EditProfileScreen(),
                  ),
                  GoRoute(
                    path: ':userId',
                    name: 'user_profile',
                    builder: (context, state) {
                      final userId = state.pathParameters['userId']!;
                      return ProfileScreen(userId: userId);
                    },
                  ),
                ],
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
        path: '/email_verified',
        name: '/email_verified',
        builder: (context, state) => const EmailVerifiedScreen(),
      ),
      GoRoute(
        path: '/unauthenticated',
        name: 'unauthenticated',
        builder: (context, state) => const UnauthenticatedScreen(),
      ),
      GoRoute(
        path: '/create_profile',
        name: 'create_profile',
        builder: (context, state) => CreateProfileScreen(),
      ),
    ],
   redirect: (context, state) async {
    if (auth.isLoading) return null;
    try {
      final isAuth = auth.isAuthenticated;
      final isEmailVerified = auth.isEmailVerified;
      final isProfileCreated = await auth.isProfileCreated;
      final currentLocation = state.uri.path;

      final isAuthRoute = [
        '/login',
        '/signup',
        '/reset_password',
        '/verify_email',
        '/unauthenticated',
        '/email_verified',
      ].contains(currentLocation);

      // Если пользователь не аутентифицирован
      if (!isAuth) {
        return isAuthRoute ? null : '/unauthenticated';
      }

      // Если пользователь аутентифицирован
      if (isAuth) {
        // Если email не подтверждён
        if (!isEmailVerified) {
          return currentLocation == '/verify_email' ? null : '/verify_email';
        }

        // Если профиль не создан
        if (!isProfileCreated) {
          return currentLocation == '/create_profile' ? null : '/create_profile';
        }

        // Если всё в порядке, но пользователь на auth-странице
        if (isAuthRoute) {
          return '/map';
        }
      }

      return null;
    } catch (e) {
      // Если произошла ошибка (например, пользователь удалён)
      return '/unauthenticated';
    }
  },
  );
}
