import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum EstadoPostulacion { pendiente, aceptada, rechazada }

class Postulacion {
  final int id;
  final int trabajoId;
  final String titulo;
  final String categoria;
  final String empleador;
  final String ubicacion;
  final double presupuesto;
  final String duracion;
  final String mensaje;
  final DateTime fecha;

  EstadoPostulacion estado;

  Postulacion({
    required this.id,
    required this.trabajoId,
    required this.titulo,
    required this.categoria,
    required this.empleador,
    required this.ubicacion,
    required this.presupuesto,
    required this.duracion,
    required this.mensaje,
    required this.fecha,
    this.estado = EstadoPostulacion.pendiente,
  });

  factory Postulacion.fromJson(Map<String, dynamic> json) {
    final trabajo = json["trabajo"] ?? {};
    final postulante = json["postulante"] ?? {};

    return Postulacion(
      id: json['id'],
      trabajoId: json['trabajoId'],
      titulo: trabajo['titulo'] ?? "Sin título",
      categoria: trabajo['categoria'] ?? "Sin categoría",
      empleador: postulante['nombre'] ?? "Desconocido",
      ubicacion: trabajo['ubicacion'] ?? "",
      presupuesto: double.tryParse((trabajo['salario'] ?? "0").toString()) ?? 0,
      duracion: trabajo['duracion'] ?? "",
      mensaje: json['mensaje'] ?? "",
      fecha: DateTime.parse(json['createdAt']),
      estado: _estadoFromString(json['estado']),
    );
  }

  static EstadoPostulacion _estadoFromString(String estado) {
    switch (estado) {
      case "aceptado":
        return EstadoPostulacion.aceptada;
      case "rechazado":
        return EstadoPostulacion.rechazada;
      default:
        return EstadoPostulacion.pendiente;
    }
  }
}

class PostulacionesProvider extends ChangeNotifier {
  final String baseUrl = "http://10.0.2.2:4000";

  List<Postulacion> _postulaciones = [];

  // ====================================
  // GETTERS
  // ====================================

  List<Postulacion> get todas => _postulaciones;

  List<Postulacion> get pendientes =>
      _postulaciones.where((p) => p.estado == EstadoPostulacion.pendiente).toList();

  List<Postulacion> get aceptadas =>
      _postulaciones.where((p) => p.estado == EstadoPostulacion.aceptada).toList();

  List<Postulacion> get rechazadas =>
      _postulaciones.where((p) => p.estado == EstadoPostulacion.rechazada).toList();

  int get totalPendientes => pendientes.length;
  int get totalAceptadas => aceptadas.length;
  int get totalRechazadas => rechazadas.length;

  // ====================================
  // CARGAR POSTULACIONES DEL BACKEND
  // ====================================

  Future<void> cargarPostulaciones(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/api/postulaciones/usuario/$userId");
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        if (data is List) {
          _postulaciones =
              data.map<Postulacion>((p) => Postulacion.fromJson(p)).toList();
        } else {
          _postulaciones = [];
        }
      } else {
        print("❌ Error cargarPostulaciones: ${resp.statusCode}");
      }
    } catch (e) {
      print("❌ ERROR cargarPostulaciones: $e");
    }

    notifyListeners();
  }

  // ====================================
  // CREAR POSTULACIÓN COMPLETA
  // ====================================

  Future<bool> crearPostulacion({
    required int trabajoId,
    required int userId,
    required String mensaje,

    // 🔥 OBLIGATORIOS POR TU UI
    required String titulo,
    required String categoria,
    required String empleador,
    required String ubicacion,
    required double presupuesto,
    required String duracion,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/postulaciones");

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "trabajoId": trabajoId,
          "userId": userId,
          "mensaje": mensaje,
        }),
      );

      print("🟪 RESP crearPostulacion: ${resp.statusCode} | ${resp.body}");

      if (resp.statusCode == 201) {
        /// GUARDAR LOCALMENTE PARA TU UI
        final nueva = Postulacion(
          id: DateTime.now().millisecondsSinceEpoch,
          trabajoId: trabajoId,
          titulo: titulo,
          categoria: categoria,
          empleador: empleador,
          ubicacion: ubicacion,
          presupuesto: presupuesto,
          duracion: duracion,
          mensaje: mensaje,
          fecha: DateTime.now(),
        );

        _postulaciones.insert(0, nueva);
        notifyListeners();

        return true;
      }
    } catch (e) {
      print("❌ ERROR crearPostulacion: $e");
    }

    return false;
  }

  // ====================================
  // ACTUALIZAR ESTADO LOCAL
  // ====================================

  void actualizarEstadoLocal(int id, EstadoPostulacion nuevoEstado) {
    final index = _postulaciones.indexWhere((p) => p.id == id);
    if (index != -1) {
      _postulaciones[index].estado = nuevoEstado;
      notifyListeners();
    }
  }

  // ====================================
  // ELIMINAR POSTULACIÓN LOCAL
  // ====================================

  void eliminarPostulacionLocal(int id) {
    _postulaciones.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ====================================
  // LIMPIAR TODO
  // ====================================

  void limpiar() {
    _postulaciones = [];
    notifyListeners();
  }
}
