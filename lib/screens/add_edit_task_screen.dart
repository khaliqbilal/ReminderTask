import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late RepeatType _repeatType;
  late List<SubTask> _subtasks;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _dueTime = TimeOfDay.fromDateTime(widget.task!.dueDate);
      _repeatType = widget.task!.repeatType;
      _subtasks = List.from(widget.task!.subtasks);
    } else {
      _title = '';
      _description = '';
      _dueDate = DateTime.now();
      _dueTime = TimeOfDay.now();
      _repeatType = RepeatType.none;
      _subtasks = [];
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final scheduledDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      final newTask = Task(
        id: widget.task?.id,
        title: _title,
        description: _description,
        dueDate: scheduledDateTime,
        isCompleted: widget.task?.isCompleted ?? false,
        repeatType: _repeatType,
        subtasks: _subtasks,
      );

      final provider = Provider.of<TaskProvider>(context, listen: false);
      if (widget.task == null) {
        await provider.addTask(newTask);
      } else {
        await provider.updateTask(newTask);
      }

      // Re-schedule notification
      if (!kIsWeb) {
        if (widget.task != null && widget.task!.id != null) {
          await NotificationService().cancelNotification(widget.task!.id!);
        }

        if (scheduledDateTime.isAfter(DateTime.now()) && !newTask.isCompleted) {
          final idToSchedule = newTask.id ?? DateTime.now().millisecond;
          await NotificationService().scheduleNotification(
            idToSchedule,
            'Task Reminder: $_title',
            _description.isNotEmpty ? _description : 'It is time for your task!',
            scheduledDateTime,
          );
        }
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask,
            tooltip: 'Save Task',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _title,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
                onSaved: (val) => _title = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 24),
              Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      title: const Text("Date"),
                      subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_dueDate), style: Theme.of(context).textTheme.bodyMedium),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    ListTile(
                      leading: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                      title: const Text("Time"),
                      subtitle: Text(_dueTime.format(context), style: Theme.of(context).textTheme.bodyMedium),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _dueTime,
                        );
                        if (picked != null) setState(() => _dueTime = picked);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<RepeatType>(
                value: _repeatType,
                decoration: const InputDecoration(
                  labelText: 'Repeat Interval',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: RepeatType.values.map((type) {
                  return DropdownMenuItem(
                    value: type, 
                    child: Text(type.name[0].toUpperCase() + type.name.substring(1))
                  );
                }).toList(),
                onChanged: (val) => setState(() => _repeatType = val ?? RepeatType.none),
              ),
              
              const SizedBox(height: 32),
              Text('Subtasks', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              
              ..._subtasks.asMap().entries.map((entry) {
                int idx = entry.key;
                SubTask sub = entry.value;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: sub.isCompleted,
                      onChanged: (val) => setState(() => sub.isCompleted = val ?? false),
                    ),
                    title: Text(
                      sub.title,
                      style: TextStyle(
                        decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                        color: sub.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      onPressed: () => setState(() => _subtasks.removeAt(idx)),
                    ),
                  ),
                );
              }).toList(),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: 'Add a new subtask...',
                      ),
                      onSubmitted: (_) {
                        if (_subtaskController.text.isNotEmpty) {
                          setState(() {
                            _subtasks.add(SubTask(
                              taskId: widget.task?.id ?? 0,
                              title: _subtaskController.text,
                            ));
                            _subtaskController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        if (_subtaskController.text.isNotEmpty) {
                          setState(() {
                            _subtasks.add(SubTask(
                              taskId: widget.task?.id ?? 0,
                              title: _subtaskController.text,
                            ));
                            _subtaskController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTask,
        label: const Text('Save Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.save, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
