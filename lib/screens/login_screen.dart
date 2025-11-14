import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';
import 'register_user_screen.dart';
import 'register_employer_screen.dart';
import 'complete_profile_form.dart';
import 'seleccion_screen.dart';

class LoginScreen extends StatefulWidget {
  final String rol;
  const LoginScreen({super.key, required this.rol});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // ======================================================
  // 🔹 Método que se ejecuta DESPUÉS del login exitoso
  // ======================================================
  Future<void> _afterLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final bool isEmpleador = auth.role == 'empleador';
    final bool perfilCompleto = auth.perfilCompleto;
    final int empleadorId = auth.userId ?? 0;
    final String? token = auth.token;

    if (isEmpleador && !perfilCompleto && token != null) {
      // Mostrar modal para completar perfil
      final wantToComplete = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Completar perfil'),
          content: const Text(
            'Hola 👋 Para continuar es necesario completar tu perfil. ¿Deseas hacerlo ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí'),
            ),
          ],
        ),
      );

      if (wantToComplete == true) {
        // Mostrar formulario para completar perfil
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CompleteProfileForm(
                token: token,
                initialData: null,
                onSubmit: (data, token) async {
                  try {
                    data['empleadorId'] = empleadorId;

                    final url = Uri.parse('http://localhost:4000/api/perfil-laboral');
                    final response = await http.post(
                      url,
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode(data),
                    );

                    if (response.statusCode == 201) {
                      // 🔹 Actualizar estado en el provider
                      auth.setPerfilCompleto(true);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil completado correctamente ✅')),
                      );

                      Navigator.of(context).pop(); // Cierra el modal
                      Navigator.of(context).pushReplacementNamed('/homeEmpleador');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar: ${response.statusCode} ${response.body}'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SeleccionScreen()),
        );
      }
    } else {
      // 🔹 Si ya completó el perfil, ir directo al home
      Navigator.pushReplacementNamed(
        context,
        isEmpleador ? '/homeEmpleador' : '/homeUser',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            width: size.width > 500 ? 400 : double.infinity,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'INICIAR SESIÓN COMO ${widget.rol.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B21B6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "* Requerido" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                    ),
                    validator: (value) => value == null || value.isEmpty ? "* Requerido" : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.purpleAccent.withOpacity(0.2),
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final role = await auth.login(
                                  usernameController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                if (role != null) {
                                  await _afterLogin(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Credenciales inválidas')),
                                  );
                                }
                              }
                            },
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (widget.rol == 'usuario') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterUserScreen(rol: 'usuario')),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterEmployerScreen(rol: 'empleador')),
                        );
                      }
                    },
                    child: Text(
                      widget.rol == 'usuario'
                          ? '¿No tienes cuenta? Regístrate aquí'
                          : '¿Eres nuevo empleador? Regístrate aquí',
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
