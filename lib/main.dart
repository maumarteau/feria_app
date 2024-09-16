// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/transaccion_provider.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => TransaccionProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feria Vecinal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Fondo blanco para toda la app
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Fondo blanco para el AppBar
          elevation: 0, // Sin sombra
          iconTheme: IconThemeData(color: Colors.black), // Iconos negros
          titleTextStyle:
              TextStyle(color: Colors.black, fontSize: 18.0), // Título negro
        ),
        primaryColor: Colors.white, // Asegurar que el primaryColor sea blanco
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.white, // Color primario blanco
          secondary: Colors.teal,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}
