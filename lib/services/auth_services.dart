import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:4000/api';

  // =====================================================
  // 🟦 LOGIN
  // =====================================================
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'rol': data['rol'] ?? data['user']?['rol'],
          'user': data['user'] ?? {},
          'token': data['token'] ?? '',
          'perfilCompleto': data['perfilCompleto'] ?? false,
        };
      }

      return null;
    } catch (e) {
      print("❌ Error login: $e");
      return null;
    }
  }

  // =====================================================
  // 🟩 REGISTRO USUARIO NORMAL
  // =====================================================
  Future<bool> registerUser(String nombre, String password, String email) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': 'usuario'
        }),
      );

      return res.statusCode == 201;

    } catch (e) {
      print("❌ Error registrando usuario: $e");
      return false;
    }
  }

  // =====================================================
  // 🟨 REGISTRO TRABAJADOR — CORRECTO
  // =====================================================
  Future<bool> registerWorker({
    required String nombre,
    required String usuario,
    required String email,
    required String password,
    required String telefono,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'usuario': usuario,
          'email': email,
          'password': password,
          'telefono': telefono,
          'rol': 'trabajador'
        }),
      );

      print("📨 Registro trabajador → ${res.body}");

      return res.statusCode == 201;

    } catch (e) {
      print("❌ Error registrando trabajador: $e");
      return false;
    }
  }

  // =====================================================
  // 🟧 GUARDAR PERFIL LABORAL
  // =====================================================
  Future<bool> savePerfilLaboral(Map perfil, String token) async {
    final url = Uri.parse('$baseUrl/perfil-laboral');

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(perfil),
      );

      return res.statusCode == 201;

    } catch (e) {
      print("❌ Error guardando perfil: $e");
      return false;
    }
  }
}
