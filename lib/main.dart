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

// 🔹 Home Trabajador + módulos
import 'screens/home_trabajador.dart';
import 'screens/perfil_trabajador_screen.dart';
import 'screens/mis_postulaciones_screen.dart';
import 'screens/publicar_servicio_screen.dart';
import 'screens/publicaciones_screen.dart';

// 🔥 SERVICIOS PUBLICADOS POR TRABAJADOR (YA EXISTE)
import 'screens/ofertas_screen.dart';

// 🔥 TRABAJOS PUBLICADOS POR EMPLEADOR (NUEVA PANTALLA)
import 'screens/ofertas_trabajos_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

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
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final rol = args['rol'];

          switch (settings.name) {

            // ⭐ SELECCIÓN DE ROL
            case '/seleccion':
              return MaterialPageRoute(builder: (_) => SeleccionScreen());

            // ⭐ LOGIN
            case '/login':
              return MaterialPageRoute(
                builder: (_) => LoginScreen(rol: rol ?? 'trabajador'),
              );

            // ⭐ REGISTRO
            case '/register':
              if (rol == 'trabajador') {
                return MaterialPageRoute(
                  builder: (_) => RegisterTrabajadorScreen(rol: 'trabajador'),
                );
              }
              if (rol == 'empleador') {
                return MaterialPageRoute(
                  builder: (_) => RegisterEmployerScreen(),
                );
              }
              return MaterialPageRoute(builder: (_) => SeleccionScreen());

            // ⭐ HOME EMPLEADOR
            case '/homeEmpleador':
              return MaterialPageRoute(builder: (_) => HomeEmpleadorScreen());

            // ⭐ HOME TRABAJADOR
            case '/homeTrabajador':
              return MaterialPageRoute(builder: (_) => HomeTrabajadorScreen());

            // ⭐ PERFIL TRABAJADOR
            case '/perfilTrabajador':
              return MaterialPageRoute(
                builder: (_) => PerfilTrabajadorScreen(
                  userId: args['userId'] ?? 0,
                  nombre: args['nombre'] ?? 'Sin nombre',
                  telefono: args['telefono'] ?? 'No registrado',
                ),
              );

            // ⭐ SERVICIOS PUBLICADOS POR TRABAJADORES
            case '/ofertasServicios':
              return MaterialPageRoute(builder: (_) => OfertasScreen());

            // ⭐ TRABAJOS PUBLICADOS POR EMPLEADOR
            case '/ofertasTrabajos':
              return MaterialPageRoute(builder: (_) => OfertasTrabajosScreen());

            // ⭐ MIS POSTULACIONES
            case '/misPostulaciones':
              return MaterialPageRoute(builder: (_) => MisPostulacionesScreen());

            // ⭐ PUBLICAR SERVICIO
            case '/publicarServicio':
              return MaterialPageRoute(builder: (_) => PublicarServicioScreen());

            // ⭐ PUBLICACIONES TRABAJADOR
            case '/publicaciones':
              return MaterialPageRoute(builder: (_) => PublicacionesScreen());

            // ⭐ EMPLEADOR - PUBLICAR TRABAJO
            case '/publicarTrabajo':
              return MaterialPageRoute(builder: (_) => PublicarTrabajoScreen());

            // ⭐ EMPLEADOR - MIS PUBLICACIONES
            case '/misPublicaciones':
              return MaterialPageRoute(builder: (_) => MisPublicacionesScreen());

            // ⭐ EMPLEADOR - BILLETERA
            case '/miBilleteraEmpleador':
              return MaterialPageRoute(
                  builder: (_) => MiBilleteraEmpleadorScreen());

            // ⭐ EMPLEADOR - HISTORIAL
            case '/historialTransacciones':
              return MaterialPageRoute(
                  builder: (_) => HistorialTransaccionesScreen());

            // ⭐ SIMULACIÓN PAYPAL
            case '/pagoPaypal':
              return MaterialPageRoute(builder: (_) => PagoPayPalScreen());

            default:
              return MaterialPageRoute(builder: (_) => SeleccionScreen());
          }
        },
      ),
    );
  }
}
