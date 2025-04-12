import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStateNotifier extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  late final FirebaseAuth _auth;

  AuthStateNotifier() {
    _auth = FirebaseAuth.instance;

    // Подписываемся на изменения auth-состояния
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (_user != null) {
        await _user!.reload();
        _user = _auth.currentUser;
      }
      _isLoading = false;
      notifyListeners();
    });
  }
  bool get isLoading => _isLoading;
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
}
