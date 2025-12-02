import 'package:flutter/material.dart';

import '../providers/postulaciones_provider.dart';

class PostulacionDetalleScreen extends StatelessWidget {
  final Postulacion postulacion;

  const PostulacionDetalleScreen({super.key, required this.postulacion});

  @override
  Widget build(BuildContext context) {
    Color estadoColor;
    String estadoText;

    switch (postulacion.estado) {
      case EstadoPostulacion.aceptada:
        estadoColor = Colors.green;
        estadoText = "Aceptada";
        break;
      case EstadoPostulacion.rechazada:
        estadoColor = Colors.red;
        estadoText = "Rechazada";
        break;
      default:
        estadoColor = Colors.orange;
        estadoText = "Pendiente";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Postulación"),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              postulacion.titulo,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Chip(
                  label: Text(estadoText),
                  backgroundColor: estadoColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: estadoColor),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _info("Categoría", postulacion.categoria),
            _info("Empleador", postulacion.empleador),
            _info("Ubicación", postulacion.ubicacion),
            _info("Presupuesto", "\$${postulacion.presupuesto}"),
            _info("Duración", postulacion.duracion),

            const SizedBox(height: 20),

            const Text(
              "Mensaje enviado:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              postulacion.mensaje,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            Text(
              "Fecha: ${postulacion.fecha.day}/${postulacion.fecha.month}/${postulacion.fecha.year}",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
