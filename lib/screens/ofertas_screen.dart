import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 👉 Importar pantalla REAL de postulación
import 'empleador/postular_oferta_screen.dart';

// 👉 Usa misma IP que MisPostulacionesScreen
const String baseUrl = "http://10.0.2.2:4000";

class OfertasScreen extends StatefulWidget {
  const OfertasScreen({super.key});

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  List trabajos = [];
  bool loading = true;

  // ============================
  // Cargar servicios del trabajador
  // ============================
  Future<void> cargarTrabajos() async {
    try {
      final url = Uri.parse("$baseUrl/api/servicios");

      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      print("🟣 SERVICIOS DISPONIBLES → ${resp.statusCode} | ${resp.body}");

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        List lista;
        if (data is List) {
          lista = data;
        } else {
          lista = (data["servicios"] ?? []) as List;
        }

        final soloActivos = lista.where((t) {
          final estado = (t["estado"] ?? "activo").toString();
          return estado == "activo";
        }).toList();

        if (!mounted) return;
        setState(() {
          trabajos = soloActivos;
          loading = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${resp.statusCode}: ${resp.body}")),
        );
        setState(() => loading = false);
      }
    } catch (e) {
      print("❌ Error cargando servicios: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    cargarTrabajos();
  }

  // ============================
  // Construcción UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios publicados'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      backgroundColor: const Color(0xFFF9FAFB),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trabajos.isEmpty
              ? const Center(
                  child: Text(
                    "No hay servicios publicados por ahora",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarTrabajos,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: trabajos.length,
                      itemBuilder: (context, index) {
                        final t = trabajos[index];

                        final titulo = (t['titulo'] ?? 'Sin título').toString();
                        final categoria =
                            (t['categoria'] ?? 'General').toString();
                        final descripcion =
                            (t['descripcion'] ?? '').toString();
                        final ubicacion =
                            (t['ubicacion'] ?? 'Sin ubicación').toString();
                        final salario =
                            (t['presupuesto'] ?? 0).toString();

                        final publicadoPor = "Trabajador";
                        final bool urgente = false; // servicios no tienen
                        final postulaciones = 0; // servicios no tienen

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ================= TITULO ==================
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      titulo,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  if (urgente)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[600],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Urgente',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // ================= CATEGORÍA Y PUBLICADOR ==================
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDE9FE),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      categoria,
                                      style: const TextStyle(
                                        color: Color(0xFF7C3AED),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Publicado por $publicadoPor",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // ================= DESCRIPCIÓN ==================
                              Text(
                                descripcion,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF374151),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ================= UBICACIÓN Y SALARIO ==================
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        ubicacion,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money,
                                          size: 16, color: Colors.grey),
                                      Text(
                                        salario,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ================= POSTULACIONES + BOTÓN ==================
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$postulaciones postulaciones',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),

                                  // ====== BOTÓN QUE ABRE DETALLES ======
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PostularOfertaScreen(
                                            trabajoId: t["id"],
                                            titulo: titulo,
                                            categoria: categoria,
                                            empresa: publicadoPor,
                                            ubicacion: ubicacion,
                                            salario: salario,
                                            descripcion: descripcion,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.send, size: 16),
                                    label: const Text("Ver más"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF111827),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
