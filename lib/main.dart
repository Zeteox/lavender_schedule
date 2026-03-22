import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/utils/scrapper.dart';
import 'router/main.dart';

void main() {
  Scrapper.init("https://hp25.ynov.com/TOU/Telechargements/ical/Edt_DELPRAT.ics?version=2025.8.9&icalsecurise=8DB4E762E92AE5B045219AC821EC019539D424048D1CD4A5DE9D3C28B0A00EF48A260A6B1B440D6F388575898C3CFE9F&param=643d5b312e2e36325d2666683d3126663d31");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Lavender Schedule',
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