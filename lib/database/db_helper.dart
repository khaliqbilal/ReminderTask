import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    
    String path = join(kIsWeb ? '' : await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        repeatType INTEGER NOT NULL,
        repeatDays TEXT,
        notificationSound TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertTask(Task task) async {
    Database db = await database;
    int taskId = await db.insert('tasks', task.toMap());
    for (var subtask in task.subtasks) {
      subtask.taskId = taskId;
      await db.insert('subtasks', subtask.toMap());
    }
    return taskId;
  }

  Future<List<Task>> getTasks() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    List<Task> tasks = [];
    for (var map in maps) {
      Task task = Task.fromMap(map);
      final List<Map<String, dynamic>> subMaps = await db.query(
        'subtasks',
        where: 'taskId = ?',
        whereArgs: [task.id],
      );
      task.subtasks = subMaps.map((s) => SubTask.fromMap(s)).toList();
      tasks.add(task);
    }
    return tasks;
  }

  Future<int> updateTask(Task task) async {
    Database db = await database;
    await db.delete('subtasks', where: 'taskId = ?', whereArgs: [task.id]);
    for (var subtask in task.subtasks) {
      subtask.taskId = task.id!;
      await db.insert('subtasks', subtask.toMap());
    }
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    await db.delete('subtasks', where: 'taskId = ?', whereArgs: [id]);
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
