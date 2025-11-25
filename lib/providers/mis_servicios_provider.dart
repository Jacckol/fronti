import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MisServiciosProvider extends ChangeNotifier {
  final String baseUrl = "http://10.0.2.2:4000/api/servicios";

  List<dynamic> misServicios = [];

  // ======================================================
  // 🔹 Cargar servicios publicados por un usuario
  // ======================================================
  Future<List<dynamic>> cargarMisServicios(int userId) async {
    try {
      final url = Uri.parse("$baseUrl?userId=$userId");

      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        misServicios = jsonDecode(resp.body);
        notifyListeners();
        return misServicios;
      } else {
        print("❌ Error backend: ${resp.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error cargarMisServicios: $e");
      return [];
    }
  }

  // ======================================================
  // 🔹 EDITAR SERVICIO (PUT)
  // ======================================================
  Future<bool> editarServicio({
    required int id,
    required String titulo,
    required String categoria,
    required String descripcion,
    required String ubicacion,
    required double presupuesto,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/$id");

      final resp = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "titulo": titulo,
          "categoria": categoria,
          "descripcion": descripcion,
          "ubicacion": ubicacion,
          "presupuesto": presupuesto,
        }),
      );

      print("📌 RESPUESTA EDITAR: ${resp.body}");

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        // actualizar lista local
        final index = misServicios.indexWhere((s) => s["id"] == id);
        if (index != -1) {
          misServicios[index] = data;
          notifyListeners();
        }

        return true;
      }

      return false;
    } catch (e) {
      print("❌ Error editar servicio: $e");
      return false;
    }
  }

  // ======================================================
  // 🔹 ELIMINAR SERVICIO POR ID
  // ======================================================
  Future<bool> eliminarServicio(int id) async {
    try {
      final url = Uri.parse("$baseUrl/$id");

      final resp = await http.delete(url);

      if (resp.statusCode == 200) {
        misServicios.removeWhere((s) => s["id"] == id);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print("❌ Error eliminar servicio: $e");
      return false;
    }
  }
}
