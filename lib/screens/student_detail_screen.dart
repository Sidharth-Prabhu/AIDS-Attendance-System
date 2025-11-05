// lib/screens/student_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:attendance_system/models/student.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  final DateTime markedDate;
  final String markedType; // 'absent', 'internal', 'external'

  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.markedDate,
    required this.markedType,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  List<String> absentDates = [];
  List<String> internalODDates = [];
  List<String> externalODDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() => _isLoading = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('absent_attendance')
        .get();
    final reg = widget.student.regNum;

    absentDates.clear();
    internalODDates.clear();
    externalODDates.clear();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = doc.id;
      final absents = List<String>.from(data['absents'] ?? []);
      final internal = List<String>.from(data['internal_od'] ?? []);
      final external = List<String>.from(data['external_od'] ?? []);

      if (absents.contains(reg)) absentDates.add(dateStr);
      if (internal.contains(reg)) internalODDates.add(dateStr);
      if (external.contains(reg)) externalODDates.add(dateStr);
    }

    absentDates.sort();
    internalODDates.sort();
    externalODDates.sort();

    setState(() => _isLoading = false);
  }

  Future<void> _openWhatsApp(String phone) async {
    final url = 'https://wa.me/$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('WhatsApp not installed')));
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot make call')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final markedDateStr = DateFormat('dd MMM yyyy').format(widget.markedDate);
    final markedTypeLabel = widget.markedType == 'absent'
        ? 'Absent'
        : widget.markedType == 'internal'
        ? 'Internal OD'
        : 'External OD';

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        backgroundColor: const Color(0xFF4361EE),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFF4361EE),
                            child: Text(
                              widget.student.name[0],
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            widget.student.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.student.regNum,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.red,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '$markedDateStr • $markedTypeLabel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Contact Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _makeCall(widget.student.phone ?? ''),
                          icon: Icon(Icons.phone),
                          label: Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _openWhatsApp(widget.student.phone ?? ''),
                          icon: Icon(Icons.message),
                          label: Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Attendance Stats
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance History',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 12),
                          _buildStatRow(
                            'Total Absents',
                            absentDates.length,
                            Colors.red,
                          ),
                          _buildStatRow(
                            'Internal OD',
                            internalODDates.length,
                            Colors.orange,
                          ),
                          _buildStatRow(
                            'External OD',
                            externalODDates.length,
                            Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Absent Dates
                  if (absentDates.isNotEmpty)
                    _buildDateSection('Absent Dates', absentDates, Colors.red),
                  if (internalODDates.isNotEmpty)
                    _buildDateSection(
                      'Internal OD Dates',
                      internalODDates,
                      Colors.orange,
                    ),
                  if (externalODDates.isNotEmpty)
                    _buildDateSection(
                      'External OD Dates',
                      externalODDates,
                      Colors.purple,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            '$count days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String title, List<String> dates, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(Icons.calendar_month, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        children: dates.map((d) {
          final date = DateTime.parse(d);
          return ListTile(
            dense: true,
            leading: Icon(Icons.circle, size: 8, color: color),
            title: Text(DateFormat('dd MMM yyyy').format(date)),
          );
        }).toList(),
      ),
    );
  }
}
