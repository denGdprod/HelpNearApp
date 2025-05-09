import 'package:go_router/go_router.dart';
import 'package:helpnear_app/features/root_screen.dart';
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
import 'package:helpnear_app/features/loading/splash.dart';
import 'package:helpnear_app/features/profile/medicaldata_screen.dart';
import 'package:flutter/foundation.dart';

GoRouter createRouter(AuthStateNotifier auth) {
  return GoRouter(
    initialLocation: '/splash', // Начальная точка на Splash экран
    refreshListenable: auth,
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: [
      // Splash экран
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Root экран с навигацией
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
                    path: 'medical_data',
                    name: 'medical_data',
                    builder: (context, state) => const MedicalDataScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/user/:userId',
        name: 'user_profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      // Прочие экраны
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
    // Логика редиректа
    redirect: (context, state) {
      // Добавление подробного лога для редиректов
      debugPrint('🧭 Redirect triggered');
      debugPrint('🔁 Current location: ${state.uri.path}');
      debugPrint('🔐 isLoading: ${auth.isLoading}');
      debugPrint('👤 isAuthenticated: ${auth.isAuthenticated}');
      debugPrint('📧 isEmailVerified: ${auth.isEmailVerified}');
      debugPrint('📄 isProfileCreated: ${auth.isProfileCreatedSync ?? false}');

      // Если приложение еще загружается, не выполняем редирект
      if (auth.isLoading) return null;

      // Получаем состояние аутентификации и другие флаги
      final isAuth = auth.isAuthenticated;
      final isEmailVerified = auth.isEmailVerified;
      final isProfileCreated = auth.isProfileCreatedSync ?? false;
      final currentLocation = state.uri.path;

      // Проверяем, является ли текущий путь маршрутом для аутентификации
      final isAuthRoute = [
        '/login',
        '/signup',
        '/reset_password',
        '/verify_email',
        '/unauthenticated',
        '/email_verified',
      ].contains(currentLocation);

      final isMain = [
        '/profile',
        '/map'
      ].contains(currentLocation);

      // Редирект для незарегистрированных пользователей
      if (!isAuth) {
        debugPrint('🚫 Not authenticated, redirecting if needed...');
        return isAuthRoute ? null : '/unauthenticated';
      }

      // Если пользователь авторизован
      if (isAuth) {
        // Проверка email
        if (!isEmailVerified) {
          debugPrint('✉️ Email not verified, redirecting if needed...');
          return currentLocation == '/verify_email' ? null : '/verify_email';
        }
        // Проверка наличия профиля
        if (!isProfileCreated) {
          debugPrint('📋 Profile not created, redirecting if needed...');
          return currentLocation == '/create_profile' ? null : '/create_profile';
        }
        // Если пользователь авторизован и находит в аутентификационном маршруте
        if (auth.isAuthenticated && isAuthRoute || currentLocation == '/splash') {
          debugPrint('✅ Auth complete, but on auth route. Redirecting to /map...');
          return '/map'; // Редирект на карту, если авторизован
        }
      }
      // Если все условия выполнены, перенаправляем на основной экран
      debugPrint('👌 No redirect needed');
      return null;
    }
  );
}
