import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/servicio_provider.dart';

class PublicarServicioScreen extends StatefulWidget {
  const PublicarServicioScreen({super.key});

  @override
  State<PublicarServicioScreen> createState() => _PublicarServicioScreenState();
}

class _PublicarServicioScreenState extends State<PublicarServicioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _presupuestoCtrl = TextEditingController();

  bool _cargando = false;

  final List<String> _categorias = [
    'Plomería',
    'Electricidad',
    'Pintura',
    'Carpintería',
    'Limpieza',
    'Jardinería',
    'Albañilería',
    'Servicio Técnico',
  ];

  String? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final servicioProvider = Provider.of<ServicioProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Publicar un Servicio",
          style: TextStyle(
            color: Color(0xFF7C3AED),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Completa los detalles del servicio que ofreces",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                _campoTexto("Título del Servicio *", "Ej: Reparación eléctrica", _tituloCtrl),
                const SizedBox(height: 15),

                // Categoría
                const Text("Categoría *"),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  items: _categorias.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSeleccionada = value;
                    });
                  },
                  validator: (v) => v == null ? "Selecciona una categoría" : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _campoTextoGrande(
                  "Descripción Detallada *",
                  "Describe qué servicio ofreces...",
                  _descripcionCtrl,
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _campoTexto(
                        "Ubicación *",
                        "Ciudad, zona",
                        _ubicacionCtrl,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _campoTexto(
                        "Presupuesto (\$) *",
                        "Ej: 40",
                        _presupuestoCtrl,
                        tecladoNumero: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cargando
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;

                                if (_categoriaSeleccionada == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Selecciona una categoría"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _cargando = true;
                                });

                                bool ok = await servicioProvider.publicarServicio(
                                  titulo: _tituloCtrl.text,
                                  categoria: _categoriaSeleccionada!,
                                  descripcion: _descripcionCtrl.text,
                                  ubicacion: _ubicacionCtrl.text,
                                  presupuesto: double.tryParse(_presupuestoCtrl.text) ?? 0,
                                  userId: 1,   // ⭐ SIN TOKEN → enviamos userId directo o null
                                );

                                setState(() {
                                  _cargando = false;
                                });

                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Servicio publicado correctamente"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Error al publicar"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Publicar Servicio",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String label, String hint, TextEditingController ctrl,
      {bool tecladoNumero = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: tecladoNumero ? TextInputType.number : TextInputType.text,
          validator: (v) => v == null || v.isEmpty ? "Campo obligatorio" : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoTextoGrande(String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: 4,
          validator: (v) => v == null || v.isEmpty ? "Campo obligatorio" : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
