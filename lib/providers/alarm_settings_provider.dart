import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmSettings {
  final bool isActivated;
  final int minutesBefore;

  const AlarmSettings({
    this.isActivated = false,
    this.minutesBefore = 30,
  });

  AlarmSettings copyWith({bool? isActivated, int? minutesBefore}) {
    return AlarmSettings(
      isActivated: isActivated ?? this.isActivated,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }
}

class AlarmSettingsNotifier extends AsyncNotifier<AlarmSettings> {
  static const _keyActivated = 'alarm_activated';
  static const _keyMinutes = 'alarm_minutes_before_class';

  @override
  Future<AlarmSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isActivated = prefs.getBool(_keyActivated) ?? false;
    final minutesBefore = prefs.getInt(_keyMinutes) ?? 30;
    // Debug - vérifie ce qui est lu au démarrage
    print("📖 LOADED: activated=$isActivated, minutes=$minutesBefore");
    return AlarmSettings(isActivated: isActivated, minutesBefore: minutesBefore);
  }

  Future<void> save(AlarmSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyActivated, settings.isActivated);
  await prefs.setInt(_keyMinutes, settings.minutesBefore);
  state = AsyncData(settings);
  // Debug - vérifie que ça s'écrit bien
  print("✅ SAVED: activated=${settings.isActivated}, minutes=${settings.minutesBefore}");
  // Relis immédiatement pour confirmer
  print("✅ READ BACK: activated=${prefs.getBool(_keyActivated)}, minutes=${prefs.getInt(_keyMinutes)}");
}
}

final alarmSettingsProvider =
    AsyncNotifierProvider<AlarmSettingsNotifier, AlarmSettings>(
  AlarmSettingsNotifier.new,
);