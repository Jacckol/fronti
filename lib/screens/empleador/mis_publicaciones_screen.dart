import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../providers/auth_provider.dart';
import 'ver_postulaciones_screen.dart';


// 👉 EMULADOR ANDROID
const String baseUrl = "http://10.0.2.2:4000";

// 👉 CELULAR FÍSICO (solo referencia)
// const String baseUrl = "http://192.168.100.22:4000";
class MisPublicacionesScreen extends StatefulWidget {
  const MisPublicacionesScreen({super.key});

  @override
  State<MisPublicacionesScreen> createState() => _MisPublicacionesScreenState();
}

class _MisPublicacionesScreenState extends State<MisPublicacionesScreen> {
  List trabajos = [];
  bool loading = true;

  // ============================
  // CARGAR TRABAJOS DEL EMPLEADOR
  // ============================
  Future<void> cargarTrabajos() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final url = Uri.parse(
        "$baseUrl/api/trabajos/mios/${auth.userId}",
      );

      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      print("🟣 MIS TRABAJOS → ${resp.statusCode} | ${resp.body}");

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        if (!mounted) return;
        setState(() {
          trabajos = data["trabajos"] ?? [];
          loading = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ${resp.statusCode}: ${resp.body}")),
        );
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("❌ Error cargando trabajos: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
      setState(() {
        loading = false;
      });
    }
  }

  // ============================
  // ELIMINAR TRABAJO
  // ============================
  Future<void> eliminarTrabajo(int id) async {
    final url = Uri.parse("$baseUrl/api/trabajos/$id");

    final resp = await http.delete(url);

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Trabajo eliminado")));
      cargarTrabajos();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${resp.body}")));
    }
  }

  void confirmarEliminar(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar publicación"),
        content: const Text("¿Seguro que deseas eliminar este trabajo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              eliminarTrabajo(id);
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  // EDITAR TRABAJO
  // ============================
  void editarTrabajo(Map trabajo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarTrabajoScreen(trabajo: trabajo),
      ),
    ).then((_) => cargarTrabajos());
  }

  // ============================
  // CAMBIAR ESTADO
  // ============================
  Future<void> cambiarEstado(int id, String estado) async {
    final url = Uri.parse("$baseUrl/api/trabajos/$id/estado");

    final resp = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"estado": estado}),
    );

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estado actualizado a $estado")),
      );
      cargarTrabajos();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${resp.body}")));
    }
  }

  @override
  void initState() {
    super.initState();
    cargarTrabajos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F0FF),
      appBar: AppBar(
        title: const Text("Mis Publicaciones"),
        backgroundColor: const Color(0xff6A4CE8),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : trabajos.isEmpty
              ? const Center(child: Text("No tienes publicaciones"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trabajos.length,
                  itemBuilder: (_, i) {
                    final t = trabajos[i];
                    final estado = (t["estado"] ?? "activo").toString();

                    Color colorEstado = estado == "finalizado"
                        ? Colors.green
                        : estado == "pausado"
                            ? Colors.orange
                            : Colors.blue;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t["titulo"] ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorEstado.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  estado.toUpperCase(),
                                  style: TextStyle(
                                    color: colorEstado,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t["descripcion"] ?? "",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.place,
                                size: 16,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 4),
                              Text(t["ubicacion"] ?? ""),
                              const SizedBox(width: 20),
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text("${t["salario"] ?? ""}"),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // VER POSTULACIONES
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerPostulacionesScreen(
                                        trabajoId: t["id"],
                                        tituloTrabajo: t["titulo"] ?? "",
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("Ver postulaciones"),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) => cambiarEstado(t["id"], v),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: "activo",
                                    child: Text("Marcar activo"),
                                  ),
                                  PopupMenuItem(
                                    value: "pausado",
                                    child: Text("Pausar publicación"),
                                  ),
                                  PopupMenuItem(
                                    value: "finalizado",
                                    child: Text("Marcar como finalizado"),
                                  ),
                                ],
                                child: const Icon(Icons.more_vert),
                              ),
                              TextButton.icon(
                                onPressed: () => editarTrabajo(t),
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                label: const Text(
                                  "Editar",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => confirmarEliminar(t["id"]),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Eliminar",
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
    );
  }
}

// =============================
// PANTALLA DE EDITAR TRABAJO
// =============================
class EditarTrabajoScreen extends StatefulWidget {
  final Map trabajo;

  const EditarTrabajoScreen({super.key, required this.trabajo});

  @override
  State<EditarTrabajoScreen> createState() => _EditarTrabajoScreenState();
}

class _EditarTrabajoScreenState extends State<EditarTrabajoScreen> {
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final ubicacionCtrl = TextEditingController();
  final salarioCtrl = TextEditingController();
  String categoria = "";

  @override
  void initState() {
    super.initState();
    tituloCtrl.text = widget.trabajo["titulo"] ?? "";
    descripcionCtrl.text = widget.trabajo["descripcion"] ?? "";
    ubicacionCtrl.text = widget.trabajo["ubicacion"] ?? "";
    salarioCtrl.text = (widget.trabajo["salario"] ?? "").toString();
    categoria = widget.trabajo["categoria"] ?? "";
  }

  Future<void> actualizar() async {
    final url = Uri.parse(
      "$baseUrl/api/trabajos/${widget.trabajo["id"]}",
    );

    final body = {
      "titulo": tituloCtrl.text.trim(),
      "descripcion": descripcionCtrl.text.trim(),
      "salario": salarioCtrl.text.trim(),
      "ubicacion": ubicacionCtrl.text.trim(),
      "categoria": categoria,
    };

    final resp = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Trabajo actualizado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${resp.body}")),
      );
    }
  }

  Widget inputBox(String label, TextEditingController c,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: c,
            maxLines: maxLines,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F0FF),
      appBar: AppBar(
        title: const Text("Editar Trabajo"),
        backgroundColor: const Color(0xff6A4CE8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            inputBox("Título del trabajo", tituloCtrl),
            inputBox("Descripción detallada", descripcionCtrl, maxLines: 4),
            inputBox("Ubicación", ubicacionCtrl),
            inputBox("Presupuesto (\$)", salarioCtrl),
            const Text(
              "Categoría",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: categoria.isEmpty ? null : categoria,
                underline: const SizedBox(),
                items: const [
                  "Electricidad",
                  "Plomería",
                  "Pintura",
                  "Limpieza"
                ].map(
                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                ).toList(),
                onChanged: (v) => setState(() => categoria = v ?? ""),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: actualizar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "Guardar Cambios",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
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
