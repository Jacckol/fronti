import 'package:flutter/material.dart';

/// Estado de la postulación
enum EstadoPostulacion { pendiente, aceptada, rechazada }

/// Modelo simple de Postulación
class Postulacion {
  final int id; // id interno de la postulación
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

class PostulacionesProvider extends ChangeNotifier {
  final List<Postulacion> _postulaciones = [];
  int _autoId = 1;

  List<Postulacion> get todas => List.unmodifiable(_postulaciones);

  List<Postulacion> get pendientes => _postulaciones
      .where((p) => p.estado == EstadoPostulacion.pendiente)
      .toList();

  List<Postulacion> get aceptadas => _postulaciones
      .where((p) => p.estado == EstadoPostulacion.aceptada)
      .toList();

  List<Postulacion> get rechazadas => _postulaciones
      .where((p) => p.estado == EstadoPostulacion.rechazada)
      .toList();

  int get totalPendientes => pendientes.length;
  int get totalAceptadas => aceptadas.length;
  int get totalRechazadas => rechazadas.length;

  /// Agregar una postulación a partir de un "trabajo" (map del OfertasScreen)
  void agregarDesdeTrabajo(Map<String, dynamic> trabajo) {
    final nueva = Postulacion(
      id: _autoId++,
      trabajoId: trabajo['id'] ?? 0,
      titulo: trabajo['titulo'] ?? '',
      categoria: trabajo['categoria'] ?? '',
      empleador: trabajo['publicadoPor'] ?? '',
      ubicacion: trabajo['ubicacion'] ?? '',
      presupuesto: (trabajo['presupuesto'] ?? 0).toDouble(),
      duracion: trabajo['duracion'] ?? '',
      mensaje: 'Me interesa este trabajo. Tengo experiencia en esta área.',
      fecha: DateTime.now(),
    );

    _postulaciones.add(nueva);
    notifyListeners();
  }

  /// Por si luego quieres cambiar el estado manualmente o desde backend
  void cambiarEstado(int id, EstadoPostulacion nuevoEstado) {
    final idx = _postulaciones.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _postulaciones[idx].estado = nuevoEstado;
    notifyListeners();
  }
}
