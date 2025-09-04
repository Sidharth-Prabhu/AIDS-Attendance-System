import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

// Color Scheme
const Color primaryColor = Color(0xFF4361EE);
const Color secondaryColor = Color(0xFF3A0CA3);
const Color accentColor = Color(0xFF7209B7);
const Color successColor = Color(0xFF4CC9F0);
const Color warningColor = Color(0xFFF72585);
const Color backgroundColor = Color(0xFFF8F9FA);
const Color cardColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF212529);

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Pro',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: backgroundColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        textTheme: TextTheme(
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
        ),
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricChecked = false;
  bool _biometricAuthRequired = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

  Future<void> _checkBiometricAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final lastLogin = prefs.getInt('last_login') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      setState(() => _biometricAuthRequired = true);

      final authenticated = await _authenticateWithBiometrics();
      if (!authenticated) {
        await FirebaseAuth.instance.signOut();
        await prefs.remove('last_login');
        setState(() => _biometricAuthRequired = false);
      } else {
        await prefs.setInt('last_login', now);
        setState(() => _biometricAuthRequired = false);
      }
    }

    setState(() => _isBiometricChecked = true);
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return true;

      final isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return true;

      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the attendance app',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      return result;
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBiometricChecked) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: 64, color: Colors.white),
              SizedBox(height: 20),
              if (_biometricAuthRequired)
                Text(
                  'Please authenticate to continue...',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: primaryColor,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return snapshot.hasData ? HomeScreen() : LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> login() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passController.text.trim(),
          );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: warningColor),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: warningColor,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'ATTENDANCE PRO',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Smart Attendance Management',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Login Form
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Email Field
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: primaryColor),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),

                      // Password Field
                      TextField(
                        controller: passController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  'All registered users can login',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_login');
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Pro'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user?.email ?? 'User ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Manage student attendance efficiently',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Action Cards
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),

            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.edit_calendar,
                    title: 'Mark\nAttendance',
                    color: successColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AttendancePage()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.visibility,
                    title: 'View\nAttendance',
                    color: accentColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ViewAttendancePage()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Reports &\nAnalytics',
                    color: warningColor,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.settings,
                    title: 'Settings &\nPreferences',
                    color: primaryColor,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AttendanceStatus { present, absent, od }

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  Map<String, AttendanceStatus> attendanceStatus = {};
  Map<String, String> odType =
      {}; // Tracks 'internal' or 'external' for OD students
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var student in students) {
      attendanceStatus[student['reg']!] = AttendanceStatus.present;
      odType[student['reg']!] = '';
    }
    loadAttendance();
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      await loadAttendance();
    }
  }

  void togglePresentAbsentOD(String reg) {
    setState(() {
      final current = attendanceStatus[reg]!;
      if (current == AttendanceStatus.present) {
        attendanceStatus[reg] = AttendanceStatus.absent;
      } else if (current == AttendanceStatus.absent) {
        attendanceStatus[reg] = AttendanceStatus.present;
      } else if (current == AttendanceStatus.od) {
        attendanceStatus[reg] = AttendanceStatus.present;
      }
    });
  }

  Future<void> loadAttendance() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final doc = await FirebaseFirestore.instance
        .collection('absent_attendance')
        .doc(dateStr)
        .get();

    final absents = doc.exists && doc.data()!.containsKey('absents')
        ? List<String>.from(doc['absents'])
        : <String>[];
    final internalODs = doc.exists && doc.data()!.containsKey('internal_od')
        ? List<String>.from(doc['internal_od'])
        : <String>[];
    final externalODs = doc.exists && doc.data()!.containsKey('external_od')
        ? List<String>.from(doc['external_od'])
        : <String>[];

    setState(() {
      for (var student in students) {
        final reg = student['reg']!;
        if (internalODs.contains(reg)) {
          attendanceStatus[reg] = AttendanceStatus.od;
          odType[reg] = 'internal';
        } else if (externalODs.contains(reg)) {
          attendanceStatus[reg] = AttendanceStatus.od;
          odType[reg] = 'external';
        } else if (absents.contains(reg)) {
          attendanceStatus[reg] = AttendanceStatus.absent;
          odType[reg] = '';
        } else {
          attendanceStatus[reg] = AttendanceStatus.present;
          odType[reg] = '';
        }
      }
      _isLoading = false;
    });
  }

  Future<void> submitAttendance() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final absents = <String>[];
    final internalODs = <String>[];
    final externalODs = <String>[];

    attendanceStatus.forEach((reg, status) {
      if (status == AttendanceStatus.absent) {
        absents.add(reg);
      } else if (status == AttendanceStatus.od) {
        if (odType[reg] == 'internal') {
          internalODs.add(reg);
        } else if (odType[reg] == 'external') {
          externalODs.add(reg);
        }
      }
    });

    await FirebaseFirestore.instance
        .collection('absent_attendance')
        .doc(dateStr)
        .set({
          'absents': absents,
          'internal_od': internalODs,
          'external_od': externalODs,
        });

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance submitted successfully!'),
        backgroundColor: successColor,
      ),
    );

    await _shareAttendanceViaWhatsApp(absents, internalODs, externalODs);
  }

  Future<void> _shareAttendanceViaWhatsApp(
    List<String> absents,
    List<String> internalODs,
    List<String> externalODs,
  ) async {
    final dateFormatted = DateFormat('d MMMM').format(selectedDate);
    final presentCount =
        students.length -
        absents.length -
        internalODs.length -
        externalODs.length;
    final absentCount = absents.length;
    final internalODCount = internalODs.length;
    final externalODCount = externalODs.length;

    final absentsStr = absents.isEmpty
        ? 'nil'
        : absents.map((e) => e.substring(e.length - 3)).join(',');
    final internalODStr = internalODs.isEmpty
        ? 'nil'
        : internalODs.map((e) => e.substring(e.length - 3)).join(',');
    final externalODStr = externalODs.isEmpty
        ? 'nil'
        : externalODs.map((e) => e.substring(e.length - 3)).join(',');

    final message =
        'II AIDS-E\n'
        '$dateFormatted\n'
        'Absentees: $absentsStr\n'
        'Present Count: $presentCount\n'
        'Internal OD: $internalODStr\n'
        'Internal OD Count: $internalODCount\n'
        'External OD: $externalODStr\n'
        'External OD Count: $externalODCount\n'
        'No. of Absentees: $absentCount';

    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    final whatsappWebUrl =
        'https://wa.me/?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (await canLaunchUrl(Uri.parse(whatsappWebUrl))) {
      await launchUrl(
        Uri.parse(whatsappWebUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'WhatsApp is not installed and WhatsApp Web cannot be opened.',
          ),
          backgroundColor: warningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance')),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Date:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 8),
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final reg = student['reg']!;
                      final status = attendanceStatus[reg]!;

                      Color avatarBg;
                      IconData avatarIcon;
                      Color avatarIconColor;

                      switch (status) {
                        case AttendanceStatus.present:
                          avatarBg = successColor.withOpacity(0.2);
                          avatarIcon = Icons.check;
                          avatarIconColor = successColor;
                          break;
                        case AttendanceStatus.absent:
                          avatarBg = warningColor.withOpacity(0.2);
                          avatarIcon = Icons.close;
                          avatarIconColor = warningColor;
                          break;
                        case AttendanceStatus.od:
                          avatarBg = accentColor.withOpacity(0.2);
                          avatarIcon = Icons.directions_run;
                          avatarIconColor = accentColor;
                          break;
                      }

                      return Dismissible(
                        key: Key(reg),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: accentColor,
                          child: Row(
                            children: [
                              Icon(Icons.directions_run, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Mark External OD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          color: successColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Mark Internal OD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.directions_run, color: Colors.white),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            setState(() {
                              attendanceStatus[reg] = AttendanceStatus.od;
                              odType[reg] = 'external';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${student['name']} marked as External OD',
                                ),
                                backgroundColor: accentColor,
                              ),
                            );
                          } else if (direction == DismissDirection.endToStart) {
                            setState(() {
                              attendanceStatus[reg] = AttendanceStatus.od;
                              odType[reg] = 'internal';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${student['name']} marked as Internal OD',
                                ),
                                backgroundColor: successColor,
                              ),
                            );
                          }
                          return false;
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: avatarBg,
                              child: Icon(
                                avatarIcon,
                                color: avatarIconColor,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              student['name']!,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text('Reg: $reg'),
                            trailing: Switch(
                              value: status == AttendanceStatus.absent,
                              onChanged: (value) {
                                setState(() {
                                  if (status == AttendanceStatus.od) {
                                    attendanceStatus[reg] = value
                                        ? AttendanceStatus.absent
                                        : AttendanceStatus.present;
                                    odType[reg] = '';
                                  } else {
                                    attendanceStatus[reg] = value
                                        ? AttendanceStatus.absent
                                        : AttendanceStatus.present;
                                    odType[reg] = '';
                                  }
                                });
                              },
                              activeThumbColor: warningColor,
                              inactiveThumbColor: successColor,
                            ),
                            onTap: () {
                              if (status == AttendanceStatus.od) {
                                setState(() {
                                  attendanceStatus[reg] =
                                      AttendanceStatus.present;
                                  odType[reg] = '';
                                });
                              } else {
                                togglePresentAbsentOD(reg);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : submitAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'SUBMIT ATTENDANCE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({super.key});

  @override
  _ViewAttendancePageState createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  DateTime? fromDate;
  DateTime? toDate;
  bool useDateRange = false;

  Future<void> _selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => fromDate = picked);
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Attendance Records'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_month, size: 48, color: primaryColor),
                      SizedBox(height: 12),
                      Text(
                        'Attendance Records',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'View and analyze attendance data',
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.date_range, color: primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Date Range Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: useDateRange,
                            onChanged: (value) {
                              setState(() {
                                useDateRange = value ?? false;
                                if (!useDateRange) {
                                  fromDate = null;
                                  toDate = null;
                                }
                              });
                            },
                            activeColor: primaryColor,
                          ),
                          Text('Use Date Range'),
                        ],
                      ),
                      if (useDateRange) ...[
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _selectFromDate(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: primaryColor),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      fromDate == null
                                          ? 'From Date'
                                          : DateFormat(
                                              'dd MMM',
                                            ).format(fromDate!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _selectToDate(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: primaryColor),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      toDate == null
                                          ? 'To Date'
                                          : DateFormat(
                                              'dd MMM',
                                            ).format(toDate!),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (fromDate != null &&
                            toDate != null &&
                            fromDate!.isAfter(toDate!))
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'From date cannot be after to date',
                              style: TextStyle(
                                color: warningColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (useDateRange && (fromDate == null || toDate == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select both from and to dates'),
                        backgroundColor: warningColor,
                      ),
                    );
                    return;
                  }
                  if (useDateRange && fromDate!.isAfter(toDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('From date cannot be after to date'),
                        backgroundColor: warningColor,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomAttendanceView(
                        fromDate: useDateRange ? fromDate : null,
                        toDate: useDateRange ? toDate : null,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'VIEW ATTENDANCE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAttendanceView extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;

  const CustomAttendanceView({super.key, this.fromDate, this.toDate});

  @override
  _CustomAttendanceViewState createState() => _CustomAttendanceViewState();
}

class _CustomAttendanceViewState extends State<CustomAttendanceView> {
  List<String> filteredDates = [];
  Map<String, List<String>> dateToAbsents = {};
  Map<String, List<String>> dateToInternalODs = {};
  Map<String, List<String>> dateToExternalODs = {};
  Map<String, Map<String, dynamic>> studentSummary = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);

    final query = await FirebaseFirestore.instance
        .collection('absent_attendance')
        .get();

    final allDates = query.docs.map((doc) => doc.id).toList()..sort();

    if (widget.fromDate != null && widget.toDate != null) {
      final fromStr = DateFormat('yyyy-MM-dd').format(widget.fromDate!);
      final toStr = DateFormat('yyyy-MM-dd').format(widget.toDate!);

      filteredDates = allDates.where((date) {
        return date.compareTo(fromStr) >= 0 && date.compareTo(toStr) <= 0;
      }).toList();
    } else {
      filteredDates = allDates;
    }

    dateToAbsents = {};
    dateToInternalODs = {};
    dateToExternalODs = {};

    for (var doc in query.docs) {
      if (filteredDates.contains(doc.id)) {
        dateToAbsents[doc.id] = List<String>.from(doc.data()['absents'] ?? []);
        dateToInternalODs[doc.id] = List<String>.from(
          doc.data()['internal_od'] ?? [],
        );
        dateToExternalODs[doc.id] = List<String>.from(
          doc.data()['external_od'] ?? [],
        );
      }
    }

    studentSummary = {};
    final totalDaysInRange = filteredDates.length;

    for (final student in students) {
      final reg = student['reg']!;
      int absentCount = 0;
      int odCount = 0;

      for (final date in filteredDates) {
        if (dateToAbsents[date]?.contains(reg) ?? false) {
          absentCount++;
        }
        final isInternalOD = dateToInternalODs[date]?.contains(reg) ?? false;
        final isExternalOD = dateToExternalODs[date]?.contains(reg) ?? false;
        if (isInternalOD || isExternalOD) {
          odCount++;
        }
      }

      final present = totalDaysInRange - absentCount - odCount;
      final percentage = totalDaysInRange > 0
          ? (present / totalDaysInRange * 100).toStringAsFixed(2)
          : '0.00';

      studentSummary[reg] = {
        'name': student['name'],
        'total_days': totalDaysInRange,
        'present': present,
        'absent': absentCount,
        'od': odCount,
        'percentage': percentage,
      };
    }

    setState(() => _isLoading = false);
  }

  Future<void> exportAndShareAbsentSheetCSV() async {
    final csvBuffer = StringBuffer();
    final header =
        ['Reg No', 'Name'] +
        filteredDates
            .map((d) => DateFormat('dd-MM-yyyy').format(DateTime.parse(d)))
            .toList();
    csvBuffer.writeln(header.join(','));

    for (final student in students) {
      final reg = student['reg']!;
      final name = student['name']!.contains(',')
          ? '"${student['name']!}"'
          : student['name']!;
      final row = [
        reg,
        name,
        ...filteredDates.map((date) {
          final isAbsent = dateToAbsents[date]?.contains(reg) ?? false;
          final isInternalOD = dateToInternalODs[date]?.contains(reg) ?? false;
          final isExternalOD = dateToExternalODs[date]?.contains(reg) ?? false;
          if (isAbsent) return 'Absent';
          if (isInternalOD) return 'Internal OD';
          if (isExternalOD) return 'External OD';
          return 'Present';
        }),
      ];
      csvBuffer.writeln(row.join(','));
    }

    final dir = await getTemporaryDirectory();
    final rangeText = widget.fromDate != null && widget.toDate != null
        ? '${DateFormat('ddMMyy').format(widget.fromDate!)}_${DateFormat('ddMMyy').format(widget.toDate!)}'
        : 'all_dates';
    final file = File('${dir.path}/attendance_sheet_$rangeText.csv');
    await file.writeAsString(csvBuffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'Attendance Sheet Report (${widget.fromDate != null ? 'Custom Range' : 'All Dates'})',
    );
  }

  Future<void> exportAndShareODSheetCSV() async {
    final csvBuffer = StringBuffer();
    csvBuffer.writeln(
      'Reg No,Name,Total Days,Internal OD,External OD,Total OD,Percentage',
    );

    for (final student in students) {
      final reg = student['reg']!;
      final name = student['name']!.contains(',')
          ? '"${student['name']!}"'
          : student['name']!;
      int internalODCount = 0;
      int externalODCount = 0;
      for (final date in filteredDates) {
        if (dateToInternalODs[date]?.contains(reg) ?? false) {
          internalODCount++;
        }
        if (dateToExternalODs[date]?.contains(reg) ?? false) {
          externalODCount++;
        }
      }
      final totalOD = internalODCount + externalODCount;
      final totalDays = filteredDates.length;
      final percentage = totalDays > 0
          ? (totalOD / totalDays * 100).toStringAsFixed(2)
          : '0.00';

      csvBuffer.writeln(
        '$reg,$name,$totalDays,$internalODCount,$externalODCount,$totalOD,$percentage',
      );
    }

    final dir = await getTemporaryDirectory();
    final rangeText = widget.fromDate != null && widget.toDate != null
        ? '${DateFormat('ddMMyy').format(widget.fromDate!)}_${DateFormat('ddMMyy').format(widget.toDate!)}'
        : 'all_dates';
    final file = File('${dir.path}/od_sheet_$rangeText.csv');
    await file.writeAsString(csvBuffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'OD Sheet Report (${widget.fromDate != null ? 'Custom Range' : 'All Dates'})',
    );
  }

  Future<void> exportAndShareSummaryCSV() async {
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Reg No,Name,Total Days,Present,Absent,OD,Percentage');

    for (final student in students) {
      final reg = student['reg']!;
      final name = student['name']!.contains(',')
          ? '"${student['name']!}"'
          : student['name']!;
      final data =
          studentSummary[reg] ??
          {
            'total_days': 0,
            'present': 0,
            'absent': 0,
            'od': 0,
            'percentage': '0.00',
            'name': student['name'],
          };

      csvBuffer.writeln(
        '$reg,$name,${data['total_days']},${data['present']},${data['absent']},${data['od']},${data['percentage']}',
      );
    }

    final dir = await getTemporaryDirectory();
    final rangeText = widget.fromDate != null && widget.toDate != null
        ? '${DateFormat('ddMMyy').format(widget.fromDate!)}_${DateFormat('ddMMyy').format(widget.toDate!)}'
        : 'all_dates';
    final file = File('${dir.path}/summary_$rangeText.csv');
    await file.writeAsString(csvBuffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text:
          'Summary Report (${widget.fromDate != null ? 'Custom Range' : 'All Dates'})',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = widget.fromDate != null && widget.toDate != null
        ? '${DateFormat('dd/MM/yyyy').format(widget.fromDate!)} - ${DateFormat('dd/MM/yyyy').format(widget.toDate!)}'
        : 'All Dates';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance - $rangeText'),
          backgroundColor: primaryColor,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Absent Sheet', icon: Icon(Icons.list)),
              Tab(text: 'OD Sheet', icon: Icon(Icons.directions_run)),
              Tab(text: 'Summary', icon: Icon(Icons.bar_chart)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: loadData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 16),
                    Text('Loading attendance data...'),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [backgroundColor, Colors.white],
                  ),
                ),
                child: TabBarView(
                  children: [
                    _buildAbsentSheetView(rangeText),
                    _buildODSheetView(rangeText),
                    _buildSummaryView(rangeText),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAbsentSheetView(String rangeText) {
    if (filteredDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: textColor.withOpacity(0.3)),
            SizedBox(height: 16),
            Text(
              'No data available for selected range',
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Date Range: $rangeText',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: exportAndShareAbsentSheetCSV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 16),
                      SizedBox(width: 8),
                      Text('Export CSV'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => primaryColor.withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Reg No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...filteredDates.map(
                      (date) => DataColumn(
                        label: Text(
                          DateFormat('dd-MM-yy').format(DateTime.parse(date)),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  rows: students.map((student) {
                    final reg = student['reg']!;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(reg, style: TextStyle(fontFamily: 'monospace')),
                        ),
                        DataCell(Text(student['name']!)),
                        ...filteredDates.map(
                          (date) => DataCell(
                            Builder(
                              builder: (context) {
                                final isAbsent =
                                    dateToAbsents[date]?.contains(reg) ?? false;
                                final isInternalOD =
                                    dateToInternalODs[date]?.contains(reg) ??
                                    false;
                                final isExternalOD =
                                    dateToExternalODs[date]?.contains(reg) ??
                                    false;
                                String status;
                                Color? bg;
                                Color? fg;
                                if (isAbsent) {
                                  status = 'Absent';
                                  bg = warningColor.withOpacity(0.2);
                                  fg = warningColor;
                                } else if (isInternalOD) {
                                  status = 'Internal OD';
                                  bg = accentColor.withOpacity(0.2);
                                  fg = accentColor;
                                } else if (isExternalOD) {
                                  status = 'External OD';
                                  bg = accentColor.withOpacity(0.2);
                                  fg = accentColor;
                                } else {
                                  status = 'Present';
                                  bg = successColor.withOpacity(0.2);
                                  fg = successColor;
                                }
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: fg,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
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
        ),
      ],
    );
  }

  Widget _buildODSheetView(String rangeText) {
    if (filteredDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: textColor.withOpacity(0.3)),
            SizedBox(height: 16),
            Text(
              'No data available for selected range',
              style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.directions_run, color: primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'OD Summary - $rangeText',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: exportAndShareODSheetCSV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 16),
                      SizedBox(width: 8),
                      Text('Export CSV'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard(
                'Total Days',
                filteredDates.length.toString(),
                primaryColor,
              ),
              SizedBox(width: 12),
              _buildStatCard(
                'Students',
                students.length.toString(),
                successColor,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => primaryColor.withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Reg No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Days',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Internal OD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'External OD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total OD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Percentage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: students.map((student) {
                    final reg = student['reg']!;
                    int internalODCount = 0;
                    int externalODCount = 0;
                    for (final date in filteredDates) {
                      if (dateToInternalODs[date]?.contains(reg) ?? false) {
                        internalODCount++;
                      }
                      if (dateToExternalODs[date]?.contains(reg) ?? false) {
                        externalODCount++;
                      }
                    }
                    final totalOD = internalODCount + externalODCount;
                    final totalDays = filteredDates.length;
                    final percentage = totalDays > 0
                        ? (totalOD / totalDays * 100).toStringAsFixed(2)
                        : '0.00';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(reg, style: TextStyle(fontFamily: 'monospace')),
                        ),
                        DataCell(Text(student['name']!)),
                        DataCell(Text(totalDays.toString())),
                        DataCell(Text(internalODCount.toString())),
                        DataCell(Text(externalODCount.toString())),
                        DataCell(Text(totalOD.toString())),
                        DataCell(
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              color: totalOD > 0 ? accentColor : textColor,
                              fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }

  Widget _buildSummaryView(String rangeText) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.analytics, color: primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Summary - $rangeText',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: exportAndShareSummaryCSV,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 16),
                      SizedBox(width: 8),
                      Text('Export CSV'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard(
                'Total Days',
                studentSummary.values.firstOrNull?['total_days']?.toString() ??
                    '0',
                primaryColor,
              ),
              SizedBox(width: 12),
              _buildStatCard(
                'Students',
                students.length.toString(),
                successColor,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => primaryColor.withOpacity(0.1),
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Reg No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Days',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Present',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Absent',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'OD',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Percentage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: students.map((student) {
                    final reg = student['reg']!;
                    final data =
                        studentSummary[reg] ??
                        {
                          'total_days': 0,
                          'present': 0,
                          'absent': 0,
                          'od': 0,
                          'percentage': '0.00',
                        };

                    final percentage =
                        double.tryParse(data['percentage'].toString()) ?? 0;
                    final percentageColor = percentage >= 75
                        ? successColor
                        : percentage >= 50
                        ? primaryColor
                        : warningColor;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(reg, style: TextStyle(fontFamily: 'monospace')),
                        ),
                        DataCell(Text(student['name']!)),
                        DataCell(Text(data['total_days'].toString())),
                        DataCell(Text(data['present'].toString())),
                        DataCell(Text(data['absent'].toString())),
                        DataCell(Text(data['od'].toString())),
                        DataCell(
                          Text(
                            '${data['percentage']}%',
                            style: TextStyle(
                              color: percentageColor,
                              fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
