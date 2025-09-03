import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final List<Map<String, String>> students = [
  {'reg': '2117240070251', 'name': 'Rasool M'},
  {'reg': '2117240070252', 'name': 'Rathish P N'},
  {'reg': '2117240070253', 'name': 'Ravikumar R'},
  {'reg': '2117240070254', 'name': 'Reethu Nivyaa V'},
  {'reg': '2117240070255', 'name': 'Rishi M S'},
  {'reg': '2117240070256', 'name': 'Ritesh M S'},
  {'reg': '2117240070257', 'name': 'Rohan Kumar E'},
  {'reg': '2117240070258', 'name': 'Rohit R R'},
  {'reg': '2117240070259', 'name': 'Sabarinathan M'},
  {'reg': '2117240070260', 'name': 'Sagar M'},
  {'reg': '2117240070261', 'name': 'Sahaana B'},
  {'reg': '2117240070262', 'name': 'Sai Vishal L N'},
  {'reg': '2117240070263', 'name': 'Sailesh S'},
  {'reg': '2117240070264', 'name': 'Saindhavi S'},
  {'reg': '2117240070265', 'name': 'Sajeev Mrithul S'},
  {'reg': '2117240070266', 'name': 'Sam Meshak P'},
  {'reg': '2117240070267', 'name': 'Samyuktha J'},
  {'reg': '2117240070268', 'name': 'Sandhiya L'},
  {'reg': '2117240070269', 'name': 'Sanjana B'},
  {'reg': '2117240070270', 'name': 'Sanjay J'},
  {'reg': '2117240070271', 'name': 'Sanjay M'},
  {'reg': '2117240070272', 'name': 'Sanjay N'},
  {'reg': '2117240070273', 'name': 'Sanjeev G'},
  {'reg': '2117240070274', 'name': 'Sanjeev Y'},
  {'reg': '2117240070275', 'name': 'Santhosh P'},
  {'reg': '2117240070276', 'name': 'Santhosh R'},
  {'reg': '2117240070277', 'name': 'Santhosh Kumar S'},
  {'reg': '2117240070278', 'name': 'Santhosh Pandi M'},
  {'reg': '2117240070279', 'name': 'Saran Nithish S'},
  {'reg': '2117240070280', 'name': 'Sarika V'},
  {'reg': '2117240070281', 'name': 'Sarumathi S'},
  {'reg': '2117240070282', 'name': 'Sarvesh D'},
  {'reg': '2117240070283', 'name': 'Seenuvasan R'},
  {'reg': '2117240070284', 'name': 'Shaana Zaima S'},
  {'reg': '2117240070285', 'name': 'Shailajaa J'},
  {'reg': '2117240070286', 'name': 'Shalini G'},
  {'reg': '2117240070287', 'name': 'Shalini T'},
  {'reg': '2117240070288', 'name': 'Shalini Shahani C'},
  {'reg': '2117240070289', 'name': 'Shameena M'},
  {'reg': '2117240070290', 'name': 'Shandiya S'},
  {'reg': '2117240070291', 'name': 'Shanjithkrishna V'},
  {'reg': '2117240070292', 'name': 'Shankar Pooja'},
  {'reg': '2117240070293', 'name': 'Shanmuga Krishnan S M'},
  {'reg': '2117240070294', 'name': 'Shanmuga Sundaram M'},
  {'reg': '2117240070295', 'name': 'Shanmuganathan S S'},
  {'reg': '2117240070296', 'name': 'Sharikaa D'},
  {'reg': '2117240070297', 'name': 'Sherin Faurgana S'},
  {'reg': '2117240070298', 'name': 'Sheshank A'},
  {'reg': '2117240070299', 'name': 'Shivani S'},
  {'reg': '2117240070300', 'name': 'Shobana S'},
  {'reg': '2117240070301', 'name': 'Shreenandh L S'},
  {'reg': '2117240070302', 'name': 'Shrinidhi Meena Palaniappan'},
  {'reg': '2117240070303', 'name': 'Shriya R'},
  {'reg': '2117240070304', 'name': 'Shruthi S S'},
  {'reg': '2117240070305', 'name': 'Shyam Francis T'},
  {'reg': '2117240070306', 'name': 'Shylendhar M'},
  {'reg': '2117240070307', 'name': 'Siddartha Mariappan S'},
  {'reg': '2117240070308', 'name': 'Sidharth P L'},
  {'reg': '2117240070309', 'name': 'Sindhuja M'},
  {'reg': '2117240070310', 'name': 'Sivagurunathan P'},
  {'reg': '2117240070311', 'name': 'Sofia M'},
  {'reg': '2117240070312', 'name': 'Sorneshvaran D R'},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Attendance App', home: AuthWrapper());
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return snapshot.hasData ? HomeScreen() : LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(onPressed: login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [IconButton(onPressed: logout, icon: Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttendancePage()),
              ),
              child: Text('Mark Attendance'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ViewAttendancePage()),
              ),
              child: Text('View Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  Map<String, bool> absentStatus = {};

  @override
  void initState() {
    super.initState();
    students.forEach((student) => absentStatus[student['reg']!] = false);
    loadAttendance();
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      loadAttendance();
    }
  }

  void toggleAbsent(String reg) {
    setState(() => absentStatus[reg] = !absentStatus[reg]!);
  }

  Future<void> loadAttendance() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final doc = await FirebaseFirestore.instance
        .collection('absent_attendance')
        .doc(dateStr)
        .get();
    final absents = doc.exists
        ? List<String>.from(doc['absents'] ?? [])
        : <String>[];
    setState(() {
      students.forEach(
        (student) =>
            absentStatus[student['reg']!] = absents.contains(student['reg']!),
      );
    });
  }

  Future<void> submitAttendance() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final absents = <String>[];
    absentStatus.forEach((reg, isAbsent) {
      if (isAbsent) absents.add(reg);
    });
    await FirebaseFirestore.instance
        .collection('absent_attendance')
        .doc(dateStr)
        .set({'absents': absents});

    // Update summary
    final datesQuery = await FirebaseFirestore.instance
        .collection('absent_attendance')
        .get();
    final totalDays = datesQuery.docs.length;
    for (final student in students) {
      final reg = student['reg']!;
      int absentCount = 0;
      for (final dateDoc in datesQuery.docs) {
        final abs = List<String>.from(dateDoc['absents'] ?? []);
        if (abs.contains(reg)) absentCount++;
      }
      final present = totalDays - absentCount;
      final percent = totalDays > 0
          ? (present / totalDays * 100).toStringAsFixed(2)
          : '0';
      await FirebaseFirestore.instance.collection('summary').doc(reg).set({
        'name': student['name'],
        'total_days': totalDays,
        'present': present,
        'absent': absentCount,
        'percentage': percent,
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Attendance submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance for ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
        ),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => selectDate(context),
            child: Text('Select Date'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final reg = student['reg']!;
                final isAbsent = absentStatus[reg]!;
                return ListTile(
                  title: Text('${student['reg']} - ${student['name']}'),
                  trailing: Icon(
                    isAbsent ? Icons.close : Icons.check,
                    color: isAbsent ? Colors.red : Colors.green,
                  ),
                  onTap: () => toggleAbsent(reg),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: submitAttendance, child: Text('Submit')),
        ],
      ),
    );
  }
}

