import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class CompletedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.completedTasks;
        if (tasks.isEmpty) {
          return Center(child: Text('No completed tasks.'));
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => TaskTile(task: tasks[index]),
        );
      },
    );
  }
}
