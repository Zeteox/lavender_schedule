import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/providers/alarm_settings_provider.dart';
import 'package:lavender_schedule/providers/class_provider.dart';
import 'package:lavender_schedule/utils/alarm_utils.dart';
import 'package:lavender_schedule/utils/scrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/alarm_settings.dart';
import '../model/school_class.dart';

Future<void> showSearchDialog(BuildContext context, List<SchoolClass> allClasses, bool isSubmission, Function(Object) onResult) async {
  String searchQuery = '';

  final result = await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Widget listContent;

          if (isSubmission) {
            final uniqueModules = allClasses
                .map((c) => c.subject)
                .toSet()
                .where((m) => m.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            listContent = ListView.builder(
              shrinkWrap: true,
              itemCount: uniqueModules.length,
              itemBuilder: (context, index) {
                final module = uniqueModules[index];
                return ListTile(
                  title: Text(module, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.pop(context, module),
                );
              },
            );
          } else {
            final filteredClasses = allClasses
                .where((c) => c.subject.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList()
              ..sort((a, b) => a.start.compareTo(b.start));

            listContent = ListView.builder(
              shrinkWrap: true,
              itemCount: filteredClasses.length,
              itemBuilder: (context, index) {
                final c = filteredClasses[index];
                final startLocal = c.start.toLocal();
                final heureFr = "${startLocal.hour.toString().padLeft(2, '0')}h${startLocal.minute.toString().padLeft(2, '0')}";
                final dateFr = "Le ${startLocal.day.toString().padLeft(2, '0')}/${startLocal.month.toString().padLeft(2, '0')} à $heureFr";

                return ListTile(
                  title: Text(c.subject, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                  subtitle: Text(dateFr, style: const TextStyle(color: Color(0xFFE7CCF5))),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            );
          }

          return Dialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSubmission ? "Rechercher une matière" : "Rechercher un cours",
                    style: const TextStyle(color: Color(0xFFE7CCF5), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Color(0xFFFFEFDC)),
                    decoration: InputDecoration(
                      hintText: "Titre du cours...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFE7CCF5)),
                      filled: true,
                      fillColor: const Color(0xFF282828),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Flexible(child: listContent),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler", style: TextStyle(color: Color(0xFF9155AB), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result != null) onResult(result);
}

void showUrlDialog(BuildContext context, TextEditingController urlController, WidgetRef ref, {bool canDismiss = false}) {
  urlController.text = Scrapper.getInstance().getApiUrl();

  showDialog(
    context: context,
    barrierDismissible: canDismiss,
    builder: (context) {
      bool isSaving = false;
      String? errorText;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5)),
            title: const Row(
              children: [
                Icon(Icons.calendar_month, color: Color(0xFFE7CCF5), size: 22),
                SizedBox(width: 10),
                Text("Configurer le planning", style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Colle l'URL de ton fichier .ics pour synchroniser tes cours.", style: TextStyle(color: Color(0xFFFFEFDC), fontSize: 14)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlController,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    style: const TextStyle(color: Color(0xFFFFEFDC)),
                    decoration: InputDecoration(
                      hintText: "https://ade.example.com/export.ics",
                      hintStyle: const TextStyle(color: Color(0xFF888888)),
                      errorText: errorText,
                      filled: true,
                      fillColor: const Color(0xFF282828),
                      prefixIcon: const Icon(Icons.link, color: Color(0xFF9155AB), size: 20),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF9155AB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE7CCF5), width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (canDismiss)
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler", style: TextStyle(color: Color(0xFF888888)))),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9155AB), foregroundColor: const Color(0xFFFFEFDC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: isSaving ? null : () async {
                  final url = urlController.text.trim();
                  if (url.isEmpty || !url.startsWith('http')) {
                    setDialogState(() => errorText = "Entre une URL valide (http/https)");
                    return;
                  }
                  setDialogState(() { isSaving = true; errorText = null; });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('ics_url', url);

                  Scrapper.getInstance().setApiUrl(url);
                  ref.read(classesProvider.notifier).refresh();

                  if (context.mounted) Navigator.of(context).pop();
                },
                child: isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFEFDC))) : const Text("Enregistrer"),
              ),
            ],
          );
        },
      );
    },
  );
}

void showAlarmDialog(BuildContext context, TextEditingController urlController, WidgetRef ref, {bool canDismiss = false}) {
  ref.read(alarmSettingsProvider.future).then((currentSettings) {
    bool alarmActivated = currentSettings.isActivated;
    int selectedMinutesBefore = currentSettings.minutesBefore;

    showDialog(
      context: context,
      barrierDismissible: canDismiss,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5),
              ),
              title: const Row(
                children: [
                  Icon(Icons.alarm, color: Color(0xFFE7CCF5), size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Configurer les alarmes",
                    style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Alarmes activées",
                          style: TextStyle(color: Color(0xFFFFEFDC), fontSize: 14),
                        ),
                        Switch(
                          value: alarmActivated,
                          onChanged: (value) => setDialogState(() => alarmActivated = value),
                        ),
                      ],
                    ),

                    const Divider(color: Color(0xFF3A3A3A)),
                    const SizedBox(height: 8),

                    AnimatedOpacity(
                      opacity: alarmActivated ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Alarme avant le cours :",
                            style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [15, 30, 60, 120, 180, 240, 300].map((minutes) {
                              final isSelected = selectedMinutesBefore == minutes;
                              return GestureDetector(
                                onTap: alarmActivated
                                    ? () => setDialogState(() => selectedMinutesBefore = minutes)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF9155AB) : const Color(0xFF282828),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFFE7CCF5) : const Color(0xFF3A3A3A),
                                    ),
                                  ),
                                  child: Text(
                                    minutes < 60 ? "${minutes}min" : "${minutes ~/ 60}h",
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFFEFDC) : const Color(0xFF888888),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF282828),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF3A3A3A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Color(0xFFE7CCF5), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Alarme ${selectedMinutesBefore < 60 ? '$selectedMinutesBefore minutes' : '${selectedMinutesBefore ~/ 60}h'} avant chaque cours",
                                    style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Annuler", style: TextStyle(color: Color(0xFF888888))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9155AB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final newSettings = AlarmAppSettings(
                      isActivated: alarmActivated,
                      minutesBefore: selectedMinutesBefore,
                    );

                    await ref.read(alarmSettingsProvider.notifier).save(newSettings);
                    await scheduleAlarms(newSettings);

                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text("Enregistrer", style: TextStyle(color: Color(0xFFFFEFDC))),
                ),
              ],
            );
          },
        );
      },
    );
  });
}