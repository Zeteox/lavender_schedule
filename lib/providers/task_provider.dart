import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  final String id;
  final String type;
  final String title;
  final String description;
  final String? course;
  final DateTime? dueDate;

  Task({
    required this.id, required this.type, required this.title,
    required this.description, this.course, this.dueDate,
  });
}

class TaskNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return [
      Task(
        id: "1", type: "Rendu", title: "Projet Fin de Module",
        description: "Application Flutter avec Riverpod",
        course: "Développement Mobile", dueDate: DateTime.now().add(const Duration(days: 2)),
      )
    ];
  }

  void addTask(Task newTask) {
    state = [...state, newTask];
  }
}

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(() => TaskNotifier());