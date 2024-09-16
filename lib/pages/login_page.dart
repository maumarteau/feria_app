// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/feria_list_page.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import '../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool passwordVisible = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void _login() async {
    String username = userController.text.trim();
    String password = passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingrese usuario y contraseña.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('user', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loggedInUser', username);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeriaListPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inicia sesión en tu\ncuenta',
                    style: heading2.copyWith(color: textBlack),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                child: Column(
                  children: [
                    InputField(
                      hintText: 'Usuario',
                      controller: userController,
                    ),
                    const SizedBox(height: 32),
                    InputField(
                      hintText: 'Contraseña',
                      controller: passController,
                      obscureText: !passwordVisible,
                      suffixIcon: IconButton(
                        color: textGrey,
                        splashRadius: 1,
                        icon: Icon(passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: togglePassword,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomPrimaryButton(
                buttonColor: primaryBlue,
                textValue: 'Iniciar Sesión',
                textColor: Colors.white,
                onPressed: _login,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
