import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final String rol; // 'usuario' o 'empleador'
  const RegisterScreen({super.key, required this.rol});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final companyController = TextEditingController();
  final rucController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rol == 'empleador' ? 'Registro Empleador' : 'Registro Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                widget.rol == 'empleador' ? 'REGISTRO EMPLEADOR' : 'REGISTRO USUARIO',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Usuario
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Nombre / Usuario'),
                validator: (value) => value == null || value.isEmpty ? '* Requerido' : null,
              ),
              const SizedBox(height: 10),
              // Email
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) => value == null || value.isEmpty ? '* Requerido' : null,
              ),
              const SizedBox(height: 10),
              // Contraseña
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value == null || value.isEmpty ? '* Requerido' : null,
              ),
              const SizedBox(height: 10),
              // Campos extra empleador
              if (widget.rol == 'empleador') ...[
                TextFormField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Nombre Empresa'),
                  validator: (value) => value == null || value.isEmpty ? '* Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: rucController,
                  decoration: const InputDecoration(labelText: 'RUC'),
                  validator: (value) => value == null || value.isEmpty ? '* Requerido' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  validator: (value) => value == null || value.isEmpty ? '* Requerido' : null,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          bool ok = false;
                          if (widget.rol == 'usuario') {
                            ok = await auth.registerUser(
                              usernameController.text.trim(),
                              passwordController.text.trim(),
                              emailController.text.trim(),
                            );
                          } else {
                            ok = await auth.registerEmployer(
                              companyController.text.trim(),
                              usernameController.text.trim(),
                              passwordController.text.trim(),
                              emailController.text.trim(),
                            );
                          }

                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registro exitoso')),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        }
                      },
                child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
