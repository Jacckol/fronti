import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PerfilEmpleadorService {
  static const String baseUrl = "http://10.0.2.2:4000/api/empleadores/perfil";

  static Future<http.Response> crearPerfil({
    required String token,
    required Map<String, String> data,
    File? foto,
    File? cv,
    required File recordPolicial,
  }) async {
    final uri = Uri.parse(baseUrl);
    final request = http.MultipartRequest("POST", uri);

    request.headers["Authorization"] = "Bearer $token";

    // 🔹 Campos texto
    request.fields.addAll(data);

    // 🔹 Foto
    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath("foto", foto.path),
      );
    }

    // 🔹 CV
    if (cv != null) {
      request.files.add(
        await http.MultipartFile.fromPath("cv", cv.path),
      );
    }

    // 🔹 Récord policial (OBLIGATORIO)
    request.files.add(
      await http.MultipartFile.fromPath(
        "recordPolicial",
        recordPolicial.path,
      ),
    );

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }
}
