import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';

class PagoPayPalScreen extends StatefulWidget {
  const PagoPayPalScreen({super.key});

  @override
  State<PagoPayPalScreen> createState() => _PagoPayPalScreenState();
}

class _PagoPayPalScreenState extends State<PagoPayPalScreen> {
  final montoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final tarjetaCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();

  bool cargando = false;

  Future<void> procesarPago() async {
    if (montoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa un monto válido")),
      );
      return;
    }

    setState(() => cargando = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final url = Uri.parse("http://10.0.2.2:4000/api/transactions");

    final resp = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${auth.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": auth.userId,
        "monto": double.parse(montoCtrl.text),
        "tipo": "gasto",
        "descripcion": "Pago con PayPal (simulado)"
      }),
    );

    setState(() => cargando = false);

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pago realizado con éxito")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${resp.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pago PayPal (Simulado)"),
        backgroundColor: Colors.deepPurple,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Monto a pagar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: montoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Ej: 20.00",
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Datos de tarjeta (Simulado)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre en la tarjeta",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: tarjetaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Número de tarjeta",
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: cvvCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "CVV",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: procesarPago,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Confirmar Pago",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
