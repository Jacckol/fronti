import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/auth_provider.dart';

import 'pago_paypal_screen.dart';
import 'historial_transacciones_screen.dart';

class MiBilleteraEmpleadorScreen extends StatefulWidget {
  const MiBilleteraEmpleadorScreen({super.key});

  @override
  State<MiBilleteraEmpleadorScreen> createState() =>
      _MiBilleteraEmpleadorScreenState();
}

class _MiBilleteraEmpleadorScreenState
    extends State<MiBilleteraEmpleadorScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final transProv =
        Provider.of<TransactionsProvider>(context, listen: false);

    transProv.cargarTransacciones(auth.token!);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transProv = Provider.of<TransactionsProvider>(context);
    final trans = transProv.transacciones;

    double totalGastos = 0;
    for (var t in trans) {
      if (t["tipo"] == "gasto") {
        totalGastos += (t["monto"] as num).toDouble();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1FF),
      appBar: AppBar(
        title: const Text(
          "Mi Billetera",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6D4AFF),
        elevation: 0,
      ),

      body: transProv.loading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardGlassResumen(totalGastos),
                    const SizedBox(height: 25),

                    // 🔥 BOTONES MEJORADOS
                    _botonGradiente(
                      text: "Pagar con PayPal (Simulado)",
                      icon: Icons.payment,
                      colors: const [Color(0xFF6D4AFF), Color(0xFF9D7BFF)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PagoPayPalScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _botonGradiente(
                      text: "Ver Historial Completo",
                      icon: Icons.history,
                      colors: const [Colors.black87, Colors.black54],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const HistorialTransaccionesScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Últimos Gastos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: ListView.builder(
                        itemCount: trans.length,
                        itemBuilder: (_, i) {
                          final t = trans[i];
                          if (t["tipo"] != "gasto") return const SizedBox();
                          return _itemNeomorfico(
                            descripcion: t["descripcion"] ?? "Pago",
                            monto: (t["monto"] as num).toDouble(),
                            fecha: t["createdAt"],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ⭐ TARJETA GLASS EFFECT
  Widget _cardGlassResumen(double total) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.wallet, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Gastado",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ⭐ BOTÓN CON GRADIENTE
  Widget _botonGradiente({
    required String text,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ ITEM DE TRANSACCIÓN NEOMÓRFICO
  Widget _itemNeomorfico({
    required String descripcion,
    required double monto,
    required String fecha,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F1FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0xFFB6A8FF),
            offset: Offset(4, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_upward,
                color: Colors.red, size: 26),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fecha.substring(0, 10),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            "-\$${monto.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
