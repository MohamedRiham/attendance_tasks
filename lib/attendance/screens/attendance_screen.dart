import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? userName;
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;
  List<Map<String, dynamic>> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
  }

  void _checkIn() {
    setState(() {
      checkInTime = TimeOfDay.now();
    });
  }

  void _checkOut() {
    setState(() {
      checkOutTime = TimeOfDay.now();
    });
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "--:--";
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dt);
  }

  String _getStatus() {
    if (checkInTime != null && checkOutTime != null) return "Present";
    if (checkInTime != null || checkOutTime != null) return "Incomplete";
    return "Absent";
  }

  String _getTimeSpent() {
    if (checkInTime == null || checkOutTime == null) return "--:--";
    final now = DateTime.now();
    final checkIn = DateTime(now.year, now.month, now.day, checkInTime!.hour, checkInTime!.minute);
    final checkOut = DateTime(now.year, now.month, now.day, checkOutTime!.hour, checkOutTime!.minute);
    final diff = checkOut.difference(checkIn);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  void _submitName(String name) {
    setState(() {
      userName = name;
    });
  }

  void _markOnLeave() {
    setState(() {
      attendanceHistory.add({
        'date': DateFormat('MM/dd/yyyy').format(DateTime.now()),
        'status': 'On Leave',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayFormatted = DateFormat('MM/dd/yyyy').format(now);
    final dayName = DateFormat('EEEE').format(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Log')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userName == null
            ? Column(
                children: [
                  const Text("Enter your name to begin:", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(labelText: "Name"),
                    onSubmitted: _submitName,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello, $userName", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(onPressed: _checkIn, child: const Text("Check-In")),
                      const SizedBox(width: 10),
                      ElevatedButton(onPressed: _checkOut, child: const Text("Check-Out")),
                      const Spacer(),
                      TextButton(onPressed: _markOnLeave, child: const Text("Mark On Leave")),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Record", style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          _infoRow("Date", todayFormatted),
                          _infoRow("Day", dayName),
                          _infoRow("Check-In", _formatTimeOfDay(checkInTime)),
                          _infoRow("Check-Out", _formatTimeOfDay(checkOutTime)),
                          _infoRow("Time Spent", _getTimeSpent()),
                          _infoRow("Status", _getStatus()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Attendance History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: attendanceHistory.isEmpty
                        ? const Text("No past records")
                        : ListView.builder(
                            itemCount: attendanceHistory.length,
                            itemBuilder: (context, index) {
                              final record = attendanceHistory[index];
                              return ListTile(
                                title: Text(record['date']),
                                trailing: Text(record['status']),
                              );
                            },
                          ),
                  ),
                ],
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
