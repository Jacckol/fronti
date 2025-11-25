import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mis_servicios_provider.dart';
import '../providers/auth_provider.dart';
import 'editar_servicio_screen.dart';

class PublicacionesScreen extends StatefulWidget {
  const PublicacionesScreen({super.key});

  @override
  State<PublicacionesScreen> createState() => _PublicacionesScreenState();
}

class _PublicacionesScreenState extends State<PublicacionesScreen> {
  List<dynamic> servicios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final auth = context.read<AuthProvider>();
    final prov = context.read<MisServiciosProvider>();

    servicios = await prov.cargarMisServicios(auth.userId ?? 0);

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Publicaciones"),
        backgroundColor: Colors.deepPurple,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : servicios.isEmpty
              ? const Center(
                  child: Text(
                    "No has publicado servicios aún",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: servicios.length,
                  itemBuilder: (_, i) {
                    final s = servicios[i];

                    return _cardPublicacion(
                      context,
                      s, // <<< ENVIAMOS EL MAPA COMPLETO
                    );
                  },
                ),
    );
  }

  // ============================================================
  // 🔹 CARD DE PUBLICACIÓN — CORREGIDA PARA EDITAR Y ELIMINAR
  // ============================================================
  Widget _cardPublicacion(
    BuildContext context,
    Map<String, dynamic> servicio,
  ) {
    final id = servicio["id"];
    final titulo = servicio["titulo"];
    final categoria = servicio["categoria"];
    final ubicacion = servicio["ubicacion"];
    final presupuesto = servicio["presupuesto"].toString();
    final descripcion = servicio["descripcion"];
    final fecha = servicio["createdAt"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("📍 $ubicacion"),
              Text("💵 $presupuesto"),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            "Publicado: $fecha",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          // =====================================================
          // 🔥 BOTONES DE ACCIÓN
          // =====================================================
          Row(
            children: [
              // ------------------------ EDITAR ------------------------
              ElevatedButton.icon(
                onPressed: () async {
                  final actualizado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditarServicioScreen(servicio: servicio), // << CORRECTO
                    ),
                  );

                  if (actualizado == true) {
                    _cargarDatos();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text("Editar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),

              const SizedBox(width: 10),

              // ------------------------ ELIMINAR ------------------------
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirmar eliminación"),
                      content: const Text("¿Seguro deseas eliminar este servicio?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar")),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Sí, eliminar")),
                      ],
                    ),
                  );

                  if (confirmar == true) {
                    final prov = context.read<MisServiciosProvider>();
                    bool ok = await prov.eliminarServicio(id);

                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Servicio eliminado"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      _cargarDatos();
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text("Eliminar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
