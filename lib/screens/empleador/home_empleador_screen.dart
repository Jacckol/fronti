import 'package:flutter/material.dart';

// 👇 ESTE ES EL ARCHIVO DONDE REALMENTE ESTÁ TU LISTA DE OFERTAS
import '../ofertas_screen.dart';

class HomeEmpleadorScreen extends StatelessWidget {
  const HomeEmpleadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Hola",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Qué deseas hacer hoy?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // 👉 PUBLICAR TRABAJO
            _menuButton(
              context,
              icon: Icons.add_circle_outline,
              color: Colors.blue,
              title: "Publicar un Trabajo",
              subtitle: "Crea una nueva oferta de trabajo",
              onTap: () => Navigator.pushNamed(context, "/publicarTrabajo"),
            ),

            const SizedBox(height: 15),

            _menuButton(
              context,
              icon: Icons.group_outlined,
              color: Colors.green,
              title: "Buscar Perfiles Destacados",
              subtitle: "Encuentra trabajadores calificados",
              onTap: () {},
            ),

            const SizedBox(height: 15),

            // 👉 VER SERVICIOS / TRABAJOS PUBLICADOS
            _menuButton(
              context,
              icon: Icons.search,
              color: Colors.purple,
              title: "Buscar Servicios",
              subtitle: "Explora servicios disponibles",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfertasScreen(), // ✔ TU PANTALLA REAL
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _menuButton(
              context,
              icon: Icons.wallet_outlined,
              color: Colors.orange,
              title: "Mi Billetera",
              subtitle: "Control de gastos en servicios",
              onTap: () {},
            ),

            const SizedBox(height: 15),

            // 👉 MIS PUBLICACIONES (EMPLEADOR)
            _menuButton(
              context,
              icon: Icons.post_add_outlined,
              color: Colors.blue,
              title: "Mis Publicaciones",
              subtitle: "Ver y gestionar tus trabajos publicados",
              onTap: () => Navigator.pushNamed(context, "/misPublicaciones"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
