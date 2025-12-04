import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BilleteraTrabajadorScreen extends StatelessWidget {
  const BilleteraTrabajadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mi Billetera (Trabajador)",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Resumen Financiero",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),
            const Text(
              "Tus ingresos generados por servicios",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            /// ============================
            /// RESUMEN DE INGRESOS
            /// ============================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardResumen(
                  "Total Ingreso",
                  "\$0.00",
                  "Del mes actual",
                  Icons.attach_money,
                  iconColor: Colors.green,
                ),
                _cardResumen(
                  "Servicios Realizados",
                  "0",
                  "Completados",
                  Icons.task_alt,
                  iconColor: Colors.blue,
                ),
                _cardResumen(
                  "Tendencia",
                  "0%",
                  "Estable",
                  Icons.trending_up,
                  iconColor: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Historial de Ingresos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// ============================
            /// LISTA DE INGRESOS (AÚN VACÍA)
            /// Luego la llenamos con la BD
            /// ============================
            _itemIngreso(
              "Sin ingresos aún",
              "Aún no completas servicios",
              0,
              "--/--/----",
            ),

            const SizedBox(height: 40),

            /// ============================
            /// BOTONES SECUNDARIOS
            /// ============================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _boton("Exportar Reporte"),
                _boton("Ver Detalles"),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // TARJETA RESUMEN
  // ======================================================
  Widget _cardResumen(
    String titulo,
    String total,
    String descripcion,
    IconData icon, {
    Color iconColor = Colors.blue,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 10),
          Text(
            total,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 3),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // ITEM INGRESO (similar a itemServicio, pero para ingresos)
  // ======================================================
  Widget _itemIngreso(String titulo, String cliente, double precio, String fecha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.shade50,
                child: const Icon(Icons.arrow_downward,
                    color: Colors.green, size: 26),
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style:
                        const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    cliente,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${precio.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              Text(
                fecha,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BOTÓN SIMPLE
  // ======================================================
  Widget _boton(String texto) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
