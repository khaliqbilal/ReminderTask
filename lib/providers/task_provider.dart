import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark as per UI
  String _activeWorkspace = 'Personal';

  List<Task> get tasks => _tasks;
  ThemeMode get themeMode => _themeMode;
  String get activeWorkspace => _activeWorkspace;

  List<Task> get todayTasks => _tasks.where((task) {
    final now = DateTime.now();
    return !task.isCompleted &&
        task.dueDate.year == now.year &&
        task.dueDate.month == now.month &&
        task.dueDate.day == now.day;
  }).toList();

  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  List<Task> get repeatedTasks => _tasks.where((task) => task.repeatType != RepeatType.none).toList();

  void setWorkspace(String workspace) {
    _activeWorkspace = workspace;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _tasks = await DBHelper().getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DBHelper().insertTask(task);
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await DBHelper().updateTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await DBHelper().deleteTask(id);
    await fetchTasks();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
