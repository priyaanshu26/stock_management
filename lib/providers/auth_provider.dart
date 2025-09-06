import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userData?.isAdmin ?? false;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Handle auth state changes
  void _onAuthStateChanged(User? user) async {
    _user = user;
    _userData = null;
    _error = null;

    if (user != null) {
      // Load user data from Firestore
      try {
        _userData = await _authService.getUserData(user.uid);
        
        // If user document doesn't exist, create it
        if (_userData == null) {
          await _authService.createUserDocumentForExistingUser(user);
          _userData = await _authService.getUserData(user.uid);
        }
      } catch (e) {
        _error = e.toString();
      }
    }

    notifyListeners();
  }

  // Sign in
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      User? user = await _authService.signInWithEmailPassword(email, password);
      _setLoading(false);
      return user != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign up
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      User? user = await _authService.createUserWithEmailPassword(email, password);
      _setLoading(false);
      return user != null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signOut();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Make user admin (for existing users)
  Future<bool> makeUserAdmin(String email) async {
    _setLoading(true);
    _error = null;

    try {
      bool success = await _authService.makeUserAdmin(email);
      
      // If the current user's email matches, refresh their data
      if (_user?.email == email && success) {
        _userData = await _authService.getUserData(_user!.uid);
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Refresh current user data
  Future<void> refreshUserData() async {
    if (_user != null) {
      _setLoading(true);
      _error = null;

      try {
        _userData = await _authService.getUserData(_user!.uid);
        _setLoading(false);
      } catch (e) {
        _error = e.toString();
        _setLoading(false);
        notifyListeners();
      }
    }
  }

  // Update current user role
  Future<bool> updateCurrentUserRole(String role) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _error = null;

    try {
      await _authService.updateUserRole(_user!.uid, role);
      
      // Refresh user data to reflect the change
      _userData = await _authService.getUserData(_user!.uid);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}