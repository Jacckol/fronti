import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔹 Providers
import 'providers/auth_provider.dart';
import 'providers/trabajo_provider.dart';
import 'providers/empleador_provider.dart';

// 🔹 Pantallas
import 'screens/seleccion_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_user_screen.dart';
import 'screens/register_employer_screen.dart';
import 'screens/home_user.dart';
import 'screens/home_empleador.dart';
import 'screens/perfil_empleador_screen.dart'; // 👈 Importa la nueva pantalla

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TrabajoProvider()),
        ChangeNotifierProvider(create: (_) => EmpleadorProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TodoServy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF3F5F7),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        initialRoute: '/seleccion',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/seleccion':
              return MaterialPageRoute(
                builder: (_) => const SeleccionScreen(),
              );

            case '/login':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => LoginScreen(
                  rol: args['rol'] ?? 'usuario',
                ),
              );

            case '/register':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              if (args['rol'] == 'usuario') {
                return MaterialPageRoute(
                  builder: (_) => RegisterUserScreen(rol: 'usuario'),
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => RegisterEmployerScreen(rol: 'empleador'),
                );
              }

            case '/homeUser':
              return MaterialPageRoute(
                builder: (_) => const HomeUserScreen(),
              );

            case '/homeEmpleador':
              return MaterialPageRoute(
                builder: (_) => const HomeEmpleadorScreen(),
              );

            // 👇 Nueva ruta para el perfil del empleador
            case '/perfilEmpleador':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => PerfilEmpleadorScreen(
                  userId: args['userId'],
                  nombre: args['nombre'],
                  telefono: args['telefono'],
                ),
              );

            default:
              return MaterialPageRoute(
                builder: (_) => const SeleccionScreen(),
              );
          }
        },
      ),
    );
  }
}
