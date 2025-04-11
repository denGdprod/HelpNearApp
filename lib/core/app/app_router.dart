import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpnear_app/core/app/auth_wrapper.dart';
import 'package:helpnear_app/features/map/home_screen.dart';
import 'package:helpnear_app/features/profile/account_screen.dart';
import 'package:helpnear_app/features/auth/login_screen.dart';
import 'package:helpnear_app/features/auth/signup_screen.dart';
import 'package:helpnear_app/features/auth/reset_password_screen.dart';
import 'package:helpnear_app/features/auth/verify_email_screen.dart';
import 'package:helpnear_app/features/errors/ErrorScreen.dart';

final appRouter = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  routes: [
    // Главный маршрут с AuthWrapper
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWrapper(),
    ),
    
    // Дочерние маршруты
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
  ],

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuth = user != null;
    final isEmailVerified = user?.emailVerified ?? false;
    final currentLocation = state.uri.path; 

    final authRoutes = [
      '/login',
      '/signup',
      '/reset_password',
      '/verify_email'
    ];

    // Если пользователь не авторизован и не на auth-маршруте
    if (!isAuth && !authRoutes.contains(currentLocation)) {
      return '/login';
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