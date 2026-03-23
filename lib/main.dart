import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/alarm_settings.dart';
import 'package:lavender_schedule/ui/alarm_ring_page.dart';
import 'package:lavender_schedule/utils/alarm_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lavender_schedule/utils/scrapper.dart';
import 'router/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString('ics_url') ?? "";
  Scrapper.init(savedUrl);
  await Alarm.init();

  final savedSettings = AlarmAppSettings(
    isActivated: prefs.getBool('alarm_activated') ?? false,
    minutesBefore: prefs.getInt('alarm_minutes_before_class') ?? 30,
  );
  if (savedUrl.isNotEmpty) {
    await scheduleAlarms(savedSettings);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AlarmSet>? _alarmSubscription;

  @override
  void initState() {
    super.initState();
    _alarmSubscription = Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isEmpty) return;
      router.routerDelegate.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => AlarmRingPage(alarmSet: alarmSet),
        ),
      );
    });
  }

  @override
  void dispose() {
    _alarmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Lavender Schedule',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF282828),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE7CCF5),
          secondary: Color(0xFF9155AB),
          surface: Color(0xFF282828),
          onSurface: Color(0xFFFFEFDC),
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