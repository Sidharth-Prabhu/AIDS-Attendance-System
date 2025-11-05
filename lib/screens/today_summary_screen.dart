// lib/screens/today_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_system/models/student.dart';
import 'package:attendance_system/screens/student_detail_screen.dart';

class TodaySummaryScreen extends StatefulWidget {
  const TodaySummaryScreen({super.key});

  @override
  State<TodaySummaryScreen> createState() => _TodaySummaryScreenState();
}

class _TodaySummaryScreenState extends State<TodaySummaryScreen> {
  DateTime? today;
  List<String> absents = [];
  List<String> internalODs = [];
  List<String> externalODs = [];
  bool _isLoading = true;
  String _statusMessage = 'Loading today\'s attendance...';

  final Map<String, Student> _regToStudent = {};

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  Future<void> _loadTodayAttendance() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching today\'s record...';
    });

    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    final dateStr = DateFormat('yyyy-MM-dd').format(today!);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('absent_attendance')
          .doc(dateStr)
          .get();

      if (!doc.exists || doc.data() == null) {
        setState(() {
          _statusMessage = 'No attendance marked for today yet.';
          _isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      absents = List<String>.from(data['absents'] ?? []);
      internalODs = List<String>.from(data['internal_od'] ?? []);
      externalODs = List<String>.from(data['external_od'] ?? []);

      // Build reg → student map
      _regToStudent.clear();
      for (var s in students) {
        _regToStudent[s.regNum] = s;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = today != null
        ? DateFormat('dd MMM yyyy').format(today!)
        : '';
    final allMarked = [
      ...absents.map((r) => {'reg': r, 'type': 'Absent'}),
      ...internalODs.map((r) => {'reg': r, 'type': 'Internal OD'}),
      ...externalODs.map((r) => {'reg': r, 'type': 'External OD'}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Summary'),
        backgroundColor: const Color(0xFF4361EE),
        actions: [
          IconButton(
            onPressed: _loadTodayAttendance,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('No absentees or OD on $dateStr'),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4361EE), Color(0xFF3A0CA3)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summaryChip('Absentees', absents.length, Colors.red),
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
                    ],
                  ),
                ),
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
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentDetailScreen(
                                  student: student,
                                  markedDate: today!,
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
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
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
