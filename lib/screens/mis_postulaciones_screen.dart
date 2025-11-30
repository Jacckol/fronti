import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/postulaciones_provider.dart';

class MisPostulacionesScreen extends StatefulWidget {
  const MisPostulacionesScreen({super.key});

  @override
  State<MisPostulacionesScreen> createState() => _MisPostulacionesScreenState();
}

enum FiltroPostulacion { todas, pendientes, aceptadas, rechazadas }

class _MisPostulacionesScreenState extends State<MisPostulacionesScreen> {
  FiltroPostulacion _filtro = FiltroPostulacion.todas;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PostulacionesProvider>();

    List<Postulacion> lista;
    switch (_filtro) {
      case FiltroPostulacion.pendientes:
        lista = prov.pendientes;
        break;
      case FiltroPostulacion.aceptadas:
        lista = prov.aceptadas;
        break;
      case FiltroPostulacion.rechazadas:
        lista = prov.rechazadas;
        break;
      case FiltroPostulacion.todas:
      default:
        lista = prov.todas;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Postulaciones'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 🔹 Contadores (como las tarjetas de arriba)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _contadorCard(
                  label: 'Pendientes',
                  color: const Color(0xFFFFF7E0),
                  textColor: const Color(0xFF92400E),
                  cantidad: prov.totalPendientes,
                ),
                const SizedBox(width: 8),
                _contadorCard(
                  label: 'Aceptadas',
                  color: const Color(0xFFE0FBEA),
                  textColor: const Color(0xFF166534),
                  cantidad: prov.totalAceptadas,
                ),
                const SizedBox(width: 8),
                _contadorCard(
                  label: 'Rechazadas',
                  color: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFFB91C1C),
                  cantidad: prov.totalRechazadas,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Filtros tipo tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filtroChip('Todas', FiltroPostulacion.todas),
                _filtroChip('Pendientes', FiltroPostulacion.pendientes),
                _filtroChip('Aceptadas', FiltroPostulacion.aceptadas),
                _filtroChip('Rechazadas', FiltroPostulacion.rechazadas),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Aún no tienes postulaciones',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    itemBuilder: (_, index) {
                      final p = lista[index];
                      return _cardPostulacion(p);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _contadorCard({
    required String label,
    required int cantidad,
    required Color color,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              cantidad.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtroChip(String texto, FiltroPostulacion value) {
    final bool activo = _filtro == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filtro = value;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: activo ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12,
                color: activo ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardPostulacion(Postulacion p) {
    Color etiquetaColor;
    Color etiquetaTexto;
    String etiquetaTextoStr;

    switch (p.estado) {
      case EstadoPostulacion.aceptada:
        etiquetaColor = const Color(0xFFE0FBEA);
        etiquetaTexto = const Color(0xFF166534);
        etiquetaTextoStr = 'Aceptada';
        break;
      case EstadoPostulacion.rechazada:
        etiquetaColor = const Color(0xFFFEE2E2);
        etiquetaTexto = const Color(0xFFB91C1C);
        etiquetaTextoStr = 'Rechazada';
        break;
      case EstadoPostulacion.pendiente:
      default:
        etiquetaColor = const Color(0xFFFFF7E0);
        etiquetaTexto = const Color(0xFF92400E);
        etiquetaTextoStr = 'Pendiente';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  p.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: etiquetaColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  etiquetaTextoStr,
                  style: TextStyle(
                    color: etiquetaTexto,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Categoria + empleador
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p.categoria,
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Empleador: ${p.empleador}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Ubicación + dinero + duración
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    p.ubicacion,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.attach_money,
                      size: 14, color: Colors.grey),
                  Text(
                    '${p.presupuesto.toStringAsFixed(0)}€',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    p.duracion,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mensaje del usuario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tu mensaje: ${p.mensaje}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          // Fecha + botón
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Postulado: ${p.fecha.day}/${p.fecha.month}/${p.fecha.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              TextButton(
                onPressed: () {
                  // Aquí luego puedes abrir chat o lo que quieras
                },
                child: const Text(
                  'Ver Detalles',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
