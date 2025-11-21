import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔹 Providers
import 'providers/auth_provider.dart';
import 'providers/trabajo_provider.dart';
import 'providers/empleador_provider.dart';
import 'providers/postulaciones_provider.dart';

// 🔹 Pantallas
import 'screens/seleccion_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_user_screen.dart';
import 'screens/register_employer_screen.dart';
import 'screens/home_user.dart';
import 'screens/home_empleador.dart';
import 'screens/perfil_empleador_screen.dart';
import 'screens/mis_postulaciones_screen.dart';
import 'screens/ofertas_screen.dart';

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
        ChangeNotifierProvider(create: (_) => PostulacionesProvider()),
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

        // 🚀 Pantalla inicial
        initialRoute: '/seleccion',

        // ===============================================
        // 🔥 onGenerateRoute — TODAS LAS RUTAS DEFINIDAS
        // ===============================================
        onGenerateRoute: (settings) {
          switch (settings.name) {

            // 🔹 Pantalla de selección de rol
            case '/seleccion':
              return MaterialPageRoute(builder: (_) => const SeleccionScreen());

            // 🔹 Login
            case '/login':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => LoginScreen(
                  rol: args['rol'] ?? 'usuario',
                ),
              );

            // 🔹 Registro según rol
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

            // 🔹 Home Usuario
            case '/homeUser':
              return MaterialPageRoute(
                builder: (_) => const HomeUserScreen(),
              );

            // 🔹 Home Empleador
            case '/homeEmpleador':
              return MaterialPageRoute(
                builder: (_) => const HomeEmpleadorScreen(),
              );

            // 🔹 Perfil Empleador
            case '/perfilEmpleador':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => PerfilEmpleadorScreen(
                  userId: args['userId'] ?? 0,
                  nombre: args['nombre'] ?? 'Sin nombre',
                  telefono: args['telefono'] ?? 'No registrado',
                ),
              );

            // 🔹 Ofertas Screen
            case '/ofertas':
              return MaterialPageRoute(builder: (_) => const OfertasScreen());

            // 🔹 Mis Postulaciones
            case '/misPostulaciones':
              return MaterialPageRoute(
                builder: (_) => const MisPostulacionesScreen(),
              );

            // 🔹 Ruta desconocida → regresar a selección
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
