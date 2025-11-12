import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Provider para manejar el perfil del empleador
class EmpleadorProvider extends ChangeNotifier {
  Map<String, dynamic>? perfil; // Perfil del empleador
  bool loading = false; // Estado de carga
  int? empleadorId; // ID real del empleador en la DB

  /// URL base del backend
  final String baseUrl = 'http://localhost:4000/api/perfil-empleador';

  /// 🔹 Getters útiles para la UI
  String get nombre => perfil?['nombre'] ?? '';
  String get telefono => perfil?['telefono'] ?? '';
  String get ubicacion => perfil?['ubicacion'] ?? '';
  String get categoria => perfil?['categoria'] ?? '';
  int get experiencia => perfil?['experiencia'] ?? 0;
  String get biografia => perfil?['biografia'] ?? '';
  List<String> get habilidades {
    final h = perfil?['habilidades'];
    if (h is List) return List<String>.from(h);
    return [];
  }

  /// 🔹 Obtener perfil usando userId
  /// Este endpoint espera que tu backend tenga /user/:userId
  Future<void> fetchPerfil(int userId) async {
    loading = true;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse('$baseUrl/user/$userId'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        perfil = data['perfil'];
        empleadorId = data['empleadorId'];
      } else if (res.statusCode == 404) {
        perfil = null;
        empleadorId = null;
        debugPrint('Perfil no encontrado para userId=$userId');
      } else {
        perfil = null;
        empleadorId = null;
        debugPrint('Error fetchPerfil ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      perfil = null;
      empleadorId = null;
      debugPrint('Excepción fetchPerfil: $e');
    }

    loading = false;
    notifyListeners();
  }

  /// 🔹 Guardar o actualizar perfil
  /// Si no existe perfil, el backend debe crear uno con POST
  Future<bool> savePerfil({
    String? ubicacion,
    String? categoria,
    int? experiencia,
    String? biografia,
    List<String>? habilidades,
    File? fotoFile,
    File? cvFile,
  }) async {
    if (empleadorId == null) {
      debugPrint('No se puede guardar perfil: empleadorId es null');
      return false;
    }

    loading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/$empleadorId');
      final request = http.MultipartRequest('PUT', uri);

      // Campos de texto
      request.fields['ubicacion'] = ubicacion ?? '';
      request.fields['categoria'] = categoria ?? '';
      request.fields['experiencia'] = (experiencia ?? 0).toString();
      request.fields['biografia'] = biografia ?? '';
      request.fields['habilidades'] = jsonEncode(habilidades ?? []);

      // Archivos (foto y CV)
      if (fotoFile != null) {
        final stream = http.ByteStream(fotoFile.openRead());
        final length = await fotoFile.length();
        request.files.add(
          http.MultipartFile(
            'foto',
            stream,
            length,
            filename: fotoFile.path.split(Platform.pathSeparator).last,
          ),
        );
      }

      if (cvFile != null) {
        final stream = http.ByteStream(cvFile.openRead());
        final length = await cvFile.length();
        request.files.add(
          http.MultipartFile(
            'cv',
            stream,
            length,
            filename: cvFile.path.split(Platform.pathSeparator).last,
          ),
        );
      }

      // Enviar request
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        perfil = data['perfil'] ?? perfil;
        loading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('savePerfil error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint('Excepción savePerfil: $e');
    }

    loading = false;
    notifyListeners();
    return false;
  }

  /// 🔹 Limpiar perfil (por ejemplo al cerrar sesión)
  void clearPerfil() {
    perfil = null;
    empleadorId = null;
    notifyListeners();
  }
}
