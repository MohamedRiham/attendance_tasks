import 'package:attendance_tasks/attendance/models/attendance.dart';
import 'package:attendance_tasks/attendance/provider/attendance_provider.dart';
import 'package:attendance_tasks/common/widgets/custom_scaffold.dart';
import 'package:attendance_tasks/common/widgets/custom_text_field.dart';
import 'package:attendance_tasks/task/screens/task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  final TextEditingController _userNameController = TextEditingController();
  late AttendanceProvider attendanceProvider;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await attendanceProvider.loadName();
        await attendanceProvider.loadAttendanceHistory();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred while loading details'),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    attendanceProvider = Provider.of<AttendanceProvider>(context);
    return CustomScaffold(
      title: 'Attendance',
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? CircularProgressIndicator()
                : attendanceProvider.myName == null
                ? Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Enter your name to begin:",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _userNameController,
                          hintText: 'User Name',
                          icon: Icons.person,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 10),

                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await attendanceProvider.saveUserName(
                                    _userNameController.text,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
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
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Hello, ${attendanceProvider.myName}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (attendanceProvider
                                  .todayAttendance
                                  ?.attendanceStatus !=
                              'On Leave' &&
                          (attendanceProvider.todayAttendance?.checkInTime ==
                                  null ||
                              attendanceProvider
                                      .todayAttendance
                                      ?.checkOutTime ==
                                  null)) ...[
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
                                (Theme.of(context).brightness == Brightness.dark
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (attendanceProvider
                                      .todayAttendance
                                      ?.checkInTime ==
                                  null) ...[
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      String message = await attendanceProvider
                                          .checkIn();

                                      if (context.mounted) {
                                        if (message == 'Already marked') {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Check-in has already been marked.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
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
                                  },
                                  child: const Text("In"),
                                ),
                                const SizedBox(width: 10),
                              ],
                              if (attendanceProvider
                                      .todayAttendance
                                      ?.checkOutTime ==
                                  null) ...[
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      String message = await attendanceProvider
                                          .checkOut();

                                      if (context.mounted) {
                                        if (message ==
                                            'No check-in found for today.') {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No check-in found for today.',
                                              ),
                                            ),
                                          );
                                        } else if (message ==
                                            'Attendance for today has already been marked.') {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Attendance for today has already been marked.',
                                              ),
                                            ),
                                          );
                                        }
                                      }
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
                                  },
                                  child: const Text("Out"),
                                ),
                                const SizedBox(width: 10),
                              ],
                              if (attendanceProvider
                                          .todayAttendance
                                          ?.checkInTime ==
                                      null &&
                                  attendanceProvider
                                          .todayAttendance
                                          ?.checkOutTime ==
                                      null) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        await attendanceProvider.markOnLeave();
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
                                    },
                                    child: const Text("Leave"),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        "Today's Record",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow(
                                "Date",
                                attendanceProvider.formattedCurrentDay ?? '__',
                              ),
                              _infoRow(
                                "Day Name",
                                attendanceProvider.todayAttendance?.dayName ??
                                    '',
                              ),
                              _infoRow(
                                "Check-In",
                                attendanceProvider
                                        .todayAttendance
                                        ?.checkInTime ??
                                    '__',
                              ),
                              _infoRow(
                                "Check-Out",
                                attendanceProvider
                                        .todayAttendance
                                        ?.checkOutTime ??
                                    '__',
                              ),
                              _infoRow(
                                "Time Spent",
                                attendanceProvider.todayAttendance?.timeSpent ??
                                    '__',
                              ),
                              _infoRow(
                                "Status",
                                attendanceProvider
                                        .todayAttendance
                                        ?.attendanceStatus ??
                                    '__',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Attendance History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: attendanceProvider.attendanceHistory.isEmpty
                            ? const Center(child: Text("No past records"))
                            : ListView.builder(
                                itemCount:
                                    attendanceProvider.attendanceHistory.length,
                                itemBuilder: (context, index) {
                                  final record = attendanceProvider
                                      .attendanceHistory[index];
                                  return AttendanceCard(attendance: record);
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigation: attendanceProvider.myName != null
          ? BottomNavigationBar(
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TasksScreen()),
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
            )
          : null,
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final Attendance attendance;

  const AttendanceCard({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Date", _formatDate(attendance.date)),
            _infoRow("Day Name", attendance.dayName ?? "--"),
            _infoRow("Check-In", attendance.checkInTime ?? "--"),
            _infoRow("Check-Out", attendance.checkOutTime ?? "--"),
            _infoRow("Time Spent", attendance.timeSpent ?? "--"),
            _infoRow("Status", attendance.attendanceStatus ?? "--"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text("$title:", style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "--";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}
