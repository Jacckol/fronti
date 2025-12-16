import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 🔹 Providers
import 'providers/auth_provider.dart';
import 'providers/trabajo_provider.dart';
import 'providers/trabajador_provider.dart';
import 'providers/postulaciones_provider.dart';
import 'providers/mis_servicios_provider.dart';
import 'providers/servicio_provider.dart';
import 'providers/transactions_provider.dart';
import 'providers/notificaciones_provider.dart';

// 🔹 Pantallas principales
import 'screens/seleccion_screen.dart';
import 'screens/login_screen.dart';

// 🔹 Registro
import 'screens/register_trabajador_screen.dart';
import 'screens/register_employer_screen.dart';

// 🔹 Home Empleador
import 'screens/empleador/home_empleador_screen.dart';
import 'screens/empleador/mis_publicaciones_screen.dart';
import 'screens/empleador/publicar_trabajo_screen.dart';
import 'screens/empleador/mi_billetera_screen.dart';
import 'screens/empleador/historial_transacciones_screen.dart';
import 'screens/empleador/pago_paypal_screen.dart';

// 🔹 Home Trabajador
import 'screens/home_trabajador.dart';
import 'screens/perfil_trabajador_screen.dart';
import 'screens/mis_postulaciones_screen.dart';
import 'screens/publicar_servicio_screen.dart';
import 'screens/publicaciones_screen.dart';

// 🔹 Ofertas y trabajos
import 'screens/ofertas_screen.dart';
import 'screens/ofertas_trabajos_screen.dart';

// 🔹 Notificaciones (UNIFICADA)
import 'screens/notificaciones/notificaciones_screen.dart';
import 'screens/notificaciones/notificacion_detalle_screen.dart';

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
        ChangeNotifierProvider(create: (_) => TrabajadorProvider()),
        ChangeNotifierProvider(create: (_) => PostulacionesProvider()),
        ChangeNotifierProvider(create: (_) => MisServiciosProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
        ChangeNotifierProvider(create: (_) => TransactionsProvider()),

        // ⭐⭐⭐ Provider de notificaciones ⭐⭐⭐
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
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

        // ==========================================================
        // 🔥 Sistema completo de rutas
        // ==========================================================
        onGenerateRoute: (settings) {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final rol = args['rol'];

          switch (settings.name) {

            // 🔹 Selección de rol
            case '/seleccion':
              return MaterialPageRoute(builder: (_) => const SeleccionScreen());

            // 🔹 Login
            case '/login':
              return MaterialPageRoute(
                builder: (_) => LoginScreen(rol: rol ?? 'trabajador'),
              );

            // 🔹 Registro
            case '/register':
              if (rol == 'trabajador') {
                return MaterialPageRoute(
                  builder: (_) => const RegisterTrabajadorScreen(rol: 'trabajador'),
                );
              }
              if (rol == 'empleador') {
                return MaterialPageRoute(
                  builder: (_) => const RegisterEmployerScreen(),
                );
              }
              return MaterialPageRoute(builder: (_) => const SeleccionScreen());

            // 🔹 Home Empleador
            case '/homeEmpleador':
              return MaterialPageRoute(builder: (_) => const HomeEmpleadorScreen());

            // 🔹 Home Trabajador
            case '/homeTrabajador':
              return MaterialPageRoute(builder: (_) => const HomeTrabajadorScreen());

            // 🔹 Perfil trabajador
            case '/perfilTrabajador':
              return MaterialPageRoute(
                builder: (_) => PerfilTrabajadorScreen(
                  userId: args['userId'] ?? 0,
                  nombre: args['nombre'] ?? 'Sin nombre',
                  telefono: args['telefono'] ?? 'No registrado',
                ),
              );

            // 🔹 Ofertas
            case '/ofertasServicios':
              return MaterialPageRoute(builder: (_) => const OfertasScreen());

            case '/ofertasTrabajos':
              return MaterialPageRoute(builder: (_) => const OfertasTrabajosScreen());

            // 🔹 Mis Postulaciones
            case '/misPostulaciones':
              return MaterialPageRoute(builder: (_) => const MisPostulacionesScreen());

            // 🔹 Publicar servicios
            case '/publicarServicio':
              return MaterialPageRoute(builder: (_) => const PublicarServicioScreen());

            case '/publicaciones':
              return MaterialPageRoute(builder: (_) => const PublicacionesScreen());

            // 🔹 Empleador – Publicar trabajo
            case '/publicarTrabajo':
              return MaterialPageRoute(builder: (_) => const PublicarTrabajoScreen());

            // 🔹 Empleador – Mis publicaciones
            case '/misPublicaciones':
              return MaterialPageRoute(builder: (_) => const MisPublicacionesScreen());

            // 🔹 Billetera empleador
            case '/miBilleteraEmpleador':
              return MaterialPageRoute(builder: (_) => const MiBilleteraEmpleadorScreen());

            // 🔹 Historial de transacciones
            case '/historialTransacciones':
              return MaterialPageRoute(builder: (_) => const HistorialTransaccionesScreen());

            // 🔹 Pago PayPal (simulado)
            case '/pagoPaypal':
              return MaterialPageRoute(builder: (_) => const PagoPayPalScreen());

            // ⭐ 🔥 NUEVA PANTALLA UNIFICADA DE NOTIFICACIONES
            case '/notificaciones':
              return MaterialPageRoute(builder: (_) => const NotificacionesScreen());

            // ⭐ 🔥 Pantalla de detalle de notificación
            case '/notificacionDetalle':
              return MaterialPageRoute(
                builder: (_) => NotificacionDetalleScreen(
                  notificacion: args['notificacion'],
                ),
              );

            default:
              return MaterialPageRoute(builder: (_) => const SeleccionScreen());
          }
        },
      ),
    );
  }
}
