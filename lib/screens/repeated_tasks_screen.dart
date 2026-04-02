import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class RepeatedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.repeatedTasks;
        if (tasks.isEmpty) {
          return Center(child: Text('No repeated tasks.'));
        }
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => TaskTile(task: tasks[index]),
        );
      },
    );
  }
}
