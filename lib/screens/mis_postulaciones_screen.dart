import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/postulaciones_provider.dart';
import '../providers/auth_provider.dart';
import 'postulacion_detalle_screen.dart';

class MisPostulacionesScreen extends StatefulWidget {
  const MisPostulacionesScreen({super.key});

  @override
  State<MisPostulacionesScreen> createState() =>
      _MisPostulacionesScreenState();
}

enum FiltroPostulacion { todas, pendientes, aceptadas, rechazadas }

class _MisPostulacionesScreenState extends State<MisPostulacionesScreen> {
  FiltroPostulacion _filtro = FiltroPostulacion.todas;

  // ======================================================
  // 🔥 CARGAR POSTULACIONES
  // ======================================================
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postulacionesProv =
          context.read<PostulacionesProvider>();
      final auth = context.read<AuthProvider>();

      if (auth.userId != null) {
        postulacionesProv.cargarPostulaciones(auth.userId!);
      }
    });
  }

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

          // ================= CONTADORES =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _contador('Pendientes', prov.totalPendientes,
                    const Color(0xFFFFF7E0), const Color(0xFF92400E)),
                const SizedBox(width: 8),
                _contador('Aceptadas', prov.totalAceptadas,
                    const Color(0xFFE0FBEA), const Color(0xFF166534)),
                const SizedBox(width: 8),
                _contador('Rechazadas', prov.totalRechazadas,
                    const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ================= FILTROS =================
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

          // ================= LISTA =================
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
                    itemBuilder: (_, i) => _cardPostulacion(lista[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // CONTADOR
  // ======================================================
  Widget _contador(
      String label, int cantidad, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              cantidad.toString(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: textColor)),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // FILTRO CHIP
  // ======================================================
  Widget _filtroChip(String texto, FiltroPostulacion value) {
    final activo = _filtro == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filtro = value),
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
                  color:
                      activo ? Colors.white : const Color(0xFF6B7280)),
            ),
          ),
        ),
      ),
    );
  }

  // ======================================================
  // CARD POSTULACIÓN (CON ACEPTAR / RECHAZAR)
  // ======================================================
  Widget _cardPostulacion(Postulacion p) {
    Color bg;
    Color txt;
    String estadoTxt;

    switch (p.estado) {
      case EstadoPostulacion.aceptada:
        bg = const Color(0xFFE0FBEA);
        txt = const Color(0xFF166534);
        estadoTxt = 'Aceptada';
        break;
      case EstadoPostulacion.rechazada:
        bg = const Color(0xFFFEE2E2);
        txt = const Color(0xFFB91C1C);
        estadoTxt = 'Rechazada';
        break;
      default:
        bg = const Color(0xFFFFF7E0);
        txt = const Color(0xFF92400E);
        estadoTxt = 'Pendiente';
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
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(p.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(estadoTxt,
                style: TextStyle(
                    color: txt, fontSize: 11, fontWeight: FontWeight.w600)),
          )
        ]),

        const SizedBox(height: 10),

        Text(p.categoria,
            style: const TextStyle(
                color: Color(0xFF7C3AED), fontSize: 12)),

        const SizedBox(height: 14),

        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PostulacionDetalleScreen(postulacion: p),
              ),
            ),
            child: const Text('Ver detalle'),
          ),

          if (p.estado == EstadoPostulacion.pendiente)
            TextButton(
              onPressed: () {
                context
                    .read<PostulacionesProvider>()
                    .actualizarEstadoLocal(
                        p.id, EstadoPostulacion.aceptada);
              },
              child:
                  const Text('Aceptar', style: TextStyle(color: Colors.green)),
            ),

          if (p.estado == EstadoPostulacion.pendiente)
            TextButton(
              onPressed: () {
                context
                    .read<PostulacionesProvider>()
                    .actualizarEstadoLocal(
                        p.id, EstadoPostulacion.rechazada);
              },
              child:
                  const Text('Rechazar', style: TextStyle(color: Colors.red)),
            ),

          TextButton(
            onPressed: () {
              context
                  .read<PostulacionesProvider>()
                  .eliminarPostulacionLocal(p.id);
            },
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ])
      ]),
    );
  }
}
