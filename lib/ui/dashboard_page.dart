import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/utils/dialog_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender_schedule/utils/task_utils.dart';
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
      if (Scrapper.getInstance().getApiUrl().isEmpty) showUrlDialog(context, _urlController, ref);
    });
  }

  @override
  void dispose() { _urlController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final classesState = ref.watch(classesProvider);

    final top5Submissions = (allTasks.where((t) => t.type == "Rendu" && t.dueDate != null).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!))).take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), tooltip: "Changer l'URL", onPressed: () => showUrlDialog(context, _urlController, ref, canDismiss: true)),
          IconButton(icon: const Icon(Icons.alarm), tooltip: "Alarmes", onPressed: () => showAlarmDialog(context, _urlController, ref, canDismiss: true)),
        ],
      ),
      body: Scrapper.getInstance().getApiUrl().isEmpty
          ? const Center(child: Text("Veuillez configurer l'URL.", style: TextStyle(color: Color(0xFFFFEFDC))))
          : classesState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => Center(child: Text("Erreur : $e", style: const TextStyle(color: Color(0xFFFFEFDC)))),
        data: (allClasses) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(taskProvider.notifier).cleanOldTasks(allClasses));

          final now = DateTime.now();
          final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

          double totalHours = 0, doneHours = 0;
          for (var schoolClass in allClasses.where((c) => c.start.toLocal().isAfter(weekStart) && c.end.toLocal().isBefore(weekEnd))) {
            final duration = schoolClass.end.difference(schoolClass.start).inMinutes / 60.0;
            totalHours += duration;
            if (schoolClass.end.toLocal().isBefore(now)) doneHours += duration;
          }

          SchoolClass? nextClass = allClasses.where((c) => c.end.toLocal().isAfter(now)).toList()
              .fold<SchoolClass?>(null, (prev, elem) => prev == null ? elem : (elem.start.isBefore(prev.start) ? elem : prev));

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;

              Widget leftCol = Column(
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
                  const Text("Prochain cours", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                  const SizedBox(height: 12),
                  if (nextClass == null) const Text("Aucun cours à venir.", style: TextStyle(color: Color(0xFFFFEFDC), fontStyle: FontStyle.italic))
                  else GestureDetector(
                    onTap: () => context.push('/details', extra: nextClass),
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF9155AB), borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.timer, color: Color(0xFFFFEFDC), size: 30),
                        title: Text(nextClass.subject, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC))),
                        subtitle: Text("${nextClass.start.toLocal().hour}h${nextClass.start.toLocal().minute.toString().padLeft(2,'0')} - ${nextClass.end.toLocal().hour}h${nextClass.end.toLocal().minute.toString().padLeft(2,'0')} | ${nextClass.rooms.join(', ')}", style: const TextStyle(color: Color(0xFFFFEFDC))),
                      ),
                    ),
                  ),
                ],
              );

              Widget rightCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rendus urgents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                  const SizedBox(height: 12),
                  if (top5Submissions.isEmpty) const Text("Aucun rendu en attente !", style: TextStyle(color: Color(0xFFE7CCF5)))
                  else ...top5Submissions.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7CCF5), width: 1.5)),
                    child: ListTile(
                      onTap: () => showTaskDetails(context, r),
                      leading: const Icon(Icons.assignment_late, color: Color(0xFFE7CCF5)),
                      title: Text(r.title, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
                      subtitle: Text(r.course ?? "Aucun cours", style: const TextStyle(color: Color(0xFFFFEFDC))),
                    ),
                  )),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: isDesktop
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: leftCol), const SizedBox(width: 32), Expanded(child: rightCol)])
                    : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [leftCol, const SizedBox(height: 32), rightCol]),
              );
            },
          );
        },
      ),
    );
  }
}