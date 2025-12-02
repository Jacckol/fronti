import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// EMULADOR → 10.0.2.2
// CELULAR REAL → cambia a: http://192.168.100.22:4000
const String baseUrl = "http://10.0.2.2:4000";

class VerPostulacionesScreen extends StatefulWidget {
  final int trabajoId;
  final String tituloTrabajo;

  const VerPostulacionesScreen({
    super.key,
    required this.trabajoId,
    required this.tituloTrabajo,
  });

  @override
  State<VerPostulacionesScreen> createState() => _VerPostulacionesScreenState();
}

class _VerPostulacionesScreenState extends State<VerPostulacionesScreen> {
  bool loading = true;
  List postulaciones = [];

  // ============================
  // CARGAR POSTULACIONES
  // ============================
  Future<void> cargarPostulaciones() async {
    try {
      final url = Uri.parse(
        "$baseUrl/api/postulaciones/trabajo/${widget.trabajoId}",
      );

      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        postulaciones = data["postulaciones"] ?? [];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${resp.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  // ============================
  // CAMBIAR ESTADO POSTULACIÓN
  // ============================
  Future<void> cambiarEstado(int id, String estado) async {
    try {
      final url = Uri.parse(
        "$baseUrl/api/postulaciones/$id/estado",
      );

      final resp = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"estado": estado}),
      );

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Postulación marcada como $estado")),
        );
        cargarPostulaciones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${resp.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    cargarPostulaciones();
  }

  @override
  Widget build(BuildContext context) {
    final total = postulaciones.length;
    final aceptadas =
        postulaciones.where((p) => p["estado"] == "aceptado").length;
    final rechazadas =
        postulaciones.where((p) => p["estado"] == "rechazado").length;

    return Scaffold(
      backgroundColor: const Color(0xffF3F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff6A4CE8),
        title: const Text("Postulaciones"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // CABECERA
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tituloTrabajo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Revisa las personas interesadas en este trabajo.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _statCard(
                            "Postulaciones",
                            total.toString(),
                            Icons.group_outlined,
                            Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          _statCard(
                            "Aceptadas",
                            aceptadas.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          const SizedBox(width: 10),
                          _statCard(
                            "Rechazadas",
                            rechazadas.toString(),
                            Icons.cancel_outlined,
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: postulaciones.isEmpty
                      ? const Center(
                          child: Text(
                            "Aún no hay postulaciones para este trabajo",
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: postulaciones.length,
                          itemBuilder: (_, i) {
                            final p = postulaciones[i];
                            final postulante = p["postulante"] ?? {};
                            final nombre = postulante["nombre"] ?? "Sin nombre";
                            final email = postulante["email"] ?? "Sin email";
                            final mensaje =
                                (p["mensaje"] ?? "").toString().trim().isEmpty
                                    ? "Sin mensaje"
                                    : p["mensaje"];

                            Color colorEstado;
                            switch (p["estado"]) {
                              case "aceptado":
                                colorEstado = Colors.green;
                                break;
                              case "rechazado":
                                colorEstado = Colors.red;
                                break;
                              default:
                                colorEstado = Colors.orange;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              email,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorEstado.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          (p["estado"] ?? "pendiente")
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorEstado,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    mensaje,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => cambiarEstado(
                                          p["id"],
                                          "aceptado",
                                        ),
                                        child: const Text("Aceptar"),
                                      ),
                                      TextButton(
                                        onPressed: () => cambiarEstado(
                                          p["id"],
                                          "rechazado",
                                        ),
                                        child: const Text(
                                          "Rechazar",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
