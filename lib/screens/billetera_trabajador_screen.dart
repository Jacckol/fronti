import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/transactions_provider.dart';
import '../../providers/auth_provider.dart';

class BilleteraTrabajadorScreen extends StatefulWidget {
  const BilleteraTrabajadorScreen({super.key});

  @override
  State<BilleteraTrabajadorScreen> createState() =>
      _BilleteraTrabajadorScreenState();
}

class _BilleteraTrabajadorScreenState
    extends State<BilleteraTrabajadorScreen> {

  @override
  void initState() {
    super.initState();

    // 🔥 CARGAR INGRESOS DEL TRABAJADOR
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context
          .read<TransactionsProvider>()
          .cargarTransacciones(auth.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transProv = context.watch<TransactionsProvider>();

    // 🔹 SOLO INGRESOS
    final ingresos = transProv.transacciones
        .where((t) => t["tipo"] == "ingreso")
        .toList();

    // 🔹 TOTAL INGRESOS
    final totalIngreso = ingresos.fold<double>(
      0,
      (sum, t) => sum + (t["monto"] as num).toDouble(),
    );

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

      body: transProv.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "Resumen Financiero",
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),
                  const Text(
                    "Tus ingresos generados por servicios",
                    style:
                        TextStyle(fontSize: 15, color: Colors.black54),
                  ),

                  const SizedBox(height: 25),

                  /// ============================
                  /// RESUMEN
                  /// ============================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _cardResumen(
                        "Total Ingreso",
                        "\$${totalIngreso.toStringAsFixed(2)}",
                        "Acumulado",
                        Icons.attach_money,
                        iconColor: Colors.green,
                      ),
                      _cardResumen(
                        "Servicios",
                        ingresos.length.toString(),
                        "Pagados",
                        Icons.task_alt,
                        iconColor: Colors.blue,
                      ),
                      _cardResumen(
                        "Estado",
                        ingresos.isEmpty ? "0%" : "↑",
                        "Activo",
                        Icons.trending_up,
                        iconColor: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Historial de Ingresos",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ingresos.isEmpty
                      ? _itemIngreso(
                          "Sin ingresos aún",
                          "Aún no te han pagado",
                          0,
                          "--/--/----",
                        )
                      : Column(
                          children: ingresos.map((t) {
                            return _itemIngreso(
                              t["descripcion"] ?? "Pago recibido",
                              "Empleador",
                              (t["monto"] as num).toDouble(),
                              DateFormat('dd/MM/yyyy')
                                  .format(DateTime.parse(t["createdAt"])),
                            );
                          }).toList(),
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
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 10),
          Text(
            total,
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // ITEM INGRESO
  // ======================================================
  Widget _itemIngreso(
      String titulo, String cliente, double precio, String fecha) {
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
                    color: Colors.green),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    cliente,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              Text(
                fecha,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
