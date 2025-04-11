import 'package:go_router/go_router.dart';
import 'package:helpnear_app/features/map/home_screen.dart';
import 'package:helpnear_app/features/profile/account_screen.dart';
import 'package:helpnear_app/features/auth/login_screen.dart';
import 'package:helpnear_app/features/auth/signup_screen.dart';
import 'package:helpnear_app/features/auth/reset_password_screen.dart';
import 'package:helpnear_app/features/auth/verify_email_screen.dart';
import 'package:helpnear_app/features/errors/ErrorScreen.dart';
import 'package:helpnear_app/features/auth/unauthenticated_screen.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';
import 'package:provider/provider.dart';

final appRouter = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  routes: [
    // маршруты
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
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
      path: '/account',
      name: 'account',
      builder: (context, state) => const AccountScreen(),
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
    final auth = Provider.of<AuthStateNotifier>(context, listen: false);
    final isAuth = auth.isAuthenticated;
    final isEmailVerified = auth.isEmailVerified;
    final currentLocation = state.uri.toString();

    final authRoutes = [
      '/login',
      '/signup',
      '/reset_password',
      '/verify_email'
    ];

    // Если пользователь не авторизован и не на auth-маршруте
    if (!isAuth && !authRoutes.contains(currentLocation)) {
      return '/unauthenticated';
    }

    // Если email не подтвержден и не на странице подтверждения
    if (isAuth && !isEmailVerified && currentLocation != '/verify_email') {
      return '/verify_email';
    }

    // Если авторизован и пытается попасть на auth-страницы
    if (isAuth && authRoutes.contains(currentLocation)) {
      return '/home'; // Или '/account' в зависимости от логики
    }

    return null;
  },
);