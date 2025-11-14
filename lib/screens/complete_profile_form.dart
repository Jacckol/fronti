import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef OnSubmitProfile = Future<void> Function(Map<String, dynamic> data, String token);

class CompleteProfileForm extends StatefulWidget {
  final OnSubmitProfile onSubmit;
  final bool autoValidate;
  final Map<String, dynamic>? initialData;
  final String token; // 🔹 Token JWT del usuario

  const CompleteProfileForm({
    super.key,
    required this.onSubmit,
    required this.token,
    this.autoValidate = false,
    this.initialData,
  });

  @override
  State<CompleteProfileForm> createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _nombreComercialController = TextEditingController();
  String? _categoria;
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _horarioController = TextEditingController();
  final _experienciaController = TextEditingController();

  bool _loading = false;

  final List<String> _categorias = [
    'Plomería',
    'Electricidad',
    'Limpieza',
    'Mantenimiento',
    'Belleza',
    'Transporte',
    'Tecnología',
    'Servicios Automotrices',
    'Otros'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _nombreController.text = d['nombreCompleto'] ?? '';
      _cedulaController.text = d['cedulaRuc'] ?? '';
      _telefonoController.text = d['telefono'] ?? '';
      _nombreComercialController.text = d['nombreComercial'] ?? '';
      _categoria = d['categoria'];
      _descripcionController.text = d['descripcion'] ?? '';
      _direccionController.text = d['direccion'] ?? '';
      _horarioController.text = d['horario'] ?? '';
      _experienciaController.text = d['experiencia']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _nombreComercialController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _horarioController.dispose();
    _experienciaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      if (!widget.autoValidate) setState(() {});
      return;
    }

    // 🔹 Preparar payload con valores seguros
    final payload = {
      'nombreCompleto': _nombreController.text.trim(),
      'cedulaRuc': _cedulaController.text.trim().isEmpty ? null : _cedulaController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'nombreComercial': _nombreComercialController.text.trim(),
      'categoria': _categoria ?? 'Otros',
      'descripcion': _descripcionController.text.trim(),
      'direccion': _direccionController.text.trim(),
      'horario': _horarioController.text.trim(),
      'experiencia': int.tryParse(_experienciaController.text.trim()) ?? 0,
    };

    try {
      setState(() => _loading = true);

      final url = Uri.parse('http://localhost:4000/api/perfil-laboral');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil completado correctamente ✅')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar: ${response.statusCode} ${response.body}',
            ),
          ),
        );
      }

      await widget.onSubmit(payload, widget.token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando perfil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Form(
        key: _formKey,
        autovalidateMode:
            widget.autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Completa tu perfil laboral',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _nombreController,
              decoration: _inputDecoration(label: 'Nombre completo', icon: Icons.person),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _cedulaController,
              decoration: _inputDecoration(label: 'Cédula o RUC', icon: Icons.badge),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _telefonoController,
              decoration: _inputDecoration(label: 'Teléfono', icon: Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nombreComercialController,
              decoration: _inputDecoration(label: 'Nombre comercial', icon: Icons.business),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _categoria,
              isExpanded: true,
              items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              decoration: _inputDecoration(label: 'Categoría', icon: Icons.category),
              onChanged: (v) => setState(() => _categoria = v),
              validator: (v) => (v == null || v.isEmpty) ? 'Seleccione una categoría' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descripcionController,
              decoration: _inputDecoration(label: 'Descripción del servicio', icon: Icons.description),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _direccionController,
              decoration: _inputDecoration(label: 'Dirección o zona de atención', icon: Icons.location_on),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _horarioController,
              decoration: _inputDecoration(label: 'Horario de atención', icon: Icons.access_time),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _experienciaController,
              decoration: _inputDecoration(label: 'Años de experiencia', icon: Icons.timeline),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar y continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
