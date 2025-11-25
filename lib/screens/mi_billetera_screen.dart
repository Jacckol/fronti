import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MiBilleteraScreen extends StatelessWidget {
  const MiBilleteraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Portal Empleador",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.logout, color: Colors.black),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            const Text(
              "Mi Billetera",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),
            const Text(
              "Control de gastos e inversión en servicios",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // ===================== Combo de selector (mes) =====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: "Este mes",
                  items: const [
                    DropdownMenuItem(value: "Este mes", child: Text("Este mes")),
                    DropdownMenuItem(value: "Octubre", child: Text("Octubre")),
                    DropdownMenuItem(value: "Septiembre", child: Text("Septiembre")),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===================== TARJETAS DE RESUMEN =====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardResumen(
                  "Total Gastado",
                  "€950",
                  "En servicios",
                  Icons.account_balance_wallet,
                ),
                _cardResumen(
                  "Promedio por Servicio",
                  "\$158",
                  "6 servicios",
                  Icons.price_change,
                ),
                _cardResumen(
                  "Cambio Mensual",
                  "67.1%",
                  "Reducción",
                  Icons.trending_down,
                  iconColor: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Historial de Transacciones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // ===================== LISTA DE SERVICIOS =====================
            _itemServicio("Reparación Eléctrica", "Carlos Rodríguez", 150, "02 nov 2025"),
            _itemServicio("Limpieza Profunda", "María García", 85, "01 nov 2025"),
            _itemServicio("Pintura de Habitación", "Juan Martínez", 320, "27 oct 2025"),
            _itemServicio("Instalación de Grifo", "Ana López", 95, "24 oct 2025"),
            _itemServicio("Mantenimiento Jardín", "Pedro Sánchez", 120, "19 oct 2025"),
            _itemServicio("Reparación Puerta", "Laura Fernández", 180, "14 oct 2025"),

            const SizedBox(height: 30),

            // ===================== BOTONES INFERIORES =====================
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

  // ===================== WIDGET TARJETA RESUMEN =====================
  Widget _cardResumen(String titulo, String total, String descripcion, IconData icon,
      {Color iconColor = Colors.blue}) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
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
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ===================== ITEM DEL HISTORIAL =====================
  Widget _itemServicio(String titulo, String user, double precio, String fecha) {
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
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.attach_money, color: Colors.blue, size: 26),
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user,
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
                "€${precio.toString()}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                fecha,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ===================== BOTÓN =====================
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
