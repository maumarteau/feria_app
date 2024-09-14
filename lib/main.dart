import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaccion_provider.dart';
import 'pages/login_page.dart';

void main() {
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
        primarySwatch: const MaterialColor(0xFF0A204C, {
          50: Color(0xFFE8F0FF),
          100: Color(0xFFC5D4E9),
          200: Color(0xFF9FB8D3),
          300: Color(0xFF7A9CBF),
          400: Color(0xFF5A83AE),
          500: Color(0xFF3B6A9D),
          600: Color(0xFF345F94),
          700: Color(0xFF2C548A),
          800: Color(0xFF24497F),
          900: Color(0xFF1D3E75),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}
