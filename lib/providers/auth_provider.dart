import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // ===== Estados =====
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _role;      // rol del usuario
  String? get role => _role;

  String? _userName;  // nombre del usuario
  String? get userName => _userName;

  int? _userId;       // id del usuario
  int? get userId => _userId;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ===== LOGIN =====
  Future<String?> login(String username, String password) async {
    isLoading = true;

    final response = await _authService.login(username, password);
    if (response != null) {
      _role = response['rol'];
      _userName = response['nombre'];
      _userId = response['id']; // ✅ Guardar ID real
      isLoading = false;
      notifyListeners();
      return _role;
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  // ===== REGISTRO USUARIO =====
  Future<bool> registerUser(String username, String password, String email) async {
    isLoading = true;
    notifyListeners();

    final ok = await _authService.registerUser(username, password, email);

    isLoading = false;
    notifyListeners();
    return ok;
  }

  // ===== REGISTRO EMPLEADOR =====
  Future<bool> registerEmployer(String companyName, String username, String password, String email) async {
    isLoading = true;
    notifyListeners();

    final ok = await _authService.registerEmployer(companyName, username, password, email);

    isLoading = false;
    notifyListeners();
    return ok;
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    await _authService.logout();
    _role = null;
    _userName = null;
    _userId = null; // ✅ Limpiar ID
    notifyListeners();
  }
}
