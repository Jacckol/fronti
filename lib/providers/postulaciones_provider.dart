import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ======================================================
// ENUM ESTADOS
// ======================================================
enum EstadoPostulacion { pendiente, aceptada, rechazada }

EstadoPostulacion estadoFromString(String estado) {
  switch (estado) {
    case "aceptado":
      return EstadoPostulacion.aceptada;
    case "rechazado":
      return EstadoPostulacion.rechazada;
    default:
      return EstadoPostulacion.pendiente;
  }
}

// ======================================================
// MODELO POSTULACIÓN (para TRABAJOS - no rompe tu app)
// ======================================================
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
    required this.estado,
  });

  factory Postulacion.fromJson(Map<String, dynamic> json) {
    // ✅ SOLO AUMENTO: soporta "trabajo" o "Trabajo"
    final trabajo = (json["trabajo"] ?? json["Trabajo"] ?? {}) as Map;

    return Postulacion(
      id: _toInt(json["id"]),
      trabajoId: _toInt(trabajo["id"]),
      titulo: (trabajo["titulo"] ?? "Sin título").toString(),
      categoria: (trabajo["categoria"] ?? "General").toString(),
      empleador: "Empleador",
      ubicacion: (trabajo["ubicacion"] ?? "").toString(),
      presupuesto: 0,
      duracion: "",
      mensaje: (json["mensaje"] ?? "").toString(),
      fecha: DateTime.tryParse((json["createdAt"] ?? "").toString()) ?? DateTime.now(),
      estado: estadoFromString((json["estado"] ?? "pendiente").toString()),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

// ======================================================
// PROVIDER POSTULACIONES
// ======================================================
class PostulacionesProvider extends ChangeNotifier {
  final String baseUrl = "http://10.0.2.2:4000";

  List<Postulacion> _postulaciones = [];

  // ======================================================
  // GETTERS
  // ======================================================
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

  // ======================================================
  // 🔥 CARGAR POSTULACIONES (TRABAJOS) POR USUARIO (TRABAJADOR)
  // GET /api/postulaciones/usuario/:userId
  // ======================================================
  Future<void> cargarPostulaciones(int userId) async {
    try {
      final url = Uri.parse("$baseUrl/api/postulaciones/usuario/$userId");
      final resp = await http.get(url);

      debugPrint("📥 GET cargarPostulaciones => $url");
      debugPrint("📥 status=${resp.statusCode} body=${resp.body}");

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);

        // ✅ SOLO AUMENTO:
        // soporta:
        // A) backend devuelve lista directa: [ ... ]
        // B) backend devuelve objeto: { "postulaciones": [ ... ] }
        List lista = [];

        if (decoded is List) {
          lista = decoded;
        } else if (decoded is Map && decoded["postulaciones"] is List) {
          lista = decoded["postulaciones"];
        } else if (decoded is Map && decoded["data"] is List) {
          // por si tu backend usa "data"
          lista = decoded["data"];
        }

        _postulaciones = lista
            .map<Postulacion>((p) => Postulacion.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        _postulaciones = [];
      }
    } catch (e) {
      debugPrint("❌ ERROR cargarPostulaciones: $e");
      _postulaciones = [];
    }

    notifyListeners();
  }

  // alias
  Future<void> cargarDesdeBackend(int userId) async {
    await cargarPostulaciones(userId);
  }

  // ======================================================
  // ✅ CREAR POSTULACIÓN A TRABAJO (TRABAJADOR → EMPLEADOR)
  // POST /api/postulaciones
  // ======================================================
  Future<bool> crearPostulacion({
    required int trabajoId,
    required int userId,
    required String mensaje,

    // Campos UI inmediata (no afectan backend)
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

      if (resp.statusCode == 201) {
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
          estado: EstadoPostulacion.pendiente,
        );

        _postulaciones.insert(0, nueva);
        notifyListeners();
        return true;
      }

      debugPrint("❌ crearPostulacion(trabajo) status: ${resp.statusCode} body: ${resp.body}");
      return false;
    } catch (e) {
      debugPrint("❌ ERROR crearPostulacion(trabajo): $e");
      return false;
    }
  }

  // ======================================================
  // ✅ CREAR POSTULACIÓN A SERVICIO (EMPLEADOR → TRABAJADOR)
  // POST /api/servicios/:servicioId/postulaciones
  // body: { userId, mensaje }
  // ======================================================
  Future<bool> crearPostulacionServicio({
    required int servicioId,
    required int userId,
    required String mensaje,
    String? empresa,
  }) async {
    try {
      if (servicioId <= 0) {
        debugPrint("❌ crearPostulacionServicio: servicioId inválido => $servicioId");
        return false;
      }

      final url = Uri.parse("$baseUrl/api/servicios/$servicioId/postulaciones");

      debugPrint("📤 POST crearPostulacionServicio => $url");
      debugPrint("📤 servicioId=$servicioId userId=$userId mensaje_len=${mensaje.length}");

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "mensaje": mensaje,
        }),
      );

      debugPrint("📥 crearPostulacionServicio status: ${resp.statusCode} body: ${resp.body}");

      if (resp.statusCode == 201) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("❌ ERROR crearPostulacionServicio: $e");
      return false;
    }
  }

  // ======================================================
  // ✅ CAMBIAR ESTADO POSTULACIÓN DE SERVICIO
  // PUT /api/servicios/postulaciones/:id/estado
  // body: { estado: "aceptado" | "rechazado" }
  // ======================================================
  Future<bool> cambiarEstadoPostulacion({
    required int postulacionId,
    required String estado,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/servicios/postulaciones/$postulacionId/estado");

      final resp = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"estado": estado}),
      );

      if (resp.statusCode == 200) return true;

      debugPrint("❌ cambiarEstadoPostulacion status: ${resp.statusCode} body: ${resp.body}");
      return false;
    } catch (e) {
      debugPrint("❌ ERROR cambiarEstadoPostulacion: $e");
      return false;
    }
  }

  // ======================================================
  // ✅ NUEVO: OBTENER POSTULACIONES DE UN SERVICIO (para Mis Publicaciones)
  // GET /api/servicios/:servicioId/postulaciones
  // Devuelve List<Map> para tu modal SIN tocar tu modelo Postulacion (trabajos).
  // ======================================================
  Future<List<Map<String, dynamic>>> obtenerPostulacionesServicio(int servicioId) async {
    try {
      if (servicioId <= 0) return [];

      final url = Uri.parse("$baseUrl/api/servicios/$servicioId/postulaciones");

      debugPrint("📥 GET obtenerPostulacionesServicio => $url");

      final resp = await http.get(url);

      debugPrint("📥 status=${resp.statusCode} body=${resp.body}");

      if (resp.statusCode != 200) return [];

      final decoded = jsonDecode(resp.body);
      return _toMapList(decoded);
    } catch (e) {
      debugPrint("❌ ERROR obtenerPostulacionesServicio: $e");
      return [];
    }
  }

  // ======================================================
  // ✅ Helper: soporta [] o {postulaciones: []} o {data: []}
  // ======================================================
  List<Map<String, dynamic>> _toMapList(dynamic decoded) {
    List lista = [];

    if (decoded is List) {
      lista = decoded;
    } else if (decoded is Map && decoded["postulaciones"] is List) {
      lista = decoded["postulaciones"];
    } else if (decoded is Map && decoded["data"] is List) {
      lista = decoded["data"];
    }

    return lista
        .where((e) => e is Map)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ======================================================
  // UTILIDADES LOCALES
  // ======================================================
  void actualizarEstadoLocal(int id, EstadoPostulacion nuevoEstado) {
    final index = _postulaciones.indexWhere((p) => p.id == id);
    if (index != -1) {
      _postulaciones[index].estado = nuevoEstado;
      notifyListeners();
    }
  }

  void eliminarPostulacionLocal(int id) {
    _postulaciones.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void limpiar() {
    _postulaciones.clear();
    notifyListeners();
  }
}
