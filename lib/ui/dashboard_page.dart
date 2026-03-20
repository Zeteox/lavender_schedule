import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(taskProvider);
    final rendusList = allTasks.where((task) => task.type == "Rendu" && task.dueDate != null).toList();
    rendusList.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Prochain cours", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE7CCF5))),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF9155AB), borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.timer, color: Color(0xFFFFEFDC), size: 30),
                title: Text("Développement Mobile", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFEFDC), fontSize: 18)),
                subtitle: Text("14:00 - Salle Labo B2", style: TextStyle(color: Color(0xFFFFEFDC))),
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
              child: rendusList.isEmpty
                  ? const Center(child: Text("Aucun rendu en attente ! 🎉", style: TextStyle(color: Color(0xFFE7CCF5), fontSize: 16)))
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
            )
          ],
        ),
      ),
    );
  }
}