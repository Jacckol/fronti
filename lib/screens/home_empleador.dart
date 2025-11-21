import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'ofertas_screen.dart';
import 'perfil_empleador_screen.dart';
import 'mis_postulaciones_screen.dart';

class HomeEmpleadorScreen extends StatelessWidget {
  const HomeEmpleadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.userName ?? "Usuario";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Portal del Empleador',
          style: TextStyle(
            color: Color(0xFF8B5CF6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Seguro deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sí'),
                    ),
                  ],
                ),
              );

              if (confirmar == true) {
                await auth.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(rol: 'empleador'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.black87),
            label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido 👋 $userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B21B6),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gestiona tu perfil y tus oportunidades',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _menuCard(
                        icon: Icons.search,
                        color: Colors.blue,
                        title: 'Buscar\nOfertas',
                        subtitle: 'Encuentra empleos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OfertasScreen()),
                          );
                        },
                      );
                    case 1:
                      return _menuCard(
                        icon: Icons.person,
                        color: Colors.purple,
                        title: 'Mi\nPerfil',
                        subtitle: 'Editar información',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PerfilEmpleadorScreen(
                                userId: auth.userId ?? 0,
                                nombre: userName,
                                telefono: "No registrado",
                              ),
                            ),
                          );
                        },
                      );
                    case 2:
                      return _menuCard(
                        icon: Icons.note_alt_outlined,
                        color: Colors.green,
                        title: 'Mis\nPostulaciones',
                        subtitle: 'Revisar solicitudes',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MisPostulacionesScreen(),
                            ),
                          );
                        },
                      );
                    case 3:
                      return _menuCard(
                        icon: Icons.calendar_month,
                        color: Colors.orange,
                        title: 'Agenda\nServicios',
                        subtitle: 'Trabajos programados',
                        onTap: () {},
                      );
                    case 4:
                      return _menuCard(
                        icon: Icons.account_balance_wallet,
                        color: Colors.teal,
                        title: 'Mi\nBilletera',
                        subtitle: 'Pagos e ingresos',
                        onTap: () {},
                      );
                    default:
                      return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
