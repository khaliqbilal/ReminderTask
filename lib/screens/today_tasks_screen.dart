import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TodayTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.todayTasks;
        if (tasks.isEmpty) {
          return Center(child: Text('No tasks for today.'));
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => TaskTile(task: tasks[index]),
        );
      },
    );
  }
}
