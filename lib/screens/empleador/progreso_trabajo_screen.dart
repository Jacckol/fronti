import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// EMULADOR → 10.0.2.2
// CELULAR REAL → http://192.168.100.22:4000
const String baseUrl = "http://10.0.2.2:4000";

class ProgresoTrabajoScreen extends StatefulWidget {
  final int trabajoId;
  final int postulacionId;
  final String tituloTrabajo;
  final String nombreTrabajador;
  final String correoTrabajador;

  const ProgresoTrabajoScreen({
    super.key,
    required this.trabajoId,
    required this.postulacionId,
    required this.tituloTrabajo,
    required this.nombreTrabajador,
    required this.correoTrabajador,
  });

  @override
  State<ProgresoTrabajoScreen> createState() => _ProgresoTrabajoScreenState();
}

class _ProgresoTrabajoScreenState extends State<ProgresoTrabajoScreen> {
  String estadoTrabajo = "en_progreso";
  bool loading = false;

  // ============================
  // MARCAR TRABAJO FINALIZADO
  // ============================
  Future<void> finalizarTrabajo() async {
    setState(() => loading = true);

    try {
      final url = Uri.parse(
        "$baseUrl/api/trabajos/${widget.trabajoId}/finalizar",
      );

      final resp = await http.patch(url);

      if (resp.statusCode == 200) {
        setState(() {
          estadoTrabajo = "finalizado";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trabajo finalizado correctamente")),
        );
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

    setState(() => loading = false);
  }

  // ============================
  // PAGO EN EFECTIVO
  // ============================
  Future<void> pagoEfectivo() async {
    try {
      final url = Uri.parse("$baseUrl/api/pagos/efectivo");

      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "trabajoId": widget.trabajoId,
          "postulacionId": widget.postulacionId,
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pago en efectivo registrado")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  // ============================
  // PAGO POR TRANSACCIÓN
  // ============================
  Future<void> pagoTransaccion() async {
    try {
      final url = Uri.parse("$baseUrl/api/pagos/transaccion");

      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "trabajoId": widget.trabajoId,
          "postulacionId": widget.postulacionId,
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transacción realizada con éxito")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool finalizado = estadoTrabajo == "finalizado";

    return Scaffold(
      backgroundColor: const Color(0xffF3F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff6A4CE8),
        title: const Text("Progreso del trabajo"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============================
                  // INFO TRABAJO
                  // ============================
                  Text(
                    widget.tituloTrabajo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // INFO TRABAJADOR
                  // ============================
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xff6A4CE8),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(widget.nombreTrabajador),
                      subtitle: Text(widget.correoTrabajador),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ============================
                  // ESTADO
                  // ============================
                  Row(
                    children: [
                      const Text(
                        "Estado:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Chip(
                        label: Text(
                          finalizado ? "FINALIZADO" : "EN PROGRESO",
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            finalizado ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ============================
                  // BOTONES
                  // ============================
                  ElevatedButton.icon(
                    onPressed: finalizado ? null : finalizarTrabajo,
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Trabajo finalizado"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: finalizado ? pagoEfectivo : null,
                    icon: const Icon(Icons.money),
                    label: const Text("Pago en efectivo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: finalizado ? pagoTransaccion : null,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text("Transacción (billetera)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
                                                                                                                                                                   