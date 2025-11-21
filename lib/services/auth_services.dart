import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 🌍 IMPORTANTE: desde el EMULADOR, el backend de tu PC es 10.0.2.2
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
        print('✅ Login exitoso: $data');

        // 🔹 Normalmente el backend manda algo tipo:
        // { user: {...}, rol: 'empleador', token: '...', perfilCompleto: true/false }
        return {
          'rol': data['rol'] ?? data['user']?['rol'],
          'user': data['user'],
          'token': data['token'] ?? '',
          'perfilCompleto': data['perfilCompleto'] ?? false,
        };
      } else {
        final data = jsonDecode(response.body);
        print('❌ Error en login: ${data['error'] ?? response.body}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error de conexión en login: $e');
      return null;
    }
  }

  // =====================================================
  // 🟩 REGISTRO DE USUARIO NORMAL
  // =====================================================
  Future<bool> registerUser(String username, String password, String email) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': username,
          'email': email,
          'password': password,
          'rol': 'cliente',
        }),
      );

      final data = jsonDecode(response.body);
      print('📨 Respuesta registro usuario: $data');

      if (response.statusCode == 201) {
        print('✅ Usuario registrado correctamente');
        return true;
      }

      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      return false;
    } catch (e) {
      print('❌ Error en registro de usuario: $e');
      throw Exception('No se pudo registrar el usuario: $e');
    }
  }

  // =====================================================
  // 🟨 REGISTRO DE EMPLEADOR
  // =====================================================
  Future<bool> registerEmployer(
    String companyName,
    String username,
    String password,
    String email, {
    String? ruc,
    String? telefono,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': username,
          'email': email,
          'password': password,
          'rol': 'empleador',
          'empresa': companyName,
          'ruc': ruc ?? '1234567890',
          'telefono': telefono ?? '0999999999',
        }),
      );

      final data = jsonDecode(response.body);
      print('📨 Respuesta registro empleador: $data');

      if (response.statusCode == 201) {
        print('✅ Empleador registrado correctamente');
        return true;
      }

      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      return false;
    } catch (e) {
      print('❌ Error en registro de empleador: $e');
      throw Exception('No se pudo registrar el empleador: $e');
    }
  }

  // =====================================================
  // 🟩 GUARDAR PERFIL LABORAL
  // =====================================================
  Future<bool> savePerfilLaboral(Map<String, dynamic> perfilData, String token) async {
    final url = Uri.parse('$baseUrl/perfil-laboral');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(perfilData),
      );

      print('📨 Respuesta perfil laboral: ${response.body}');

      if (response.statusCode == 201) {
        print('✅ Perfil laboral guardado correctamente');
        return true;
      } else {
        print('❌ Error guardando perfil laboral: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error de conexión al guardar perfil laboral: $e');
      return false;
    }
  }

  // =====================================================
  // 🔴 LOGOUT
  // =====================================================
  Future<void> logout() async {
    print('🚪 Sesión cerrada');
    return;
  }
}
