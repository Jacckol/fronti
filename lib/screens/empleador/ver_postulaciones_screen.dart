import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 🔥 IMPORT DE PROGRESO (NO BORRA NADA)
import 'progreso_trabajo_screen.dart';

// EMULADOR → 10.0.2.2
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
  State<VerPostulacionesScreen> createState() =>
      _VerPostulacionesScreenState();
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
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => loading = false);
  }

  // =====================================================
  // 🔥 ACEPTAR Y ENTRAR A PROGRESO (FIX REAL)
  // =====================================================
  Future<void> aceptarYIrAProgreso(Map p) async {
    try {
      final url = Uri.parse(
        "$baseUrl/api/postulaciones/${p["id"]}/estado",
      );

      final resp = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"estado": "aceptado"}),
      );

      if (resp.statusCode == 200) {
        final postulante = p["postulante"] ?? {};

        // ✅ FIX REAL: USER ID, NO TRABAJADOR ID
        final trabajadorId = postulante["userId"];

        await cargarPostulaciones();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgresoTrabajoScreen(
              trabajoId: widget.trabajoId,
              trabajadorId: trabajadorId,
              tituloTrabajo: widget.tituloTrabajo,
              nombreTrabajador:
                  postulante["nombre"] ?? "Trabajador",
              rol: "EMPLEADOR",
            ),
          ),
        );
      }
    } catch (_) {}
  }

  // ============================
  // RECHAZAR POSTULACIÓN
  // ============================
  Future<void> cambiarEstado(int id, String estado) async {
    try {
      final url = Uri.parse(
        "$baseUrl/api/postulaciones/$id/estado",
      );

      await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"estado": estado}),
      );

      cargarPostulaciones();
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    cargarPostulaciones();
  }

  // =====================================================
  // 🎨 CHIP DE ESTADO
  // =====================================================
  Widget _estadoChip(String estado) {
    Color color = estado == "aceptado"
        ? Colors.green
        : estado == "rechazado"
            ? Colors.red
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
        elevation: 0,
        backgroundColor: const Color(0xff6A4CE8),
        centerTitle: true,
        title: const Text(
          "Postulaciones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================= CABECERA =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: Color(0xff6A4CE8),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tituloTrabajo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Gestiona las postulaciones recibidas",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _statCard(
                            "Postulaciones",
                            total.toString(),
                            Icons.group,
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
                            Icons.cancel,
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ================= LISTA =================
                Expanded(
                  child: postulaciones.isEmpty
                      ? const Center(
                          child: Text("Aún no hay postulaciones"),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: postulaciones.length,
                          itemBuilder: (_, i) {
                            final p = postulaciones[i];
                            final postulante = p["postulante"] ?? {};

                            final nombre =
                                postulante["nombre"] ?? "Sin nombre";
                            final email =
                                postulante["email"] ?? "Sin email";
                            final mensaje =
                                (p["mensaje"] ?? "").toString().trim().isEmpty
                                    ? "Sin mensaje"
                                    : p["mensaje"];
                            final estado = p["estado"] ?? "pendiente";

                            // ✅ FIX REAL AQUÍ TAMBIÉN
                            final trabajadorId = postulante["userId"];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        child: Text(
                                          nombre[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              email,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      _estadoChip(estado),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  Text(
                                    mensaje,
                                    style: const TextStyle(fontSize: 14),
                                  ),

                                  const SizedBox(height: 18),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      if (estado == "pendiente") ...[
                                        ElevatedButton(
                                          onPressed: () =>
                                              aceptarYIrAProgreso(p),
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green,
                                          ),
                                          child:
                                              const Text("Aceptar"),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: () =>
                                              cambiarEstado(
                                            p["id"],
                                            "rechazado",
                                          ),
                                          child:
                                              const Text("Rechazar"),
                                        ),
                                      ],
                                      if (estado == "aceptado")
                                        TextButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ProgresoTrabajoScreen(
                                                  trabajoId:
                                                      widget.trabajoId,
                                                  trabajadorId:
                                                      trabajadorId,
                                                  tituloTrabajo:
                                                      widget
                                                          .tituloTrabajo,
                                                  nombreTrabajador:
                                                      nombre,
                                                  rol: "EMPLEADOR",
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.timeline),
                                          label: const Text(
                                              "Ver progreso"),
                                        ),
                                    ],
                                  ),
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

  // ============================
  // 📊 TARJETA DE ESTADÍSTICA
  // ============================
  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 10),
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
