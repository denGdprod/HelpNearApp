import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthStateNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;
  bool _isInitialized = false; // Флаг для инициализации
  late final StreamSubscription<User?> _authSub;
  bool _emailWasJustVerified = false;
  bool? _isProfileCreatedCache;

  AuthStateNotifier() {
    _authSub = _auth.authStateChanges().listen(_handleAuthStateChanged);
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized; // Геттер для флага инициализации
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get emailWasJustVerified => _emailWasJustVerified;

  bool? get isProfileCreatedSync => _isProfileCreatedCache ?? false;

  Future<void> checkProfileCreated() async {
    if (_user == null) {
      _isProfileCreatedCache = false;
      debugPrint('🚫 [ProfileCheck] No user, profile not created.');
      return;
    }

    debugPrint('🔄 [ProfileCheck] Checking profile for user: ${_user!.uid}');
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      _isProfileCreatedCache = doc.exists && (doc.data()?['profileCreated'] == true);
      debugPrint('✅ [ProfileCheck] Profile created: $_isProfileCreatedCache');
    } catch (e) {
      debugPrint('❌ [ProfileCheck] Error checking profile: $e');
      _isProfileCreatedCache = false;
    } finally {
      notifyListeners();
    }
  }
  // Обработчик изменений состояния аутентификации
  Future<void> _handleAuthStateChanged(User? user) async {
    debugPrint('🔄 [AuthStateChanged] user: ${user?.uid ?? 'null'}');
    _setLoading(true); // Устанавливаем флаг загрузки в true
    _user = user;

    if (_user != null) {
      debugPrint('✅ [AuthStateChanged] User is authenticated: ${_user!.uid}');

      try {
        debugPrint('🔄 [AuthStateChanged] Reloading user...');
        await _user!.reload();
        _user = _auth.currentUser;
        debugPrint('🔄 [AuthStateChanged] User reloaded: ${_user?.uid ?? 'null'}');

        await checkProfileCreated();

        // Логируем событие подтверждения email
        if (_user!.emailVerified && !_emailWasJustVerified) {
          debugPrint('✅ [AuthStateChanged] Email verified!');
          _emailWasJustVerified = true;
          //_startEmailVerifiedFlagTimer();
        }
      } catch (e) {
        debugPrint('❌ [AuthStateChanged] Error during auth state change: $e');
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          debugPrint('❌ [AuthStateChanged] User not found, signing out...');
          await _auth.signOut();
          _user = null;
        }
      }
    } else {
      debugPrint('🚫 [AuthStateChanged] No user found, signing out...');
      _isProfileCreatedCache = false; // Пользователь не авторизован
    }

    // Устанавливаем флаг инициализации после загрузки
    _isInitialized = true;
    _setLoading(false); // Устанавливаем флаг загрузки в false
  }

  // Метод для обновления информации о пользователе
  Future<void> refreshUser() async {
    debugPrint('🔄 [RefreshUser] Refreshing user...');
    try {
      _setLoading(true);
      await _user?.reload();
      _user = _auth.currentUser;
      debugPrint('✅ [RefreshUser] User refreshed: ${_user?.uid ?? 'null'}');
    } catch (e) {
      debugPrint('❌ [RefreshUser] Error refreshing user: $e');
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        await _auth.signOut();
        _user = null;
        debugPrint('❌ [RefreshUser] User not found, signed out.');
      }
    } finally {
      _setLoading(false); // Устанавливаем флаг загрузки в false
      notifyListeners(); // Уведомляем слушателей
    }
  }

  // Маркер, что email был подтверждён
  void markEmailVerificationComplete() {
    debugPrint('✅ [EmailVerification] Marking email verification complete.');
    _emailWasJustVerified = false;
    notifyListeners();
  }

  // Таймер для сброса флага emailWasJustVerified
  // void _startEmailVerifiedFlagTimer() {
  //   debugPrint('🔄 [EmailVerification] Starting email verification flag timer...');
  //   Timer(const Duration(seconds: 10), () {
  //     _emailWasJustVerified = false;
  //     debugPrint('✅ [EmailVerification] Email verification flag reset.');
  //     notifyListeners();
  //   });
  // }

  // Устанавливаем флаг загрузки
  void _setLoading(bool value) {
    if (_isLoading != value) {
      debugPrint('🔄 [SetLoading] Changing loading state: $value');
      _isLoading = value;
      notifyListeners();
    }
  }

  // Метод для выхода из аккаунта
  Future<void> signOut() async {
    debugPrint('🔄 [SignOut] Signing out...');
    try {
      await _auth.signOut();
      _user = null;
      debugPrint('✅ [SignOut] User signed out.');
    } catch (e) {
      debugPrint('❌ [SignOut] Error signing out: $e');
    } finally {
      notifyListeners();
    }
  }

  void finishSplash() {
    notifyListeners(); // Это приведет к тому, что GoRouter сработает
  }

  @override
  void dispose() {
    debugPrint('🔄 [Dispose] Disposing AuthStateNotifier...');
    _authSub.cancel();
    super.dispose();
  }
}
