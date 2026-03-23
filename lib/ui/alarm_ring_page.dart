import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:lavender_schedule/router/main.dart';

class AlarmRingPage extends StatelessWidget {
  final AlarmSet alarmSet;

  const AlarmRingPage({super.key, required this.alarmSet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282828),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm, color: Color(0xFFE7CCF5), size: 80),
              const SizedBox(height: 24),
              const Text(
                "Cours bientôt !",
                style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9155AB),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.alarm_off, color: Color(0xFFFFEFDC)),
                label: const Text("Arrêter", style: TextStyle(color: Color(0xFFFFEFDC), fontSize: 18)),
                onPressed: () async {
                  await Alarm.stop(alarmSet.alarms.first.id);
                  if (context.mounted) router.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}