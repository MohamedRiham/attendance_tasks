import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task {
  String name;
  DateTime dueDate;
  String priority;
  String status;

  Task({
    required this.name,
    required this.dueDate,
    required this.priority,
    required this.status,
  });
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> tasks = [];

  final _formKey = GlobalKey<FormState>();
  String? _taskName;
  DateTime? _dueDate;
  String _priority = 'Low';
  String _status = 'Not Started';

  void _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTask() {
    if (_formKey.currentState!.validate() && _dueDate != null) {
      _formKey.currentState!.save();
      setState(() {
        tasks.add(Task(
          name: _taskName!,
          dueDate: _dueDate!,
          priority: _priority,
          status: _status,
        ));
        _taskName = null;
        _dueDate = null;
        _priority = 'Low';
        _status = 'Not Started';
      });
      _formKey.currentState!.reset();
    }
  }

  void _updateTaskStatus(int index, String newStatus) {
    setState(() {
      tasks[index].status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Task Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter task name' : null,
                    onSaved: (value) => _taskName = value,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        _dueDate == null
                            ? 'Pick Due Date'
                            : 'Due: ${DateFormat('MM/dd/yyyy').format(_dueDate!)}',
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _pickDueDate,
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    items: ['Low', 'Medium', 'High']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _priority = value!),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: ['Not Started', 'In Progress', 'Done']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _addTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Tasks List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('No tasks added yet.'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          child: ListTile(
                            title: Text(task.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due: ${DateFormat('MM/dd/yyyy').format(task.dueDate)}'),
                                Text('Priority: ${task.priority}'),
                              ],
                            ),
                            trailing: DropdownButton<String>(
                              value: task.status,
                              onChanged: (value) =>
                                  _updateTaskStatus(index, value!),
                              items: ['Not Started', 'In Progress', 'Done']
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
