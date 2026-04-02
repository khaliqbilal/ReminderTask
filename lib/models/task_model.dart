import 'dart:convert';

enum RepeatType { none, daily, weekly }

class SubTask {
  int? id;
  int taskId;
  String title;
  bool isCompleted;

  SubTask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

class Task {
  int? id;
  String title;
  String description;
  DateTime dueDate;
  bool isCompleted;
  RepeatType repeatType;
  List<int>? repeatDays; // 1 for Monday, 7 for Sunday
  String? notificationSound;
  List<SubTask> subtasks;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.isCompleted = false,
    this.repeatType = RepeatType.none,
    this.repeatDays,
    this.notificationSound,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'repeatType': repeatType.index,
      'repeatDays': repeatDays != null ? jsonEncode(repeatDays) : null,
      'notificationSound': notificationSound,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] == 1,
      repeatType: RepeatType.values[map['repeatType'] ?? 0],
      repeatDays: map['repeatDays'] != null
          ? List<int>.from(jsonDecode(map['repeatDays']))
          : null,
      notificationSound: map['notificationSound'],
    );
  }

  double get progress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    int completedCount = subtasks.where((s) => s.isCompleted).length;
    return completedCount / subtasks.length;
  }
}
