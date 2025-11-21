import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

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

  // ===========================================================
  // 🔹 LOGIN (GUARDA TOKEN Y DATOS)
  // ===========================================================
  Future<String?> login(String username, String password) async {
    isLoading = true;

    try {
      final response = await _authService.login(username, password);

      if (response != null) {
        final user = response['user'] ?? {};

        _role = response['rol'];
        _userName = user['nombre'] ?? 'Usuario';
        _userId = user['id'];
        _token = response['token'];

        // GUARDAR EN LOCAL
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token ?? '');
        await prefs.setInt('userId', _userId ?? 0);
        await prefs.setString('role', _role ?? '');
        await prefs.setString('userName', _userName ?? '');

        _perfilCompleto = false;

        isLoading = false;
        notifyListeners();
        return _role;
      }
    } catch (e) {
      print("❌ Error login provider: $e");
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  // ===========================================================
  // 🔹 REGISTRO USUARIO
  // ===========================================================
  Future<bool> registerUser(String username, String password, String email) async {
    isLoading = true;
    notifyListeners();

    final ok = await _authService.registerUser(username, password, email);

    isLoading = false;
    notifyListeners();
    return ok;
  }

  // ===========================================================
  // 🔹 REGISTRO EMPLEADOR
  // ===========================================================
  Future<bool> registerEmployer(
      String companyName, String username, String password, String email) async {
    isLoading = true;
    notifyListeners();

    final ok = await _authService.registerEmployer(
        companyName, username, password, email);

    isLoading = false;
    notifyListeners();
    return ok;
  }

  // ===========================================================
  // 🔹 PERFIL COMPLETO
  // ===========================================================
  void setPerfilCompleto(bool value) {
    _perfilCompleto = value;
    notifyListeners();
  }

  // ===========================================================
  // 🔹 CARGAR DATOS GUARDADOS
  // ===========================================================
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _userName = prefs.getString('userName');
    _userId = prefs.getInt('userId');

    notifyListeners();
  }

  // ===========================================================
  // 🔹 LOGOUT
  // ===========================================================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _role = null;
    _userName = null;
    _userId = null;
    _token = null;
    _perfilCompleto = false;

    notifyListeners();
  }
}
