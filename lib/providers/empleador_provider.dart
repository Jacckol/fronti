import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmpleadorProvider extends ChangeNotifier {
  Map<String, dynamic>? perfil;
  bool loading = false;

  final String baseUrl = "http://10.0.2.2:4000/api/perfil/mine";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // =====================================================
  // GET PERFIL
  // =====================================================
  Future<void> fetchPerfil() async {
    loading = true;
    notifyListeners();

    final token = await _getToken();

    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        perfil = {
          "nombreCompleto": data["nombreCompleto"] ?? "",
          "telefono": data["telefono"] ?? "",
          "categoria": data["categoria"] ?? "",
          "direccion": data["direccion"] ?? "",
          "experiencia": data["experiencia"] ?? 0,
          "habilidades": data["habilidades"] ?? [],
        };
      } else {
        perfil = null;
      }
    } catch (e) {
      print("❌ ERROR FETCH PERFIL: $e");
      perfil = null;
    }

    loading = false;
    notifyListeners();
  }

  // =====================================================
  // PUT PERFIL (CAMPOS BÁSICOS)
  // =====================================================
  Future<bool> savePerfil({
    required String nombreCompleto,
    required String telefono,
    required String ubicacion,
    required String categoria,
    required int experiencia,
    required List<String> habilidades,
  }) async {
    loading = true;
    notifyListeners();

    final token = await _getToken();

    try {
      final res = await http.put(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "nombreCompleto": nombreCompleto,
          "telefono": telefono,
          "direccion": ubicacion,
          "categoria": categoria,
          "experiencia": experiencia,
          "habilidades": habilidades,
        }),
      );

      if (res.statusCode == 200) {
        await fetchPerfil();
        return true;
      }
    } catch (e) {
      print("❌ ERROR SAVE PERFIL: $e");
    }

    loading = false;
    notifyListeners();
    return false;
  }

  // =====================================================
  // SUBIR FOTO
  // =====================================================
  Future<bool> uploadFoto(File file) async {
    final token = await _getToken();
    final url = Uri.parse("http://10.0.2.2:4000/api/perfil/upload-foto");

    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(await http.MultipartFile.fromPath("foto", file.path));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("📸 FOTO UPLOAD: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ ERROR UPLOAD FOTO: $e");
      return false;
    }
  }

  // =====================================================
  // SUBIR CV
  // =====================================================
  Future<bool> uploadCv(File file) async {
    final token = await _getToken();
    final url = Uri.parse("http://10.0.2.2:4000/api/perfil/upload-cv");

    final request = http.MultipartRequest("POST", url);
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(await http.MultipartFile.fromPath("cv", file.path));

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print("📄 CV UPLOAD: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ ERROR UPLOAD CV: $e");
      return false;
    }
  }
}
