import 'package:alarm/alarm.dart';
import 'package:lavender_schedule/model/school_class.dart';
import 'package:lavender_schedule/providers/alarm_settings_provider.dart';
import 'package:lavender_schedule/utils/scrapper.dart';

Future<void> scheduleAlarms(AlarmAppSettings settings) async {
  await Alarm.stopAll();

  if (!settings.isActivated) return;

  List<SchoolClass> classes;
  try {
    classes = await Scrapper.getInstance().getClasses();
  } catch (e) {
    print("Erreur scrapper: $e");
    return;
  }

  final now = DateTime.now();

  final upcoming = classes.where((c) {
    final alarmTime = c.start.toLocal().subtract(Duration(minutes: settings.minutesBefore));
    return alarmTime.isAfter(now);
  }).toList();

  for (int i = 0; i < upcoming.length; i++) {
    final cours = upcoming[i];
    final alarmTime = cours.start.toLocal().subtract(Duration(minutes: settings.minutesBefore));

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: i + 1,
        dateTime: alarmTime,
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 5),
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: cours.subject,
          body: "Dans ${settings.minutesBefore} min • ${cours.rooms.join(', ')}",
          stopButton: "Arrêter",
          icon: 'notification_icon',
        ),
      ),
    );

    print("Alarme programmée: ${cours.subject} à $alarmTime");
  }

  print("${upcoming.length} alarmes programmées");
}