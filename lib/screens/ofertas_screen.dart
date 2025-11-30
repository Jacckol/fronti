import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/postulaciones_provider.dart';

class OfertasScreen extends StatelessWidget {
  const OfertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trabajos = [
      {
        'id': 1,
        'titulo': 'Reparación de instalación eléctrica',
        'categoria': 'Electricidad',
        'urgente': true,
        'publicadoPor': 'Juan Pérez',
        'descripcion':
            'Necesito reparar la instalación eléctrica de mi cocina. Se han detectado problemas con varios enchufes y necesito que un profesional revise todo el sistema.',
        'ubicacion': 'Madrid, Centro',
        'presupuesto': 150,
        'duracion': '3-8 horas',
        'postulaciones': 8,
        'hace': '4 días',
      },
      {
        'id': 2,
        'titulo': 'Pintura completa de apartamento',
        'categoria': 'Pintura',
        'urgente': false,
        'publicadoPor': 'María González',
        'descripcion':
            'Apartamento de 80m² que necesita pintura completa en todas las habitaciones. Incluye techo y paredes. Preferible uso de pintura ecológica.',
        'ubicacion': 'Madrid, Norte',
        'presupuesto': 800,
        'duracion': '2-3 días',
        'postulaciones': 12,
        'hace': '6 días',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas disponibles'),
        backgroundColor: const Color(0xFF8B5CF6),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/misPostulaciones');
            },
            child: const Text(
              'Mis Postulaciones',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: trabajos.length,
          itemBuilder: (context, index) {
            final t = trabajos[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Título y etiqueta "Urgente"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          t['titulo'].toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (t['urgente'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Urgente',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 🔹 Categoría y autor
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t['categoria'].toString(),
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Publicado por ${t['publicadoPor'].toString()}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 🔹 Descripción
                  Text(
                    t['descripcion'].toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Detalles (ubicación, presupuesto, duración)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            t['ubicacion'].toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              size: 16, color: Colors.grey),
                          Text(
                            '${t['presupuesto']}€',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            t['duracion'].toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Postulaciones y botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hace ${t['hace'].toString()} • ${t['postulaciones']} postulaciones',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 👉 GUARDAR POSTULACIÓN EN PROVIDER
                          final postProv =
                              context.read<PostulacionesProvider>();
                          postProv.agregarDesdeTrabajo(t);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Te has postulado a "${t['titulo']}"',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black87,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Ir a Mis Postulaciones
                          Navigator.pushNamed(context, '/misPostulaciones');
                        },
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text('Postularme'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
