import 'package:flutter/material.dart';
// Asumiendo que estas clases están definidas en sus respectivos archivos:
import 'ahorro.dart';        // Contiene AhorroScreen
import 'friccion.dart';      // Contiene FriccionActivity
import 'recirculacion.dart'; // Contiene RecirculacionActivity
import 'valvula.dart';       // Contiene ValvulaActivity
import 'torre.dart';         // Contiene TorreActivity
import 'login_screen.dart';  // Contiene LoginScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión de Recursos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // CORRECCIÓN 1: Mejor contraste para el texto del botón
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Texto blanco para alto contraste
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 4,
          color: Colors.blueAccent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        // CORRECCIÓN 2: Reemplazar IneficienteScreen por AhorroScreen
        '/ahorro': (context) => AhorroScreen(), 
        '/friccion': (context) => FriccionActivity(),
        '/recirculacion': (context) => RecirculacionActivity(),
        '/valvula': (context) => ValvulaActivity(),
        '/torre': (context) => TorreActivity(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  // CORRECCIÓN 3: Reemplazar IneficienteScreen por AhorroScreen
                  MaterialPageRoute(builder: (context) => AhorroScreen()), 
                );
              },
              child: const Text('Motobombas Ineficientes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriccionActivity()),
                );
              },
              child: const Text('Pérdidas por Fricción'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecirculacionActivity()),
                );
              },
              child: const Text('Recirculación de Agua'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ValvulaActivity()),
                );
              },
              child: const Text('Válvula Parcialmente Cerrada'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TorreActivity()),
                );
              },
              child: const Text('Torre de Enfriamiento'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Asume que LoginScreen está definido en login_screen.dart
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: const Icon(Icons.exit_to_app),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
