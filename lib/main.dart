import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔹 Providers
import 'providers/auth_provider.dart';
import 'providers/trabajo_provider.dart';
import 'providers/trabajador_provider.dart';          // CAMBIADO
import 'providers/postulaciones_provider.dart';
import 'providers/mis_servicios_provider.dart';
import 'providers/servicio_provider.dart';

// 🔹 Pantallas
import 'screens/seleccion_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_user_screen.dart';
import 'screens/register_trabajador_screen.dart';     // CAMBIADO
import 'screens/home_user.dart';
import 'screens/home_trabajador.dart';                // CAMBIADO
import 'screens/perfil_trabajador_screen.dart';       // CAMBIADO
import 'screens/mis_postulaciones_screen.dart';
import 'screens/ofertas_screen.dart';
import 'screens/publicar_servicio_screen.dart';
import 'screens/publicaciones_screen.dart';
// import 'screens/mi_billetera_screen.dart'; // opcional

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
        ChangeNotifierProvider(create: (_) => TrabajadorProvider()),        // CAMBIO
        ChangeNotifierProvider(create: (_) => PostulacionesProvider()),
        ChangeNotifierProvider(create: (_) => MisServiciosProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
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
              return MaterialPageRoute(
                builder: (_) => args['rol'] == 'usuario'
                    ? RegisterUserScreen(rol: 'usuario')
                    : RegisterTrabajadorScreen(rol: 'trabajador'),     // CAMBIO
              );

            case '/homeUser':
              return MaterialPageRoute(
                builder: (_) => const HomeUserScreen(),
              );

            case '/homeTrabajador':                                     // CAMBIO
              return MaterialPageRoute(
                builder: (_) => const HomeTrabajadorScreen(),
              );

            case '/perfilTrabajador':                                   // CAMBIO
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => PerfilTrabajadorScreen(
                  userId: args['userId'] ?? 0,
                  nombre: args['nombre'] ?? 'Sin nombre',
                  telefono: args['telefono'] ?? 'No registrado',
                ),
              );

            case '/ofertas':
              return MaterialPageRoute(
                builder: (_) => const OfertasScreen(),
              );

            case '/misPostulaciones':
              return MaterialPageRoute(
                builder: (_) => const MisPostulacionesScreen(),
              );

            case '/publicarServicio':
              return MaterialPageRoute(
                builder: (_) => const PublicarServicioScreen(),
              );

            case '/publicaciones':
              return MaterialPageRoute(
                builder: (_) => const PublicacionesScreen(),
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
