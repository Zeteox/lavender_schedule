import 'package:flutter/material.dart';
import 'package:lavender_schedule/model/task.dart';

void showTaskDetails(BuildContext context, Task task) {
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