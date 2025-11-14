import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // ===== Estados =====
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _role;
  String? get role => _role;

  String? _userName;
  String? get userName => _userName;

  int? _userId;
  int? get userId => _userId;

  String? _token;
  String? get token => _token;

  bool _perfilCompleto = false;
  bool get perfilCompleto => _perfilCompleto;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ===== LOGIN =====
  Future<String?> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);

      if (response != null) {
        _role = response['rol'] ?? '';
        _userName = response['user']?['nombre'] ?? '';
        _userId = response['user']?['id'] ?? 0;
        _token = response['token'] ?? '';
        _perfilCompleto = response['perfilCompleto'] ?? false;

        isLoading = false;
        notifyListeners();
        return _role;
      }
    } catch (e) {
      debugPrint('Error en login: $e');
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  // 🔹 Actualizar perfil completado manualmente
  void setPerfilCompleto(bool value) {
    _perfilCompleto = value;
    notifyListeners();
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
    _userId = null;
    _token = null;
    _perfilCompleto = false;
    notifyListeners();
  }
}
