// lib/screens/absentee_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_system/models/student.dart';
import 'package:attendance_system/screens/student_detail_screen.dart';

class AbsenteeSummaryScreen extends StatefulWidget {
  final DateTime date;
  final List<String> absents;
  final List<String> internalODs;
  final List<String> externalODs;

  const AbsenteeSummaryScreen({
    super.key,
    required this.date,
    required this.absents,
    required this.internalODs,
    required this.externalODs,
  });

  @override
  State<AbsenteeSummaryScreen> createState() => _AbsenteeSummaryScreenState();
}

class _AbsenteeSummaryScreenState extends State<AbsenteeSummaryScreen> {
  final Map<String, Student> _regToStudent = {};

  @override
  void initState() {
    super.initState();
    _regToStudent.clear();
    for (var s in students) {
      _regToStudent[s.regNum] = s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(widget.date);
    final allAbsents = [
      ...widget.absents.map((r) => {'reg': r, 'type': 'Absent'}),
      ...widget.internalODs.map((r) => {'reg': r, 'type': 'Internal OD'}),
      ...widget.externalODs.map((r) => {'reg': r, 'type': 'External OD'}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Summary'),
        backgroundColor: const Color(0xFF4361EE),
      ),
      body: allAbsents.isEmpty
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
                        'Attendance Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$dateStr',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summaryChip(
                            'Absentees',
                            widget.absents.length,
                            Colors.red,
                          ),
                          _summaryChip(
                            'Internal OD',
                            widget.internalODs.length,
                            Colors.orange,
                          ),
                          _summaryChip(
                            'External OD',
                            widget.externalODs.length,
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
                    itemCount: allAbsents.length,
                    itemBuilder: (context, index) {
                      final item = allAbsents[index];
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
                                  markedDate: widget.date,
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
