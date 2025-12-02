import 'package:flutter/material.dart';

/// ===========================================================
/// 🔹 ENUM – Estado de la postulación
/// ===========================================================
enum EstadoPostulacion { pendiente, aceptada, rechazada }

/// ===========================================================
/// 🔹 Modelo de una Postulación
/// ===========================================================
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
}

/// ===========================================================
/// 🔹 Provider de Postulaciones
/// ===========================================================
class PostulacionesProvider extends ChangeNotifier {
  final List<Postulacion> _postulaciones = [];
  int _autoId = 1;

  // Todas
  List<Postulacion> get todas => List.unmodifiable(_postulaciones);

  // Filtros
  List<Postulacion> get pendientes =>
      _postulaciones.where((p) => p.estado == EstadoPostulacion.pendiente).toList();

  List<Postulacion> get aceptadas =>
      _postulaciones.where((p) => p.estado == EstadoPostulacion.aceptada).toList();

  List<Postulacion> get rechazadas =>
      _postulaciones.where((p) => p.estado == EstadoPostulacion.rechazada).toList();

  // Contadores
  int get totalPendientes => pendientes.length;
  int get totalAceptadas => aceptadas.length;
  int get totalRechazadas => rechazadas.length;

  /// ===========================================================
  /// 🔹 Agregar una postulación desde una oferta (OfertasScreen)
  /// ===========================================================
  void agregarDesdeTrabajo(Map<String, dynamic> trabajo) {
    final nueva = Postulacion(
      id: _autoId++,
      trabajoId: trabajo['id'] ?? 0,
      titulo: trabajo['titulo'] ?? 'Trabajo sin título',
      categoria: trabajo['categoria'] ?? 'Sin categoría',
      empleador: (trabajo['empleador']?['nombre'] ??
              trabajo['publicadoPor'] ??
              'Desconocido')
          .toString(),
      ubicacion: trabajo['ubicacion'] ?? 'Sin ubicación',
      presupuesto: double.tryParse(
              (trabajo['salario'] ?? trabajo['presupuesto'] ?? 0).toString()) ??
          0.0,
      duracion: trabajo['duracion'] ?? 'No especificada',
      mensaje:
          "Estoy interesado en este trabajo y tengo experiencia para realizarlo.",
      fecha: DateTime.now(),
    );

    _postulaciones.add(nueva);
    notifyListeners();
  }

  /// ===========================================================
  /// 🔹 Cambiar estado (ACEPTAR / RECHAZAR / PENDIENTE)
  /// ===========================================================
  void cambiarEstado(int id, EstadoPostulacion nuevoEstado) {
    final index = _postulaciones.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _postulaciones[index].estado = nuevoEstado;
    notifyListeners();
  }

  /// ===========================================================
  /// 🔹 Eliminar postulación
  /// ===========================================================
  void eliminarPostulacion(int id) {
    _postulaciones.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// ===========================================================
  /// 🔹 Reset (limpiar todo)
  /// ===========================================================
  void reset() {
    _postulaciones.clear();
    _autoId = 1;
    notifyListeners();
  }
}
