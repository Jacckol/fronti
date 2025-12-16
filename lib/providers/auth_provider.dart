import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ============================================================
  // 🔹 CAMPOS DEL USUARIO
  // ============================================================
  String? _role;                // "trabajador" | "empleador"
  String? _userName;            // nombre
  int? _userId;                 // ID tabla users
  int _empleadorId = 0;         // ID tabla empleadores
  int _trabajadorId = 0;        // ID tabla trabajadores
  String? _token;
  bool _perfilCompleto = false;

  // ============================================================
  // 🔹 GETTERS
  // ============================================================
  String? get role => _role;
  String? get userName => _userName;
  int? get userId => _userId;
  int get empleadorId => _empleadorId;
  int get trabajadorId => _trabajadorId;
  String? get token => _token;
  bool get perfilCompleto => _perfilCompleto;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ============================================================
  // 🔹 LOGIN
  // ============================================================
  Future<String?> login(String email, String password) async {
    isLoading = true;

    try {
      final response = await _authService.login(email, password);
      debugPrint("🟡 RESPONSE LOGIN: $response");

      if (response != null) {
        final user = response["user"] ?? {};
        final empleadorData = response["empleador"];
        final trabajadorData = response["trabajador"];

        // Datos base
        _role = response["rol"]; // ⚠️ el backend manda "rol"
        _userName = user["nombre"] ?? "Usuario";
        _userId = user["id"];
        _token = response["token"];
        _perfilCompleto = response["perfilCompleto"] ?? false;

        // IDs correctos
        _empleadorId =
            (empleadorData != null && empleadorData["id"] != null)
                ? empleadorData["id"]
                : 0;

        _trabajadorId =
            (trabajadorData != null && trabajadorData["id"] != null)
                ? trabajadorData["id"]
                : 0;

        debugPrint(
          "✅ LOGIN OK → role=$_role empleadorId=$_empleadorId trabajadorId=$_trabajadorId",
        );

        // Guardar sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", _token ?? "");
        await prefs.setString("role", _role ?? "");
        await prefs.setString("userName", _userName ?? "");
        await prefs.setInt("userId", _userId ?? 0);
        await prefs.setInt("empleadorId", _empleadorId);
        await prefs.setInt("trabajadorId", _trabajadorId);
        await prefs.setBool("perfilCompleto", _perfilCompleto);

        isLoading = false;
        notifyListeners();
        return _role;
      }
    } catch (e) {
      debugPrint("❌ Error en login Provider: $e");
    }

    isLoading = false;
    notifyListeners();
    return null;
  }

  // ============================================================
  // 🔹 REGISTRO USUARIO BASE
  // ============================================================
  Future<bool> registerUser(
    String nombre,
    String password,
    String email,
  ) async {
    isLoading = true;
    notifyListeners();

    final ok = await _authService.registerUser(
      nombre,
      password,
      email,
    );

    isLoading = false;
    notifyListeners();
    return ok;
  }

  // ============================================================
  // 🔹 REGISTRO TRABAJADOR
  // ============================================================
  Future<bool> registerWorker(
    String nombre,
    String username,
    String password,
    String email,
    String telefono,
  ) async {
    isLoading = true;
    notifyListeners();

    final ok = await _authService.registerWorker(
      nombre: nombre,
      usuario: username,
      email: email,
      password: password,
      telefono: telefono,
    );

    isLoading = false;
    notifyListeners();
    return ok;
  }

  // ============================================================
  // 🔹 PERFIL COMPLETO
  // ============================================================
  Future<void> setPerfilCompleto(bool value) async {
    _perfilCompleto = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("perfilCompleto", value);

    notifyListeners();
  }

  // ============================================================
  // 🔹 CARGAR SESIÓN
  // ============================================================
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    _token = prefs.getString("token");
    _role = prefs.getString("role");
    _userName = prefs.getString("userName");
    _userId = prefs.getInt("userId");
    _empleadorId = prefs.getInt("empleadorId") ?? 0;
    _trabajadorId = prefs.getInt("trabajadorId") ?? 0;
    _perfilCompleto = prefs.getBool("perfilCompleto") ?? false;

    notifyListeners();
  }

  // ============================================================
  // 🔹 LOGOUT
  // ============================================================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _role = null;
    _userName = null;
    _userId = null;
    _empleadorId = 0;
    _trabajadorId = 0;
    _token = null;
    _perfilCompleto = false;

    notifyListeners();
  }
}
