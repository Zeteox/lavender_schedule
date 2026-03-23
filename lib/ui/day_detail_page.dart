import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/school_class.dart';
import 'package:lavender_schedule/model/task.dart';
import '../providers/task_provider.dart';
import '../providers/class_provider.dart';
import '../utils/task_utils.dart';

class DayDetailPage extends ConsumerWidget {
  final SchoolClass? schoolClass;
  const DayDetailPage({super.key, this.schoolClass});

  // Keep this ID format aligned with task.specificClassId generation.
  String _classId(SchoolClass c) => '${c.subject}_${c.start.millisecondsSinceEpoch}';

  Widget _buildClassSection(BuildContext context, SchoolClass c, List<Task> allTasks) {
    final subjectSubmissions = allTasks.where((t) => t.type == "Rendu" && t.course == c.subject).toList();
    final classNotes = allTasks.where((t) => t.type == "Note" && t.specificClassId == _classId(c)).toList();
    final startLocal = c.start.toLocal(), endLocal = c.end.toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'class_${c.subject}_${c.start.millisecondsSinceEpoch}',
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7CCF5), width: 2)),
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text("${startLocal.hour.toString().padLeft(2,'0')}h${startLocal.minute.toString().padLeft(2,'0')} - ${endLocal.hour.toString().padLeft(2,'0')}h${endLocal.minute.toString().padLeft(2,'0')}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
                        ),
                        const SizedBox(width: 8),
                        Text(c.type, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF9155AB), fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(c.subject, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC))),
                    if (c.teachers.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Row(children: [const Icon(Icons.person, size: 20, color: Color(0xFFE7CCF5)), const SizedBox(width: 8), Expanded(child: Text(c.teachers.join(', '), style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 16)))])),
                    if (c.rooms.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Row(children: [const Icon(Icons.room, size: 20, color: Color(0xFFE7CCF5)), const SizedBox(width: 8), Expanded(child: Text(c.rooms.join(', '), style: const TextStyle(color: Color(0xFFFFEFDC), fontSize: 16)))])),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        const Text("Rendus de cette matière", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
        const SizedBox(height: 12),
        if (subjectSubmissions.isEmpty) const Text("Aucun rendus pour le moment", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else ...subjectSubmissions.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7CCF5), width: 1.5)),
          child: ListTile(
            onTap: () => showTaskDetails(context, r),
            leading: const Icon(Icons.assignment, color: Color(0xFFE7CCF5)),
            title: Text(r.title, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Pour le", style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 12)), Text("${r.dueDate?.day.toString().padLeft(2,'0')}/${r.dueDate?.month.toString().padLeft(2,'0')} à ${r.dueDate?.hour.toString().padLeft(2,'0')}h${r.dueDate?.minute.toString().padLeft(2,'0')}", style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold))]),
          ),
        )),

        const SizedBox(height: 24),

        const Text("Informations du cours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
        const SizedBox(height: 12),
        if (classNotes.isEmpty) const Text("Aucune informations pour le moment", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else ...classNotes.map((n) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: const Color(0xFF9155AB), borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => showTaskDetails(context, n),
            leading: const Icon(Icons.edit_note, color: Color(0xFFFFEFDC)),
            title: Text(n.title, style: const TextStyle(color: Color(0xFFFFEFDC), fontWeight: FontWeight.bold)),
            subtitle: Text(n.description, style: const TextStyle(color: Color(0xFFFFEFDC))),
          ),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(taskProvider);
    final classesState = ref.watch(classesProvider);

    if (schoolClass != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Détails & Notes")),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildClassSection(context, schoolClass!, allTasks),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Aujourd'hui")),
      body: classesState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE7CCF5))),
        error: (e, _) => const Center(child: Text("Impossible de charger les cours.")),
        data: (allClasses) {
          final now = DateTime.now();
          final classesToday = allClasses.where((c) {
            final startLocal = c.start.toLocal();
            return startLocal.year == now.year && startLocal.month == now.month && startLocal.day == now.day;
          }).toList()..sort((a, b) => a.start.compareTo(b.start));

          if (classesToday.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.weekend_outlined, size: 64, color: Color(0xFF9155AB)), SizedBox(height: 16), Text("Aucun cours aujourd'hui !", style: TextStyle(color: Color(0xFFFFEFDC), fontSize: 20, fontWeight: FontWeight.bold))]));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: classesToday.map((c) => _buildClassSection(context, c, allTasks)).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}