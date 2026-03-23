import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/alarm_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmSettingsNotifier extends AsyncNotifier<AlarmAppSettings> {
  static const _keyActivated = 'alarm_activated';
  static const _keyMinutes = 'alarm_minutes_before_class';

  @override
  Future<AlarmAppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isActivated = prefs.getBool(_keyActivated) ?? false;
    final minutesBefore = prefs.getInt(_keyMinutes) ?? 30;
    return AlarmAppSettings(isActivated: isActivated, minutesBefore: minutesBefore);
  }

  Future<void> save(AlarmAppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActivated, settings.isActivated);
    await prefs.setInt(_keyMinutes, settings.minutesBefore);
    state = AsyncData(settings);
  }
}

final alarmSettingsProvider =
    AsyncNotifierProvider<AlarmSettingsNotifier, AlarmAppSettings>(
  AlarmSettingsNotifier.new,
);