import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9155AB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text("Bienvenue", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFFFEFDC), letterSpacing: 1.5)),
            const SizedBox(height: 16),
            const Text("Préparation de vos informations...", style: TextStyle(fontSize: 16, color: Color(0xFFFFEFDC), fontStyle: FontStyle.italic)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFFFFEFDC)),
          ],
        ),
      ),
    );
  }
}