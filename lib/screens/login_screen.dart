import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';
import 'register_user_screen.dart';
import 'register_trabajador_screen.dart';      // ✔ CORRECTO
import 'complete_profile_form.dart';
import 'seleccion_screen.dart';
import 'home_trabajador.dart';                // ✔ REDIRECCIÓN CORRECTA
import 'home_user.dart';

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
  // 🔥 LÓGICA DESPUÉS DEL LOGIN (ACTUALIZADA)
  // ======================================================
  Future<void> _afterLogin(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final bool isTrabajador = auth.role == 'trabajador';  // ✔ CORRECTO
    final String? token = auth.token;
    final int userId = auth.userId ?? 0;

    // Usuario normal → directo al home
    if (!isTrabajador || token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeUserScreen()),
      );
      return;
    }

    // ===============================
    // 1️⃣ Verificar si tiene perfil
    // ===============================
    bool tienePerfil = false;

    try {
      final url = Uri.parse('http://10.0.2.2:4000/api/perfil-laboral/mine');
      final resp = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        tienePerfil = data["exists"] == true;
      }
    } catch (e) {
      debugPrint('❌ Error consultando perfil: $e');
    }

    if (tienePerfil) {
      auth.setPerfilCompleto(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeTrabajadorScreen()),
      );
      return;
    }

    // ===============================
    // 2️⃣ Preguntar si desea completarlo
    // ===============================
    final wantToComplete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Completar perfil'),
        content: const Text(
          'Para continuar necesitas completar tu perfil laboral. ¿Deseas hacerlo ahora?',
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

    if (wantToComplete != true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SeleccionScreen()),
      );
      return;
    }

    // ===============================
    // 3️⃣ Mostrar formulario de perfil
    // ===============================
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
                final url = Uri.parse('http://10.0.2.2:4000/api/perfil-laboral');
                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(data),
                );

                if (response.statusCode == 201) {
                  auth.setPerfilCompleto(true);

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeTrabajadorScreen()),
                  );
                }
              } catch (e) {
                debugPrint('❌ Error guardando perfil: $e');
              }
            },
          ),
        ),
      ),
    );
  }

  // ======================================================
  // UI
  // ======================================================
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
            width: size.width > 500 ? 400 : double.infinity,
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
            child: Form(
              key: _formKey,
              child: Column(
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
                      labelText: 'Usuario (correo)',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
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
                                }
                              }
                            },
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      if (widget.rol == 'usuario') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterUserScreen(rol: 'usuario'),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterTrabajadorScreen(rol: 'trabajador'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      widget.rol == 'usuario'
                          ? '¿No tienes cuenta? Regístrate aquí'
                          : '¿Eres nuevo trabajador? Regístrate aquí',
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
