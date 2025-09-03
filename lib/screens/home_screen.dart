// lib/screens/home_screen.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();
  Map<String, String> attendance = {};

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    var snapshot = await _firestore
        .collection('attendance')
        .doc(dateStr)
        .collection('students')
        .get();
    setState(() {
      attendance = {for (var doc in snapshot.docs) doc.id: doc['status']};
    });
  }

  Future<void> _markAttendance(String regNum, String status) async {
    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    if (status == 'present') {
      await _firestore
          .collection('attendance')
          .doc(dateStr)
          .collection('students')
          .doc(regNum)
          .delete();
    } else {
      await _firestore
          .collection('attendance')
          .doc(dateStr)
          .collection('students')
          .doc(regNum)
          .set({'status': status});
    }
    if (mounted) {
      setState(() {
        attendance[regNum] = status;
      });
    }
  }

  Future<void> _showReportDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('This Month'),
              onTap: () => _generateForMonth(true),
            ),
            ListTile(
              title: Text('Last Month'),
              onTap: () => _generateForMonth(false),
            ),
            ListTile(title: Text('Custom Range'), onTap: _generateCustom),
          ],
        ),
      ),
    );
  }

  void _generateForMonth(bool current) {
    Navigator.pop(context);
    var now = DateTime.now();
    int month = current ? now.month : now.month - 1;
    int year = current ? now.year : (month > 0 ? now.year : now.year - 1);
    if (month == 0) month = 12;
    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 0);
    _generateReport(start, end);
  }

  Future<void> _generateCustom() async {
    Navigator.pop(context);
    DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (range != null) _generateReport(range.start, range.end);
  }

  Future<void> _generateReport(DateTime start, DateTime end) async {
    try {
      String startStr = DateFormat('yyyy-MM-dd').format(start);
      String endStr = DateFormat('yyyy-MM-dd').format(end);
      QuerySnapshot dateSnap = await _firestore
          .collection('attendance')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .get();
      List<String> dateStrs = dateSnap.docs.map((d) => d.id).toList();
      List<DateTime> workingDates =
          dateStrs.map((s) => DateFormat('yyyy-MM-dd').parse(s)).toList()
            ..sort();
      int totalDays = workingDates.length;
      if (totalDays == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No attendance data for selected range')),
        );
        return;
      }

      Map<DateTime, Map<String, String>> dateToAttendance = {};
      List<Future> futures = [];
      for (String ds in dateStrs) {
        DateTime d = DateFormat('yyyy-MM-dd').parse(ds);
        futures.add(
          _firestore
              .collection('attendance')
              .doc(ds)
              .collection('students')
              .get()
              .then((snapshot) {
                dateToAttendance[d] = {
                  for (var doc in snapshot.docs) doc.id: doc['status'],
                };
              }),
        );
      }
      await Future.wait(futures);

      var excel = Excel.createExcel();
      Sheet summarySheet = excel['Summary'];
      summarySheet.appendRow([TextCellValue('Attendance Summary')]);
      summarySheet.appendRow([
        TextCellValue('Register Number'),
        TextCellValue('Student Name'),
        TextCellValue('Total number of working days'),
        TextCellValue('Number of days present'),
        TextCellValue('Number of days absent'),
        TextCellValue('Attendance percentage'),
      ]);

      final NumberFormat percFormat = NumberFormat('#.##');
      for (Student student in students) {
        int absent = 0;
        for (DateTime d in workingDates) {
          String? status = dateToAttendance[d]?[student.regNum];
          if (status == 'absent') absent++;
        }
        int present = totalDays - absent;
        double perc = totalDays > 0 ? (present / totalDays) * 100 : 0;
        String percStr = percFormat.format(perc);
        summarySheet.appendRow([
          TextCellValue(student.regNum),
          TextCellValue(student.name),
          IntCellValue(totalDays),
          IntCellValue(present),
          IntCellValue(absent),
          TextCellValue(percStr),
        ]);
      }

      Sheet absentSheet = excel['Absent Sheet'];
      absentSheet.appendRow([TextCellValue('Attendance Sheet - AI&DS E')]);
      List<CellValue> header = [
        TextCellValue('Register Number'),
        TextCellValue('Student Name'),
      ];
      header.addAll(
        workingDates.map(
          (d) => TextCellValue(DateFormat('dd-MM-yyyy').format(d)),
        ),
      );
      absentSheet.appendRow(header);

      for (Student student in students) {
        List<CellValue> row = [
          TextCellValue(student.regNum),
          TextCellValue(student.name),
        ];
        for (DateTime d in workingDates) {
          String? status = dateToAttendance[d]?[student.regNum];
          row.add(
            status == 'absent'
                ? TextCellValue('Absent')
                : status == 'od'
                ? TextCellValue('OD')
                : TextCellValue(''),
          );
        }
        absentSheet.appendRow(row);
      }

      var bytes = excel.encode();
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate Excel file')),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      String path =
          '${dir.path}/attendance_report_${startStr}_to_${endStr}.xlsx';
      File file = File(path);
      await file.writeAsBytes(bytes);

      // Verify file exists
      if (await file.exists()) {
        // Open sharing options
        await Share.shareXFiles([
          XFile(
            path,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ], text: 'Attendance Report from $startStr to $endStr');
        // Optionally open the file
        OpenFile.open(path);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save Excel file')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance - ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
        ),
        actions: [
          IconButton(icon: Icon(Icons.report), onPressed: _showReportDialog),
        ],
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          Student student = students[index];
          String status = attendance[student.regNum] ?? 'present';
          return Dismissible(
            key: Key(
              '${student.regNum}-${selectedDate.toIso8601String()}-${status.hashCode}',
            ),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Text('OD', style: TextStyle(color: Colors.white)),
            ),
            confirmDismiss: (_) async {
              if (status != 'od') {
                await _markAttendance(student.regNum, 'od');
              }
              return false; // Prevent widget removal
            },
            child: ListTile(
              title: Text('${student.regNum} - ${student.name}'),
              subtitle: Text(status.toUpperCase()),
              onTap: () async {
                String newStatus = status == 'absent' ? 'present' : 'absent';
                if (status != 'od') {
                  await _markAttendance(student.regNum, newStatus);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.calendar_today),
        onPressed: () async {
          DateTime? date = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            setState(() => selectedDate = date);
            _loadAttendance();
          }
        },
      ),
    );
  }
}
