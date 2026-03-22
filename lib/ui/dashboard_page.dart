import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/task_provider.dart';
import '../utils/scrapper.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const _icsUrlKey = 'ics_url';
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFirstLaunch());
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(_icsUrlKey);

    if (savedUrl == null || savedUrl.isEmpty) {
      if (mounted) _showUrlDialog();
    } else {
      Scrapper.getInstance().setApiUrl(savedUrl);
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showUrlDialog({bool canDismiss = false}) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE7CCF5), width: 1.5),
              ),
              title: const Row(
                children: [
                  Icon(Icons.calendar_month, color: Color(0xFFE7CCF5), size: 22),
                  SizedBox(width: 10),
                  Text(
                    "Configurer l'emploi du temps",
                    style: TextStyle(
                      color: Color(0xFFE7CCF5),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Colle l'URL de ton fichier .ics pour synchroniser tes cours.",
                    style: TextStyle(color: Color(0xFFFFEFDC), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF9155AB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF9155AB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE7CCF5), width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                if (canDismiss)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Annuler", style: TextStyle(color: Color(0xFF888888))),
                  ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF9155AB),
                    foregroundColor: const Color(0xFFFFEFDC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final url = _urlController.text.trim();
                          if (url.isEmpty || !url.startsWith('http')) {
                            setDialogState(() => errorText = "Entre une URL valide (http/https)");
                            return;
                          }
                          setDialogState(() {
                            isSaving = true;
                            errorText = null;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(_icsUrlKey, url);
                          Scrapper.getInstance().setApiUrl(url);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFEFDC)),
                        )
                      : const Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final rendusList = allTasks
        .where((task) => task.type == "Rendu" && task.dueDate != null)
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: "Calendrier",
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Changer l'URL .ics",
            onPressed: () => _showUrlDialog(canDismiss: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Prochain cours",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9155AB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.timer, color: Color(0xFFFFEFDC), size: 30),
                      title: Text(
                        "Développement Mobile",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC), fontSize: 18),
                      ),
                      subtitle: Text("14:00 - Salle Labo B2", style: TextStyle(color: Color(0xFFFFEFDC))),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Rendus urgents",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5)),
                      ),
                      Text("${rendusList.length} à faire", style: const TextStyle(color: Color(0xFFFFEFDC))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: rendusList.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucun rendu en attente ! 🎉",
                              style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: rendusList.length,
                            itemBuilder: (context, index) {
                              final rendu = rendusList[index];
                              final dateString = "${rendu.dueDate!.day}/${rendu.dueDate!.month}";
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282828),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE7CCF5), width: 1.5),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.assignment_late, color: Color(0xFFE7CCF5)),
                                  title: Text(
                                    rendu.title,
                                    style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    rendu.course ?? "Aucun cours",
                                    style: const TextStyle(color: Color(0xFFFFEFDC)),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Pour le", style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 12)),
                                      Text(
                                        dateString,
                                        style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}