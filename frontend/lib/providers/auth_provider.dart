import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool loading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    final err = await _authService.login(email, password);

    loading = false;

    if (err != null) {
      error = err;
      notifyListeners();
      return false;
    }

    notifyListeners();
    return true;
  }
  //Add signup logic
  Future<bool> signup(String email, String password) async {
  loading = true;
  error = null;
  notifyListeners();

  final err = await _authService.signup(email, password);

  loading = false;

  if (err != null) {
    error = err;
    notifyListeners();
    return false;
  }

  notifyListeners();
  return true;
}
// Add forgot password logic
Future<bool> sendOtp(String email) async {
  loading = true;
  error = null;
  notifyListeners();

  final err = await _authService.forgotPassword(email);

  loading = false;

  if (err != null) {
    error = err;
    notifyListeners();
    return false;
  }

  notifyListeners();
  return true;
}


}
