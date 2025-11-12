import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ⚠️ Para Flutter Web local, usa localhost con el puerto correcto de tu backend Express
  final String baseUrl = 'http://localhost:4000/api';

  // =====================================================
  // 🟦 LOGIN (devuelve id, nombre, rol, telefono)
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

        // 🔹 Estructura esperada del backend:
        // {
        //   "token": "jwt-token",
        //   "user": {
        //     "id": 1,
        //     "nombre": "Juan Pérez",
        //     "rol": "empleador",
        //     "telefono": "0999999999"
        //   }
        // }

        final user = data['user'] ?? data; // por compatibilidad

        return {
          'id': user['id'],
          'nombre': user['nombre'],
          'rol': user['rol'],
          'telefono': user['telefono'] ?? 'No registrado',
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
          'rol': 'cliente', // ✅ coincide con ENUM del backend
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
          'rol': 'empleador', // ✅ coincide con ENUM del backend
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
  // 🔴 LOGOUT
  // =====================================================
  Future<void> logout() async {
    print('🚪 Sesión cerrada');
    return;
  }
}