class ViewAttendancePage extends StatefulWidget {
  @override
  _ViewAttendancePageState createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('View Attendance'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Absent Sheet'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: TabBarView(children: [AbsentSheetView(), SummaryView()]),
      ),
    );
  }
}

class AbsentSheetView extends StatefulWidget {
  @override
  _AbsentSheetViewState createState() => _AbsentSheetViewState();
}

class _AbsentSheetViewState extends State<AbsentSheetView> {
  List<String> dates = [];
  Map<String, List<String>> dateToAbsents = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final query = await FirebaseFirestore.instance
        .collection('absent_attendance')
        .get();
    setState(() {
      dateToAbsents = {
        for (var doc in query.docs)
          doc.id: List<String>.from(doc['absents'] ?? []),
      };
      dates = dateToAbsents.keys.toList()..sort();
    });
  }

  Future<void> exportAndShareAbsentSheetCSV() async {
    final csvBuffer = StringBuffer();

    // Header row
    final header =
        ['Reg No', 'Name'] +
        dates
            .map((d) => DateFormat('dd-MM-yyyy').format(DateTime.parse(d)))
            .toList();
    csvBuffer.writeln(header.join(','));

    // Data rows
    for (final student in students) {
      final reg = student['reg']!;
      final name = student['name']!.contains(',')
          ? '"${student['name']!}"'
          : student['name']!;
      final row = [
        reg,
        name,
        ...dates.map(
          (date) => dateToAbsents[date]!.contains(reg) ? 'Absent' : 'Present',
        ),
      ];
      csvBuffer.writeln(row.join(','));
    }

    // Save CSV file
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/absent_sheet.csv');
    await file.writeAsString(csvBuffer.toString());

    // Share CSV file
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Absent Sheet Attendance Report (CSV)');
  }

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) return Center(child: Text('No data'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Absent Sheet'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: exportAndShareAbsentSheetCSV,
            tooltip: 'Export & Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Reg No')),
                DataColumn(label: Text('Name')),
                ...dates.map(
                  (date) => DataColumn(
                    label: Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.parse(date)),
                    ),
                  ),
                ),
              ],
              rows: students.map((student) {
                final reg = student['reg']!;
                return DataRow(
                  cells: [
                    DataCell(Text(reg)),
                    DataCell(Text(student['name']!)),
                    ...dates.map(
                      (date) => DataCell(
                        Text(
                          dateToAbsents[date]!.contains(reg)
                              ? 'Absent'
                              : 'Present',
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class SummaryView extends StatefulWidget {
  @override
  _SummaryViewState createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> summaryDocs = [];

  @override
  void initState() {
    super.initState();
    loadSummary();
  }

  Future<void> loadSummary() async {
    final query = await FirebaseFirestore.instance.collection('summary').get();
    setState(() {
      summaryDocs = query.docs;
    });
  }

  Future<void> exportAndShareSummaryCSV() async {
    // Build CSV header
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Reg No,Name,Total Days,Present,Absent,Percentage');

    // Build CSV rows
    for (final student in students) {
      final reg = student['reg']!;
      QueryDocumentSnapshot<Map<String, dynamic>>? doc;
      try {
        doc = summaryDocs.firstWhere((d) => d.id == reg);
      } catch (e) {
        doc = null;
      }
      final data = doc != null
          ? doc.data()
          : {
              'total_days': 0,
              'present': 0,
              'absent': 0,
              'percentage': '0',
              'name': student['name'],
            };

      // Escape commas in names if any
      final name = student['name']!.contains(',')
          ? '"${student['name']!}"'
          : student['name']!;

      csvBuffer.writeln(
        '$reg,$name,${data['total_days']},${data['present']},${data['absent']},${data['percentage']}',
      );
    }

    // Save CSV file
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/summary_attendance.csv');
    await file.writeAsString(csvBuffer.toString());

    // Share CSV file
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Summary Attendance Report (CSV)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Summary'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: exportAndShareSummaryCSV,
            tooltip: 'Export & Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: DataTable(
              columns: [
                DataColumn(label: Text('Reg No')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Total Days')),
                DataColumn(label: Text('Present')),
                DataColumn(label: Text('Absent')),
                DataColumn(label: Text('Percentage')),
              ],
              rows: students.map((student) {
                final reg = student['reg']!;
                QueryDocumentSnapshot<Map<String, dynamic>>? doc;
                try {
                  doc = summaryDocs.firstWhere((d) => d.id == reg);
                } catch (e) {
                  doc = null;
                }
                final data = doc != null
                    ? doc.data()
                    : {
                        'total_days': 0,
                        'present': 0,
                        'absent': 0,
                        'percentage': '0',
                        'name': student['name'],
                      };

                return DataRow(
                  cells: [
                    DataCell(Text(reg)),
                    DataCell(Text(student['name']!)),
                    DataCell(Text(data['total_days'].toString())),
                    DataCell(Text(data['present'].toString())),
                    DataCell(Text(data['absent'].toString())),
                    DataCell(Text('${data['percentage']}%')),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
