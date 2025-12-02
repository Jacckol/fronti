import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔹 Providers
import 'providers/auth_provider.dart';
import 'providers/trabajo_provider.dart';
import 'providers/trabajador_provider.dart';
import 'providers/postulaciones_provider.dart';
import 'providers/mis_servicios_provider.dart';
import 'providers/servicio_provider.dart';

// 🔹 Pantallas principales
import 'screens/seleccion_screen.dart';
import 'screens/login_screen.dart';

// 🔹 Registro
import 'screens/register_trabajador_screen.dart';
import 'screens/register_employer_screen.dart';

// 🔹 Home y módulos Empleador
import 'screens/empleador/home_empleador_screen.dart';
import 'screens/empleador/mis_publicaciones_screen.dart';
import 'screens/empleador/publicar_trabajo_screen.dart';

// 🔹 Home Trabajador y pantallas generales
import 'screens/home_trabajador.dart';
import 'screens/perfil_trabajador_screen.dart';
import 'screens/mis_postulaciones_screen.dart';

// 🔹 Ofertas (esta es la que EXISTE en tu proyecto)
import 'screens/ofertas_screen.dart';

// 🔹 Publicar servicio (trabajador)
import 'screens/publicar_servicio_screen.dart';

// 🔹 Publicaciones del trabajador
import 'screens/publicaciones_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}); // 👈 SIN CONST

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TrabajoProvider()),
        ChangeNotifierProvider(create: (_) => TrabajadorProvider()),
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
          final args =
              settings.arguments as Map<String, dynamic>? ?? {};
          final rol = args['rol'];

          switch (settings.name) {
            // ---------------------------------------
            // 🔹 Selección de Rol
            // ---------------------------------------
            case '/seleccion':
              return MaterialPageRoute(
                builder: (_) => SeleccionScreen(),
              );

            // ---------------------------------------
            // 🔹 Login
            // ---------------------------------------
            case '/login':
              return MaterialPageRoute(
                builder: (_) => LoginScreen(
                  rol: rol ?? 'trabajador',
                ),
              );

            // ---------------------------------------
            // 🔹 Registro
            // ---------------------------------------
            case '/register':
              if (rol == 'trabajador') {
                return MaterialPageRoute(
                  builder: (_) =>
                      RegisterTrabajadorScreen(rol: 'trabajador'),
                );
              }

              if (rol == 'empleador') {
                return MaterialPageRoute(
                  builder: (_) => RegisterEmployerScreen(),
                );
              }

              return MaterialPageRoute(
                builder: (_) => SeleccionScreen(),
              );

            // ---------------------------------------
            // 🔹 Home Empleador
            // ---------------------------------------
            case '/homeEmpleador':
              return MaterialPageRoute(
                builder: (_) => HomeEmpleadorScreen(),
              );

            // ---------------------------------------
            // 🔹 Home Trabajador
            // ---------------------------------------
            case '/homeTrabajador':
              return MaterialPageRoute(
                builder: (_) => HomeTrabajadorScreen(),
              );

            // ---------------------------------------
            // 🔹 Perfil Trabajador
            // ---------------------------------------
            case '/perfilTrabajador':
              return MaterialPageRoute(
                builder: (_) => PerfilTrabajadorScreen(
                  userId: args['userId'] ?? 0,
                  nombre: args['nombre'] ?? 'Sin nombre',
                  telefono: args['telefono'] ?? 'No registrado',
                ),
              );

            // ---------------------------------------
            // 🔹 Ofertas
            // ---------------------------------------
            case '/ofertasTrabajos':
              return MaterialPageRoute(
                builder: (_) => OfertasScreen(), // ✔️ ESTA ES LA REAL
              );

            // ---------------------------------------
            // 🔹 Mis Postulaciones (trabajador)
            // ---------------------------------------
            case '/misPostulaciones':
              return MaterialPageRoute(
                builder: (_) => MisPostulacionesScreen(),
              );

            // ---------------------------------------
            // 🔹 Publicar Servicio (trabajador)
            // ---------------------------------------
            case '/publicarServicio':
              return MaterialPageRoute(
                builder: (_) => PublicarServicioScreen(),
              );

            // ---------------------------------------
            // 🔹 Publicaciones (trabajador)
            // ---------------------------------------
            case '/publicaciones':
              return MaterialPageRoute(
                builder: (_) => PublicacionesScreen(),
              );

            // ---------------------------------------
            // 🔹 Empleador → Publicar Trabajo
            // ---------------------------------------
            case '/publicarTrabajo':
              return MaterialPageRoute(
                builder: (_) => PublicarTrabajoScreen(),
              );

            // ---------------------------------------
            // 🔹 Empleador → Mis Publicaciones
            // ---------------------------------------
            case '/misPublicaciones':
              return MaterialPageRoute(
                builder: (_) => MisPublicacionesScreen(),
              );

            // ---------------------------------------
            // 🔹 Default
            // ---------------------------------------
            default:
              return MaterialPageRoute(
                builder: (_) => SeleccionScreen(),
              );
          }
        },
      ),
    );
  }
}
