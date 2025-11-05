// lib/screens/date_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_system/models/student.dart';
import 'package:attendance_system/screens/student_detail_screen.dart';

class DateSummaryScreen extends StatefulWidget {
  const DateSummaryScreen({super.key});

  @override
  State<DateSummaryScreen> createState() => _DateSummaryScreenState();
}

class _DateSummaryScreenState extends State<DateSummaryScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> absents = [];
  List<String> internalODs = [];
  List<String> externalODs = [];
  bool _isLoading = true;
  String _statusMessage = 'Loading...';

  final Map<String, Student> _regToStudent = {};

  @override
  void initState() {
    super.initState();
    _buildRegMap();
    _loadAttendanceForDate(selectedDate);
  }

  void _buildRegMap() {
    _regToStudent.clear();
    for (var s in students) {
      _regToStudent[s.regNum] = s;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4361EE),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _isLoading = true;
      });
      await _loadAttendanceForDate(picked);
    }
  }

  Future<void> _loadAttendanceForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching attendance...';
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('absent_attendance')
          .doc(dateStr)
          .get();

      if (!doc.exists || doc.data() == null) {
        setState(() {
          absents.clear();
          internalODs.clear();
          externalODs.clear();
          _statusMessage = 'No attendance recorded for this date.';
          _isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      absents = List<String>.from(data['absents'] ?? []);
      internalODs = List<String>.from(data['internal_od'] ?? []);
      externalODs = List<String>.from(data['external_od'] ?? []);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(selectedDate);
    final allMarked = [
      ...absents.map((r) => {'reg': r, 'type': 'Absent'}),
      ...internalODs.map((r) => {'reg': r, 'type': 'Internal OD'}),
      ...externalODs.map((r) => {'reg': r, 'type': 'External OD'}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        backgroundColor: const Color(0xFF4361EE),
        actions: [
          IconButton(
            onPressed: () => _loadAttendanceForDate(selectedDate),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Card
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Color(0xFF4361EE),
              ),
              title: Text(
                'Selected Date',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(dateStr),
              trailing: ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text('Change'),
              ),
            ),
          ),

          // Loading / Empty / List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFF4361EE),
                        ),
                        SizedBox(height: 16),
                        Text(_statusMessage),
                      ],
                    ),
                  )
                : allMarked.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'All Present!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('No absentees or OD on $dateStr'),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Summary Chips
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361EE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _summaryChip(
                              'Absentees',
                              absents.length,
                              Colors.red,
                            ),
                            _summaryChip(
                              'Internal OD',
                              internalODs.length,
                              Colors.orange,
                            ),
                            _summaryChip(
                              'External OD',
                              externalODs.length,
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),

                      // List of Students
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: allMarked.length,
                          itemBuilder: (context, index) {
                            final item = allMarked[index];
                            final reg = item['reg'] as String;
                            final type = item['type'] as String;
                            final student = _regToStudent[reg];
                            if (student == null) return SizedBox();

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getTypeColor(
                                    type,
                                  ).withOpacity(0.2),
                                  child: Icon(
                                    _getTypeIcon(type),
                                    color: _getTypeColor(type),
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text('$reg • $type'),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentDetailScreen(
                                        student: student,
                                        markedDate: selectedDate,
                                        markedType: type.contains('OD')
                                            ? (type.contains('Internal')
                                                  ? 'internal'
                                                  : 'external')
                                            : 'absent',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('Absent')) return Colors.red;
    if (type.contains('Internal')) return Colors.orange;
    return Colors.purple;
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('Absent')) return Icons.close;
    return Icons.directions_run;
  }
}
