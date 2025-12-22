import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/perfil_empleador_service.dart';

class PerfilEmpleadorProvider extends ChangeNotifier {
  bool loading = false;
  String? error;

  Future<bool> crearPerfil({
    required String token,
    required Map<String, String> data,
    File? foto,
    File? cv,
    required File recordPolicial,
  }) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final resp = await PerfilEmpleadorService.crearPerfil(
        token: token,
        data: data,
        foto: foto,
        cv: cv,
        recordPolicial: recordPolicial,
      );

      if (resp.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(resp.body);
        error = body["message"] ?? "Error al crear perfil";
        return false;
      }
    } catch (e) {
      error = "Error de conexión";
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
