import 'package:flutter/material.dart';

class NotificacionDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> notificacion;

  const NotificacionDetalleScreen({
    super.key,
    required this.notificacion,
  });

  /// Extrae el título del trabajo desde el mensaje si no viene el objeto trabajo
  String _obtenerTituloTrabajo(Map<String, dynamic> notificacion) {
    final trabajo = notificacion["trabajo"];

    if (trabajo != null && trabajo["titulo"] != null) {
      return trabajo["titulo"];
    }

    final mensaje = notificacion["mensaje"];
    if (mensaje != null) {
      final regex = RegExp(r'"([^"]+)"');
      final match = regex.firstMatch(mensaje);
      if (match != null) {
        return match.group(1)!;
      }
    }

    return "Trabajo no especificado";
  }

  @override
  Widget build(BuildContext context) {
    // 🔎 DEBUG REAL (si algo falla, aquí lo ves)
    debugPrint("📩 NOTIFICACIÓN DETALLE:");
    debugPrint(notificacion.toString());

    final usuario = notificacion["usuarioNotificacion"] ?? {};
    final nombreUsuario = usuario["nombre"] ?? "Usuario desconocido";
    final descripcion = notificacion["mensaje"] ?? "Sin descripción";
    final tituloTrabajo = _obtenerTituloTrabajo(notificacion);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Notificación"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.deepPurple.shade300,
                child: const Icon(
                  Icons.person,
                  size: 45,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Usuario
            Text(
              nombreUsuario,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // Trabajo relacionado
            Text(
              "Trabajo relacionado:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tituloTrabajo,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 22),

            // Mensaje
            Text(
              "Mensaje:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              descripcion,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const Spacer(),

            // Botón volver
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  "Volver",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
