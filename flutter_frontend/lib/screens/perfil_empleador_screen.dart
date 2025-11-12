import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/empleador_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class PerfilEmpleadorScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String telefono;

  const PerfilEmpleadorScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.telefono,
  });

  @override
  State<PerfilEmpleadorScreen> createState() => _PerfilEmpleadorScreenState();
}

class _PerfilEmpleadorScreenState extends State<PerfilEmpleadorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _telefonoCtrl;
  final _ubicacionCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _experienciaCtrl = TextEditingController();
  final _biografiaCtrl = TextEditingController();
  final _habilidadCtrl = TextEditingController();

  List<String> _habilidades = [];
  PlatformFile? _pickedFoto;
  PlatformFile? _pickedCv;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.nombre);
    _telefonoCtrl = TextEditingController(text: widget.telefono);

    // Cargar perfil del empleador
    Future.microtask(() async {
      final provider = context.read<EmpleadorProvider>();
      await provider.fetchPerfil(widget.userId);
      final p = provider.perfil;
      if (p != null) {
        _ubicacionCtrl.text = p['ubicacion'] ?? '';
        _categoriaCtrl.text = p['categoria'] ?? '';
        _experienciaCtrl.text = (p['experiencia']?.toString() ?? '');
        _biografiaCtrl.text = p['biografia'] ?? '';
        final hab = p['habilidades'];
        if (hab is List) _habilidades = List<String>.from(hab);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _ubicacionCtrl.dispose();
    _categoriaCtrl.dispose();
    _experienciaCtrl.dispose();
    _biografiaCtrl.dispose();
    _habilidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFoto() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _pickedFoto = res.files.first);
    }
  }

  Future<void> _pickCv() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _pickedCv = res.files.first);
    }
  }

  Widget _infoCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController ctrl,
    int? maxLines,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: (v) {
            if (!readOnly && (v == null || v.trim().isEmpty)) return 'Campo obligatorio';
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<EmpleadorProvider>();
    File? fotoFile;
    File? cvFile;

    if (!kIsWeb) {
      if (_pickedFoto?.path != null) fotoFile = File(_pickedFoto!.path!);
      if (_pickedCv?.path != null) cvFile = File(_pickedCv!.path!);
    }

    bool ok = await provider.savePerfil(
      ubicacion: _ubicacionCtrl.text.trim(),
      categoria: _categoriaCtrl.text.trim(),
      experiencia: int.tryParse(_experienciaCtrl.text.trim()) ?? 0,
      biografia: _biografiaCtrl.text.trim(),
      habilidades: _habilidades,
      fotoFile: fotoFile,
      cvFile: cvFile,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Perfil actualizado ✅' : 'Error guardando perfil ❌')),
    );
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Seguro deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirmar == true) {
      await context.read<AuthProvider>().logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen(rol: 'empleador')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmpleadorProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Portal Empleador', style: TextStyle(color: Color(0xFF7C3AED))),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.black87),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.black87)),
          )
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mi Perfil Profesional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Mantén tu información actualizada para recibir mejores ofertas', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoCard('⭐', '4.8', 'Calificación'),
                      const SizedBox(width: 12),
                      _infoCard('📋', '156', 'Trabajos Completados'),
                      const SizedBox(width: 12),
                      _infoCard('💼', _experienciaCtrl.text.isNotEmpty ? _experienciaCtrl.text : '0', 'Años de Experiencia'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 260,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            const Align(alignment: Alignment.centerLeft, child: Text('Foto de Perfil', style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(height: 12),
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey[200],
                              child: Text(widget.nombre.isNotEmpty ? widget.nombre[0].toUpperCase() : 'A', style: const TextStyle(fontSize: 36)),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickFoto,
                                icon: const Icon(Icons.upload_outlined),
                                label: const Text('Subir Foto'),
                              ),
                            ),
                            if (_pickedFoto != null) ...[
                              const SizedBox(height: 8),
                              Text(_pickedFoto!.name, overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Información Personal', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                _textField(label: 'Nombre Completo *', ctrl: _nombreCtrl, readOnly: true),
                                const SizedBox(height: 10),
                                _textField(label: 'Teléfono *', ctrl: _telefonoCtrl, readOnly: true),
                                const SizedBox(height: 10),
                                _textField(label: 'Ubicación *', ctrl: _ubicacionCtrl),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: _textField(label: 'Categoría *', ctrl: _categoriaCtrl)),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: _textField(label: 'Años de Experiencia *', ctrl: _experienciaCtrl),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _textField(label: 'Biografía Profesional', ctrl: _biografiaCtrl, maxLines: 3),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: _guardar,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF07051A),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: provider.loading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text('Guardar Cambios'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Habilidades
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Habilidades y Especialidades', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _habilidadCtrl,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF3F4F6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  hintText: 'Agregar nueva habilidad...',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                final text = _habilidadCtrl.text.trim();
                                if (text.isNotEmpty) {
                                  setState(() {
                                    _habilidades.add(text);
                                    _habilidadCtrl.clear();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                              child: const Text('Agregar'),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: _habilidades.map((h) {
                            return Chip(
                              label: Text(h),
                              onDeleted: () {
                                setState(() => _habilidades.remove(h));
                              },
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // CV
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Currículum (CV)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file, size: 36, color: Colors.black54),
                              const SizedBox(height: 8),
                              const Text('Sube tu CV para mejorar tus oportunidades', style: TextStyle(color: Colors.black54)),
                              const SizedBox(height: 6),
                              const Text('PDF, DOC o DOCX (máx. 5MB)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _pickCv,
                                child: const Text('Seleccionar Archivo'),
                              ),
                              if (_pickedCv != null) ...[
                                const SizedBox(height: 8),
                                Text(_pickedCv!.name, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
