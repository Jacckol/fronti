import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_user_screen.dart';
import 'register_employer_screen.dart';

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

                  // Usuario
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
                    validator: (value) =>
                        value == null || value.isEmpty ? "* Requerido" : null,
                  ),
                  const SizedBox(height: 20),

                  // Contraseña
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
                    validator: (value) =>
                        value == null || value.isEmpty ? "* Requerido" : null,
                  ),
                  const SizedBox(height: 24),

                  // Botón de login
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
                                String? role = await auth.login(
                                  usernameController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                if (role != null) {
                                  final rolLower = role.toLowerCase();

                                  if (rolLower == 'usuario' ||
                                      rolLower == 'cliente') {
                                    Navigator.pushReplacementNamed(
                                        context, '/homeUser');
                                  } else if (rolLower == 'empleador') {
                                    Navigator.pushReplacementNamed(
                                        context, '/homeEmpleador');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Rol desconocido: $rolLower'),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Credenciales inválidas')),
                                  );
                                }
                              }
                            },
                      child: auth.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de registro
                  TextButton(
                    onPressed: () {
                      if (widget.rol == 'usuario') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterUserScreen(rol: 'usuario'),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterEmployerScreen(rol: 'empleador'),
                          ),
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
