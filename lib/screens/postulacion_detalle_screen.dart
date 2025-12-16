import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/postulaciones_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notificaciones_provider.dart';

class PostulacionDetalleScreen extends StatefulWidget {
  final Postulacion postulacion;

  const PostulacionDetalleScreen({super.key, required this.postulacion});

  @override
  State<PostulacionDetalleScreen> createState() =>
      _PostulacionDetalleScreenState();
}

class _PostulacionDetalleScreenState extends State<PostulacionDetalleScreen> {
  final TextEditingController mensajeCtrl = TextEditingController();

  bool yaPostuloBackend = false;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    verificarPostulacion();
  }

  @override
  void dispose() {
    mensajeCtrl.dispose();
    super.dispose();
  }

  // 🔍 CONSULTAR AL BACKEND
  Future<void> verificarPostulacion() async {
    final auth = context.read<AuthProvider>();

    try {
      final url = Uri.parse(
          "http://10.0.2.2:4000/api/postulaciones/verificar/${widget.postulacion.trabajoId}/${auth.userId}");

      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        yaPostuloBackend = data["postulo"] == true;
      }
    } catch (e) {
      print("❌ Error verificando postulación: $e");
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final postProv = context.read<PostulacionesProvider>();
    final notiProv = context.read<NotificacionesProvider>();

    // -----------------------------
    // CAMPOS SEGUROS (evita null)
    // -----------------------------
    final titulo = (widget.postulacion.titulo).isNotEmpty
        ? widget.postulacion.titulo
        : "Sin título";

    final categoria = (widget.postulacion.categoria).isNotEmpty
        ? widget.postulacion.categoria
        : "Sin categoría";

    final empleador = (widget.postulacion.empleador).isNotEmpty
        ? widget.postulacion.empleador
        : "Desconocido";

    final ubicacion = (widget.postulacion.ubicacion).isNotEmpty
        ? widget.postulacion.ubicacion
        : "No especificada";

    final presupuesto = widget.postulacion.presupuesto;
    final duracion = widget.postulacion.duracion.isNotEmpty
        ? widget.postulacion.duracion
        : "No especificada";

    // -----------------------------
    // ESTADO VISUAL
    // -----------------------------
    Color estadoColor;
    String estadoText;

    switch (widget.postulacion.estado) {
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
        title: const Text("Detalle de Trabajo"),
        backgroundColor: const Color(0xFF8B5CF6),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  // -------------------------
                  // TÍTULO
                  // -------------------------
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Chip(
                    label: Text(estadoText),
                    backgroundColor: estadoColor.withOpacity(0.2),
                    labelStyle: TextStyle(color: estadoColor),
                  ),

                  const SizedBox(height: 20),

                  // -------------------------
                  // INFORMACIÓN DEL TRABAJO
                  // -------------------------
                  _info("Categoría", categoria),
                  _info("Empleador", empleador),
                  _info("Ubicación", ubicacion),
                  _info("Presupuesto", "\$$presupuesto"),
                  _info("Duración", duracion),

                  const SizedBox(height: 25),

                  const Text(
                    "Escribe un mensaje para el empleador:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: mensajeCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ejemplo: Tengo experiencia, puedo empezar hoy...",
                    ),
                  ),

                  const SizedBox(height: 30),

                  // -------------------------
                  // BOTÓN DE POSTULAR
                  // -------------------------
                  if (!yaPostuloBackend)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final mensaje = mensajeCtrl.text.trim();

                          if (mensaje.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Debes escribir un mensaje"),
                              ),
                            );
                            return;
                          }

                          // ---- ENVIAR LA POSTULACIÓN ----
                          final ok = await postProv.crearPostulacion(
                            trabajoId: widget.postulacion.trabajoId,
                            userId: auth.userId!,
                            mensaje: mensaje,
                            titulo: titulo,
                            categoria: categoria,
                            empleador: empleador,
                            ubicacion: ubicacion,
                            presupuesto: presupuesto,
                            duracion: duracion,
                          );

                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error al postular ❌"),
                              ),
                            );
                            return;
                          }

                          // ---- GUARDAR NOTIFICACIÓN ----
                          try {
                            await http.post(
                              Uri.parse("http://10.0.2.2:4000/api/notificaciones"),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "userId": auth.userId,
                                "trabajoId": widget.postulacion.trabajoId,
                                "titulo": titulo,
                                "mensaje": mensaje,
                              }),
                            );
                          } catch (e) {
                            print("❌ Error enviando notificación: $e");
                          }

                          notiProv.agregarNotificacionLocal({
                            "id": DateTime.now().millisecondsSinceEpoch,
                            "leida": false,
                            "postulante": {
                              "nombre": auth.userName ?? "Trabajador",
                              "id": auth.userId,
                            },
                            "trabajo": {
                              "titulo": titulo,
                              "id": widget.postulacion.trabajoId,
                            },
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Postulación enviada ✔"),
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "POSTULARME",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

                  if (yaPostuloBackend)
                    const Text(
                      "✔ Ya postulaste a este trabajo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
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
