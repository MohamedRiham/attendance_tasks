import 'package:attendance_tasks/common/widgets/custom_dropdown.dart';
import 'package:attendance_tasks/attendance/screens/attendance_screen.dart';
import 'package:attendance_tasks/common/services/date_picker_service.dart';
import 'package:attendance_tasks/common/widgets/custom_scaffold.dart';
import 'package:attendance_tasks/common/widgets/custom_text_field.dart';
import 'package:attendance_tasks/task/models/task.dart';
import 'package:attendance_tasks/task/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  String _priority = 'Low';
  String _status = 'Not Started';
  late TaskProvider taskProvider;
  DateTime? _dueDate;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
      await taskProvider.loadTasks();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'An error occurred while saving details',
              ),
            ),
          );
        }
      }
      });

    }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    taskProvider = Provider.of<TaskProvider>(context);
    return CustomScaffold(
      title: 'Daily Tasks',
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _taskNameController,
                              hintText: 'Task Name',
                              icon: Icons.task,
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.fillColor ??
                                    (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200]),

                                border: Border.all(
                                  color:
                                      Theme.of(context)
                                          .inputDecorationTheme
                                          .border
                                          ?.borderSide
                                          .color ??
                                      (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white24
                                          : Colors.black12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _dueDate == null
                                        ? 'Pick Due Date'
                                        : 'Due: ${DateFormat('MM/dd/yyyy').format(_dueDate!)}',
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await selectDate((selectedDate) {
                                        _dueDate = selectedDate;
                                        setState(() {});
                                      });
                                    },
                                    child: const Text('Select Date'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Priority',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),

                                CustomDropdown(
                                  value: _priority,
                                  onChanged: (value) =>
                                      setState(() => _priority = value!),

                                  items: ['Low', 'Medium', 'High'],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Status',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),

                                CustomDropdown(
                                  value: _status,

                                  onChanged: (value) =>
                                      setState(() => _status = value!),

                                  items: ['Not Started', 'In Progress', 'Done'],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    _dueDate != null) {
                                  _formKey.currentState!.save();
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    Task task = Task(
                                      id: '',
                                      name: _taskNameController.text,
                                      dueDate: _dueDate!,
                                      priority: _priority,
                                      status: _status,
                                    );
                                    await taskProvider.addTask(task);
                                    _taskNameController.clear();
                                    _dueDate = null;
                                    _priority = 'Low';
                                    _status = 'Not Started';
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'An error occurred while saving details',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  setState(() {
                                    _isLoading = false;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select due date'),
                                    ),
                                  );
                                }
                              },
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: taskProvider.tasks.isEmpty
                            ? const Center(child: Text('No tasks added yet.'))
                            : ListView.builder(
                                itemCount: taskProvider.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskProvider.tasks[index];
                                  return TaskCard(
                                    task: task,
                                    updateStatus: (newStatus) async {
                                      if (newStatus != null) {
                                        try {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          task.status = newStatus;
                                          await taskProvider.updateTask(task);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'An error occurred while updating details',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigation: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AttendanceScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String?) updateStatus;
  const TaskCard({super.key, required this.task, required this.updateStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                task.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Due: ${DateFormat.yMMMd().format(task.dueDate)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('priority'),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.priority,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text('Status'),
            const SizedBox(height: 10),

            CustomDropdown(
              value: task.status,
              onChanged: (value) => updateStatus(value),
              items: ['Not Started', 'In Progress', 'Done'],
            ),
          ],
        ),
      ),
    );
  }

  static Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
