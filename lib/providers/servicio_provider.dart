import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServicioProvider extends ChangeNotifier {
  // ⭐ Conexión desde emulador hacia backend local
  final String _baseUrl = "http://10.0.2.2:4000/api/servicios";

  // ======================================================
  // 🔹 PUBLICAR SERVICIO (POST)
  // ======================================================
  Future<bool> publicarServicio({
    required String titulo,
    required String categoria,
    required String descripcion,
    required String ubicacion,
    required double presupuesto,
    required int userId, // ⭐ ahora dinámico
  }) async {
    try {
      final url = Uri.parse(_baseUrl);

      final resp = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "titulo": titulo,
          "categoria": categoria,
          "descripcion": descripcion,
          "ubicacion": ubicacion,
          "presupuesto": presupuesto,
          "userId": userId,
        }),
      );

      print("📩 RESPUESTA BACKEND:");
      print(resp.body);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return true;
      } else {
        print("❌ Error: código ${resp.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error publicando servicio: $e");
      return false;
    }
  }
}
