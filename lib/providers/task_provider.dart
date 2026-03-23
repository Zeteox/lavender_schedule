import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/school_class.dart';

class TaskNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    _loadTasks();
    return [];
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('saved_tasks');
    if (tasksJson != null) {
      final List decoded = jsonDecode(tasksJson);
      state = decoded.map((e) => Task.fromJson(e)).toList();
    }
  }

  Future<void> addTask(Task newTask) async {
    state = [...state, newTask];
    _saveTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    prefs.setString('saved_tasks', encoded);
  }

  Future<void> cleanOldTasks(List<SchoolClass> allClasses) async {
    final now = DateTime.now();
    bool hasChanges = false;

    // Remove items tied to classes/modules that have been inactive for more than 10 days.
    final updatedState = state.where((task) {
      if (task.type == "Rendu" && task.course != null) {
        final moduleClasses = allClasses.where((c) => c.subject == task.course);
        if (moduleClasses.isNotEmpty) {
          final latestClass = moduleClasses.reduce((a, b) => a.end.isAfter(b.end) ? a : b);
          if (now.difference(latestClass.end).inDays > 10) {
            hasChanges = true;
            return false;
          }
        }
      }
      else if (task.type == "Note" && task.specificClassId != null) {
        final parts = task.specificClassId!.split('_');
        if (parts.length == 2) {
          final timestamp = int.tryParse(parts[1]);
          if (timestamp != null) {
            final classDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(classDate).inDays > 10) {
              hasChanges = true;
              return false;
            }
          }
        }
      }
      return true;
    }).toList();

    if (hasChanges) {
      state = updatedState;
      _saveTasks();
    }
  }
}

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(() => TaskNotifier());