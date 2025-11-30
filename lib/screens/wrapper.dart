import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Tus pantallas
import 'login_screen.dart';
import 'home_screen.dart';
import 'admin_dashboard.dart';
import 'profesional_dashboard.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Si está cargando (por ejemplo, al iniciar sesión)
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si no hay usuario logueado
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    // Si hay usuario, navegar según su rol
    switch (authProvider.user!.role) {
      case 'admin':
        return const AdminDashboard();
      case 'profesional':
        return const ProfesionalDashboard();
      default:
        return const HomeScreen(); // usuario normal
    }
  }
}
