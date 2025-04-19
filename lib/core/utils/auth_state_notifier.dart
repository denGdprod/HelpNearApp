import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthStateNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;
  late final StreamSubscription<User?> _authSub;
  bool _emailWasJustVerified = false;

  AuthStateNotifier() {
    _authSub = _auth.authStateChanges().listen(_handleAuthStateChanged);
  }

  bool get isLoading => _isLoading;
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;
  bool get emailWasJustVerified => _emailWasJustVerified;

  Future<void> _handleAuthStateChanged(User? user) async {
    _setLoading(true);
    _user = user;

    if (_user != null) {
      try {
        await _user!.reload();
        _user = _auth.currentUser;

        // Обнаружение момента подтверждения email
        if (_user!.emailVerified && !_emailWasJustVerified) {
          _emailWasJustVerified = true;
          _startEmailVerifiedFlagTimer();
        }
      } catch (e) {
        debugPrint('❌ Auth state error: $e');
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          await _auth.signOut();
          _user = null;
        }
      }
    }

    _setLoading(false);
    notifyListeners();
  }

  Future<bool> get isProfileCreated async {
    if (_user == null) return false;
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.exists && (doc.data()?['profileCreated'] == true);
    } catch (e) {
      debugPrint('❌ Profile check error: $e');
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      _setLoading(true);
      await _user?.reload();
      _user = _auth.currentUser;
    } catch (e) {
      debugPrint('❌ Refresh user error: $e');
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        await _auth.signOut();
        _user = null;
      }
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void markEmailVerificationComplete() {
    _emailWasJustVerified = false;
    notifyListeners();
  }

  void _startEmailVerifiedFlagTimer() {
    Timer(const Duration(seconds: 10), () {
      _emailWasJustVerified = false;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}