import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserModel? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  // Mock Login Function
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate delay
    if (email.isNotEmpty && password.length >= 8) {
      _currentUser = UserModel(name: 'Kamal Perera', email: email);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mock Register Function
  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(name: name, email: email);
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
