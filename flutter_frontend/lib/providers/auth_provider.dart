import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _role; // guarda el rol del usuario logueado
  String? get role => _role;

  String? _userName; // guarda el nombre del usuario logueado
  String? get userName => _userName;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ===== LOGIN =====
  Future<String?> login(String username, String password) async {
    isLoading = true;

    // 🔹 login devuelve un mapa con rol y nombre
    final response = await _authService.login(username, password);

    if (response != null) {
      _role = response['rol'];
      _userName = response['nombre'];
      isLoading = false;
      notifyListeners();
      return _role;
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  // ===== REGISTRO USUARIO NORMAL =====
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
    notifyListeners();
  }
}
