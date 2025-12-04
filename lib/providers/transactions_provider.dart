import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransactionsProvider extends ChangeNotifier {
  List<dynamic> transacciones = [];
  bool loading = false;

  Future<void> cargarTransacciones(String token) async {
    loading = true;
    notifyListeners();

    // 👉 IP REAL PARA EMULADOR (10.0.2.2) + PUERTO REAL (4000)
    final url = Uri.parse("http://10.0.2.2:4000/api/transactions/mine");

    final resp = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    loading = false;

    if (resp.statusCode == 200) {
      transacciones = jsonDecode(resp.body);
      notifyListeners();
    } else {
      transacciones = [];
      notifyListeners();
    }
  }
}
