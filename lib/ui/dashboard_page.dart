import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/utils/dialog_utils.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../providers/class_provider.dart';
import '../model/school_class.dart';
import '../utils/scrapper.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Scrapper.getInstance().getApiUrl().isEmpty) {
        showUrlDialog(context, _urlController, ref);
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE7CCF5), width: 2)),
        title: Text(task.title, style: const TextStyle(color: Color(0xFFE7CCF5), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.course != null) Text("Matière : ${task.course}", style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text("Description :", style: TextStyle(color: const Color(0xFFFFEFDC).withValues(alpha: 0.7))),
            const SizedBox(height: 4),
            Text(task.description.isEmpty ? "Aucune description fournie." : task.description, style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer", style: TextStyle(color: Color(0xFF9155AB), fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final coursState = ref.watch(coursProvider);

    final rendusList = allTasks.where((task) => task.type == "Rendu" && task.dueDate != null).toList();
    rendusList.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final top5Rendus = rendusList.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), tooltip: "Changer l'URL .ics", onPressed: () => showUrlDialog(context, _urlController, ref, canDismiss: true)),
        ],
      ),
      body: Scrapper.getInstance().getApiUrl().isEmpty
          ? const Center(child: Text("Veuillez configurer l'URL.", style: TextStyle(color: Color(0xFFFFEFDC))))
          : coursState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => Center(child: Text("Erreur : $e", style: const TextStyle(color: Color(0xFFFFEFDC)))),
        data: (allCours) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(taskProvider.notifier).cleanOldTasks(allCours);
          });

          final now = DateTime.now();
          final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

          double totalHours = 0;
          double doneHours = 0;
          for (var c in allCours.where((c) => c.start.toLocal().isAfter(weekStart) && c.end.toLocal().isBefore(weekEnd))) {
            final duration = c.end.difference(c.start).inMinutes / 60.0;
            totalHours += duration;
            if (c.end.toLocal().isBefore(now)) doneHours += duration;
          }

          List<SchoolClass> upcoming = allCours.where((c) => c.end.toLocal().isAfter(now)).toList()..sort((a, b) => a.start.compareTo(b.start));
          SchoolClass? nextClass = upcoming.isNotEmpty ? upcoming.first : null;

          String dayLabel = "Prochain cours";
          if (nextClass != null) {
            final nextStartLocal = nextClass.start.toLocal();
            if (nextStartLocal.day == now.day && nextStartLocal.month == now.month) {
              dayLabel = "Aujourd'hui";
            } else {
              dayLabel = "Prochain cours (${nextStartLocal.day.toString().padLeft(2,'0')}/${nextStartLocal.month.toString().padLeft(2,'0')})";
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7CCF5))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Progression Semaine", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5), fontSize: 16)),
                      Text("${doneHours.toStringAsFixed(1)}h / ${totalHours.toStringAsFixed(1)}h", style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(dayLabel, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                const SizedBox(height: 12),
                if (nextClass == null)
                  const Text("Aucun cours à venir.", style: TextStyle(color: Color(0xFFFFEFDC), fontStyle: FontStyle.italic))
                else
                  GestureDetector(
                    onTap: () => context.push('/details', extra: nextClass),
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF9155AB), borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.timer, color: Color(0xFFFFEFDC), size: 30),
                        title: Text(nextClass.subject, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC), fontSize: 18)),
                        subtitle: Text("${nextClass.start.toLocal().hour.toString().padLeft(2,'0')}h${nextClass.start.toLocal().minute.toString().padLeft(2,'0')} - ${nextClass.end.toLocal().hour.toString().padLeft(2,'0')}h${nextClass.end.toLocal().minute.toString().padLeft(2,'0')} | ${nextClass.rooms.join(', ')}", style: const TextStyle(color: Color(0xFFFFEFDC))),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Rendus urgents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                    Text("${rendusList.length} à faire", style: const TextStyle(color: Color(0xFFFFEFDC))),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: top5Rendus.isEmpty
                      ? const Center(child: Text("Aucun rendu en attente ! 🎉", style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 16)))
                      : ListView.builder(
                    itemCount: top5Rendus.length,
                    itemBuilder: (context, index) {
                      final rendu = top5Rendus[index];
                      final dateString = "${rendu.dueDate!.day.toString().padLeft(2,'0')}/${rendu.dueDate!.month.toString().padLeft(2,'0')} à ${rendu.dueDate!.hour.toString().padLeft(2,'0')}h${rendu.dueDate!.minute.toString().padLeft(2,'0')}";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7CCF5), width: 1.5)),
                        child: ListTile(
                          onTap: () => _showTaskDetails(context, rendu),
                          leading: const Icon(Icons.assignment_late, color: Color(0xFFE7CCF5)),
                          title: Text(rendu.title, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                          subtitle: Text(rendu.course ?? "Aucun cours", style: const TextStyle(color: Color(0xFFFFEFDC))),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Pour le", style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 12)),
                              Text(dateString, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}