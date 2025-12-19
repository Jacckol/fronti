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

  // ============================================================
  // 🔥 CARGAR SERVICIOS (SOLO < 24 HORAS)
  // ============================================================
  Future<void> _cargarDatos() async {
    final auth = context.read<AuthProvider>();
    final prov = context.read<MisServiciosProvider>();

    final data = await prov.cargarMisServicios(auth.userId ?? 0);
    final ahora = DateTime.now();

    servicios = data.where((s) {
      if (s["createdAt"] == null) return false;
      try {
        final fecha = DateTime.parse(s["createdAt"]);
        return ahora.difference(fecha).inHours < 24;
      } catch (_) {
        return false;
      }
    }).toList();

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        title: const Text("Mis Publicaciones"),
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : servicios.isEmpty
              ? const Center(
                  child: Text(
                    "No tienes publicaciones activas (24h)",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: servicios.length,
                  itemBuilder: (_, i) =>
                      _cardPublicacion(context, servicios[i]),
                ),
    );
  }

  // ============================================================
  // 🔹 CARD DE PUBLICACIÓN (MEJORADA)
  // ============================================================
  Widget _cardPublicacion(
    BuildContext context,
    Map<String, dynamic> servicio,
  ) {
    final id = servicio["id"];
    final titulo = servicio["titulo"];
    final categoria = servicio["categoria"];
    final ubicacion = servicio["ubicacion"];
    final presupuesto = servicio["presupuesto"];
    final descripcion = servicio["descripcion"];
    final fecha = servicio["createdAt"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- TÍTULO + PRECIO ----------------
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                "\$ $presupuesto",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ---------------- BADGES ----------------
          Row(
            children: [
              _badge(
                categoria,
                background: const Color(0xFFEDE9FE),
                textColor: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              _badge(
                "⏳ 24h activo",
                background: const Color(0xFFFFF7E0),
                textColor: const Color(0xFF92400E),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---------------- UBICACIÓN ----------------
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                ubicacion,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---------------- DESCRIPCIÓN ----------------
          Text(
            descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),

          const SizedBox(height: 12),

          Text(
            "Publicado: $fecha",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          // ---------------- ACCIONES ----------------
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final actualizado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditarServicioScreen(servicio: servicio),
                    ),
                  );
                  if (actualizado == true) _cargarDatos();
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Editar"),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Eliminar servicio"),
                      content: const Text(
                          "¿Seguro deseas eliminar esta publicación?"),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text("Eliminar"),
                        ),
                      ],
                    ),
                  );

                  if (confirmar == true) {
                    final prov =
                        context.read<MisServiciosProvider>();
                    final ok =
                        await prov.eliminarServicio(id);
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text("Eliminar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGE CORREGIDO (SIN ERRORES)
  // ============================================================
  Widget _badge(
    String label, {
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
