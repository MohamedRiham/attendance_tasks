import 'package:attendance_tasks/attendance/provider/attendance_provider.dart';
import 'package:attendance_tasks/common/widgets/custom_scaffold.dart';
import 'package:attendance_tasks/common/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  TextEditingController userNameController = TextEditingController();
  late AttendanceProvider attendanceProvider;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await attendanceProvider.loadName();
       attendanceProvider.loadAttendanceHistory();

    });
  }





  @override
  Widget build(BuildContext context) {
    attendanceProvider = Provider.of<AttendanceProvider>(context);
    return CustomScaffold(
      title: 'Attendance',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading ? Center(child: CircularProgressIndicator()): attendanceProvider.myName == null
              ? Column(
                  children: [
                    const Text(
                      "Enter your name to begin:",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: userNameController,
                      hintText: 'User Name',
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await attendanceProvider.saveUserName(
                            userNameController.text,
                          );
                          setState(() {
                            _isLoading = false;
                          });
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
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, ${attendanceProvider.myName}",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
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
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'QAn error occurred while saving details',
                                    ),
                                  ),
                                );
                              }

                            }
                            setState(() {
                              _isLoading = false;
                            });

                          },
                          child: const Text("Check-In"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              setState(() {
                                _isLoading = true;
                              });

                              String message = await attendanceProvider
                                  .checkOut();

                              if (context.mounted) {
                                if (message == 'No check-in found for today.') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No check-in found for today.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'QAn error occurred while saving details',
                                    ),
                                  ),
                                );
                              }

                            }
                            setState(() {
                              _isLoading = false;
                            });


                          },
                          child: const Text("Check-Out"),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {},
                            child: const Text("Mark On Leave"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
                            Text(
                              "Today's Record",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            _infoRow("Date", attendanceProvider.formattedCurrentDay ?? '__'),
                            _infoRow("Day", attendanceProvider.todayAttendance?.dayName ?? ''),
                            _infoRow("Check-In", attendanceProvider.todayAttendance?.checkInTime ?? '__'),
                            _infoRow(
                              "Check-Out",
                              attendanceProvider.todayAttendance?.checkOutTime ?? '__',
                            ),
                            _infoRow("Time Spent", attendanceProvider.todayAttendance?.timeSpent ?? '__'),
                            _infoRow("Status", attendanceProvider.todayAttendance?.attendanceStatus ?? 'Absent'),
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
                          ? const Text("No past records")
                          : ListView.builder(
                              itemCount:
                                  attendanceProvider.attendanceHistory.length,
                              itemBuilder: (context, index) {
                                final record =
                                    attendanceProvider.attendanceHistory[index];
                                return ListTile(
                                  title: Text(record.dayName ?? ''),
                                  trailing: Text(record.attendanceStatus ?? ''),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
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
