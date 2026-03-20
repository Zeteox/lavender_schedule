import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/main.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Calendar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF282828), // Anthracite
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE7CCF5),   // Lavande
          secondary: Color(0xFF9155AB), // Violet foncé
          surface: Color(0xFF282828),
          onSurface: Color(0xFFFFEFDC), // Crème
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF282828),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFFE7CCF5)),
          titleTextStyle: TextStyle(color: Color(0xFFFFEFDC), fontSize: 24, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFFFEFDC)),
          bodyLarge: TextStyle(color: Color(0xFFFFEFDC)),
          titleMedium: TextStyle(color: Color(0xFFE7CCF5)),
        ),
      ),
    );
  }
}