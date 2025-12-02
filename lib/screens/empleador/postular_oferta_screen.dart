import 'package:flutter/material.dart';

class PostularOfertaScreen extends StatelessWidget {
  final int trabajoId;
  final String titulo;
  final String categoria;
  final String empresa;
  final String ubicacion;
  final String salario;
  final String descripcion;

  const PostularOfertaScreen({
    super.key,
    required this.trabajoId,
    required this.titulo,
    required this.categoria,
    required this.empresa,
    required this.ubicacion,
    required this.salario,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          "Detalles del Trabajo",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Titulo
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 10),

            // Empresa / Publicado por
            Text(
              "Publicado por: $empresa",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Categoria
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                categoria,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Descripcion
            const Text(
              "Descripción del Trabajo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              descripcion,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Ubicación
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 6),
                Text(
                  ubicacion,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Salario
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 4),
                Text(
                  salario,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Botón para postular
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Acción de postulación
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Postulado al trabajo #$trabajoId"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Postular Ahora",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
