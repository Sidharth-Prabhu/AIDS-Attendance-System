// main.dart
import 'dart:convert';
import 'dart:io';
import 'package:attendance_system/screens/database_manager_screen.dart';
import 'package:attendance_system/screens/date_summary_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // FCM
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Import the new Student model
import 'models/student.dart';

// Color Scheme
const Color primaryColor = Color(0xFF4361EE);
const Color secondaryColor = Color(0xFF3A0CA3);
const Color accentColor = Color(0xFF7209B7);
const Color successColor = Color(0xFF4CC9F0);
const Color warningColor = Color(0xFFF72585);
const Color backgroundColor = Color(0xFFF8F9FA);
const Color cardColor = Color(0xFFFFFFFF);
const Color textColor = Color(0xFF212529);

// FCM Background Handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM Background: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // FCM: Initialize background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS)
    await messaging.requestPermission();

    // Get FCM token (for Firebase Console testing)
    final token = await messaging.getToken();
    debugPrint('FCM Token: $token');

    // Subscribe to topic (optional)
    await messaging.subscribeToTopic('attendance_updates');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground: ${message.notification?.title}');
    });

    // Handle tap (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Tap: ${message.data}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance System',
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          surface: backgroundColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        textTheme: const TextTheme(
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
          bodyLarge: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class UpdateManager {
  static const String githubOwner = 'Sidharth-Prabhu';
  static const String githubRepo = 'AIDS-Attendance-System';
  static const String releasesUrl =
      'https://github.com/Sidharth-Prabhu/AIDS-Attendance-System/releases';

  static Future<bool> isUpdateAvailable() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest',
        ),
      );
      if (response.statusCode != 200) return false;
      final release = jsonDecode(response.body);
      final String latestVersion = release['tag_name'].replaceAll('v', '');
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final latestParts = latestVersion.split('.').map(int.parse).toList();
      for (int i = 0; i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openReleasesPage(BuildContext context) async {
    final Uri url = Uri.parse(releasesUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open releases. Visit: $releasesUrl'),
          backgroundColor: warningColor,
        ),
      );
    }
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
  String _authMessage = 'Checking authentication...';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isBiometricChecked = true;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getInt('last_login') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const authTimeout = 24 * 60 * 60 * 1000;

    if (now - lastLogin > authTimeout) {
      setState(() {
        _authMessage = 'Biometric authentication required...';
      });
      final authenticated = await _authenticateUser();
      if (authenticated) {
        await prefs.setInt('last_login', now);
        setState(() {
          _isBiometricChecked = true;
          _authMessage = 'Authenticated successfully';
        });
      } else {
        await FirebaseAuth.instance.signOut();
        await prefs.remove('last_login');
        setState(() {
          _isBiometricChecked = true;
          _authMessage = 'Authentication failed. Please log in again.';
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authMessage), backgroundColor: warningColor),
        );
      }
    } else {
      setState(() {
        _isBiometricChecked = true;
        _authMessage = 'Recent login detected';
      });
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      bool canUseBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) return true;

      if (canUseBiometrics) {
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Use fingerprint/face to access',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        if (didAuthenticate) return true;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Enter device PIN/pattern/password',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
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
              const Icon(Icons.fingerprint, size: 64, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                _authMessage,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: primaryColor,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return snapshot.hasData ? const HomeScreen() : const LoginScreen();
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed';
      if (e.code == 'user-not-found') {
        msg = 'No user found';
      } else if (e.code == 'wrong-password') {
        msg = 'Incorrect password';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: warningColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: warningColor),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child:
                Column(
              children: [
                // ... (same UI as before)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'ATTENDANCE SYSTEM',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Smart Attendance Management',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
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
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUpdateAvailable = false;
  String _userDisplayName = 'User'; // Will be updated

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
    _fetchUserName();
  }

  Future<void> _checkForUpdates() async {
    final available = await UpdateManager.isUpdateAvailable();
    if (mounted) setState(() => _isUpdateAvailable = available);
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final email = user.email?.toLowerCase().trim();
    if (email == null) return;

    // Find student with matching email
    final matchedStudent = students.firstWhere(
      (s) => s.email?.toLowerCase().trim() == email,
      orElse: () => Student(regNum: '', name: 'User'), // fallback
    );

    if (mounted) {
      setState(() {
        _userDisplayName = matchedStudent.name;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_login');
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance System'),
        actions: [
          if (_isUpdateAvailable)
            IconButton(
              onPressed: () => UpdateManager.openReleasesPage(context),
              icon: const Icon(Icons.system_update),
              tooltip: 'Update Available',
            ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
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
                  const SizedBox(height: 4),
                  Text(
                    _userDisplayName, // Now shows name from student list
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage student attendance efficiently',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      MaterialPageRoute(builder: (_) => const AttendancePage()),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.visibility,
                    title: 'View\nAttendance',
                    color: accentColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomAttendanceView(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.summarize,
                    title: 'Today\'s\nSummary',
                    color: warningColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DateSummaryScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.storage,
                    title: 'Database\nManager',
                    color: Colors.deepPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DatabaseManagerScreen(),
                      ),
                    ),
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
    BuildContext context,
    {
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
          padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
  Map<String, String> odType = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var student in students) {
      attendanceStatus[student.regNum] = AttendanceStatus.present;
      odType[student.regNum] = '';
    }
    loadAttendance();
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      await loadAttendance();
    }
  }

  void _setOD(String reg, String type) {
    setState(() {
      attendanceStatus[reg] = AttendanceStatus.od;
      odType[reg] = type;
    });
  }

  void _clearOD(String reg) {
    setState(() {
      attendanceStatus[reg] = AttendanceStatus.present;
      odType[reg] = '';
    });
  }

  Future<void> loadAttendance() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final doc = await FirebaseFirestore.instance
        .collection('semester_4')
        .doc(dateStr)
        .get();
    final absents = doc.exists
        ? List<String>.from(doc['absents'] ?? [])
        : <String>[];
    final internalODs = doc.exists
        ? List<String>.from(doc['internal_od'] ?? [])
        : <String>[];
    final externalODs = doc.exists
        ? List<String>.from(doc['external_od'] ?? [])
        : <String>[];

    setState(() {
      for (var student in students) {
        final reg = student.regNum;
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
        .collection('semester_4')
        .doc(dateStr)
        .set({
          'absents': absents,
          'internal_od': internalODs,
          'external_od': externalODs,
        });

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance submitted!'),
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
        'II AIDS-E\n$dateFormatted\nAbsentees: $absentsStr\nPresent Count: $presentCount\nInternal OD: $internalODStr\nExternal OD: $externalODStr\nNo. of Absentees: ${absents.length}';

    final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(message)}';
    final webUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (await canLaunchUrl(Uri.parse(webUrl))) {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp not available'),
          backgroundColor: warningColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected Date:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
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
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final reg = student.regNum;
                      final status = attendanceStatus[reg]!;
                      Color avatarBg, avatarIconColor;
                      IconData avatarIcon;

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
                          color: accentColor,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            children: [
                              Icon(Icons.directions_run, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'External OD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          color: successColor,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Internal OD',
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
                        confirmDismiss: (dir) async {
                          if (dir == DismissDirection.startToEnd) {
                            _setOD(reg, 'external');
                          } else {
                            _setOD(reg, 'internal');
                          }
                          return false;
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
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
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text('Reg: $reg'),
                            trailing: Switch(
                              value: status == AttendanceStatus.absent,
                              onChanged: (v) {
                                setState(() {
                                  if (status == AttendanceStatus.od) {
                                    attendanceStatus[reg] = v
                                        ? AttendanceStatus.absent
                                        : AttendanceStatus.present;
                                    odType[reg] = '';
                                  } else {
                                    attendanceStatus[reg] = v
                                        ? AttendanceStatus.absent
                                        : AttendanceStatus.present;
                                  }
                                });
                              },
                              activeThumbColor: warningColor,
                              inactiveThumbColor: successColor,
                            ),
                            onTap: () {
                              if (status == AttendanceStatus.od) {
                                _clearOD(reg);
                              } else {
                                setState(
                                  () => attendanceStatus[reg] =
                                      status == AttendanceStatus.present
                                          ? AttendanceStatus.absent
                                          : AttendanceStatus.present,
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : submitAttendance,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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

class CustomAttendanceView extends StatefulWidget {
  const CustomAttendanceView({super.key});
  @override
  _CustomAttendanceViewState createState() => _CustomAttendanceViewState();
}

class _CustomAttendanceViewState extends State<CustomAttendanceView> {
  DateTime? fromDate;
  DateTime? toDate;

  List<String> filteredDates = [];
  Map<String, List<String>> dateToAbsents = {},
      dateToInternalODs = {},
      dateToExternalODs = {};
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
        .collection('semester_4')
        .get();
    final allDates = query.docs.map((e) => e.id).toList()..sort();

    if (fromDate != null && toDate != null) {
      final fromStr = DateFormat('yyyy-MM-dd').format(fromDate!);
      final toStr = DateFormat('yyyy-MM-dd').format(toDate!);
      filteredDates =
          allDates.where((d) => d.compareTo(fromStr) >= 0 && d.compareTo(toStr) <= 0).toList();
    } else {
      filteredDates = allDates;
    }

    dateToAbsents.clear();
    dateToInternalODs.clear();
    dateToExternalODs.clear();

    for (var doc in query.docs) {
      if (filteredDates.contains(doc.id)) {
        dateToAbsents[doc.id] = List<String>.from(doc['absents'] ?? []);
        dateToInternalODs[doc.id] = List<String>.from(doc['internal_od'] ?? []);
        dateToExternalODs[doc.id] = List<String>.from(doc['external_od'] ?? []);
      }
    }

    final totalDays = filteredDates.length;
    studentSummary.clear();
    for (final student in students) {
      final reg = student.regNum;
      int absentCount = 0;
      for (final date in filteredDates) {
        if (dateToAbsents[date]?.contains(reg) ?? false) absentCount++;
      }
      final present = totalDays - absentCount;
      final percentage = totalDays > 0
          ? (present / totalDays * 100).toStringAsFixed(2)
          : '0.00';
      studentSummary[reg] = {
        'name': student.name,
        'total_days': totalDays,
        'present': present,
        'absent': absentCount,
        'percentage': percentage,
      };
    }

    setState(() => _isLoading = false);
  }

  Future<void> _showFilterDialog() async {
    DateTime? tempFromDate = fromDate;
    DateTime? tempToDate = toDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter by Date'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempFromDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => tempFromDate = picked);
                          }
                        },
                        child: Text(tempFromDate == null
                            ? 'From'
                            : DateFormat('dd/MM/yy').format(tempFromDate!)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempToDate ?? DateTime.now(),
                            firstDate: tempFromDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => tempToDate = picked);
                          }
                        },
                        child: Text(tempToDate == null
                            ? 'To'
                            : DateFormat('dd/MM/yy').format(tempToDate!)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      fromDate = tempFromDate;
                      toDate = tempToDate;
                    });
                    loadData();
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // exportAndShare* methods – updated to use `student.regNum`, `student.name`
  Future<void> exportAndShareAbsentSheetCSV() async {
    final csv = StringBuffer();
    csv.writeln(
      [
        'Reg No',
        'Name',
        ...filteredDates.map(
          (d) => DateFormat('dd-MM-yyyy').format(DateTime.parse(d)),
        ),
      ].join(','),
    );
    for (final student in students) {
      final reg = student.regNum;
      final name = student.name.contains(',')
          ? '"${student.name}"'
          : student.name;
      final row = [
        reg,
        name,
        ...filteredDates.map(
          (d) =>
              dateToAbsents[d]?.contains(reg) ?? false ? 'Absent' : 'Present',
        ),
      ];
      csv.writeln(row.join(','));
    }
    final file = File(
      '${(await getTemporaryDirectory()).path}/attendance_sheet.csv',
    );
    await file.writeAsString(csv.toString());
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> exportAndShareODSheetCSV() async {
    final csv = StringBuffer();
    csv.writeln(
      [
        'Reg No',
        'Name',
        ...filteredDates.map(
          (d) => DateFormat('dd-MM-yyyy').format(DateTime.parse(d)),
        ),
      ].join(','),
    );
    for (final student in students) {
      final reg = student.regNum;
      final name = student.name.contains(',')
          ? '"${student.name}"'
          : student.name;
      final row = [
        reg,
        name,
        ...filteredDates.map((d) {
          if (dateToInternalODs[d]?.contains(reg) ?? false) {
            return 'Internal OD';
          } else if (dateToExternalODs[d]?.contains(reg) ?? false) {
            return 'External OD';
          } else {
            return '-';
          }
        }),
      ];
      csv.writeln(row.join(','));
    }
    final file = File('${(await getTemporaryDirectory()).path}/od_sheet.csv');
    await file.writeAsString(csv.toString());
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> exportAndShareSummaryCSV() async {
    final csv = StringBuffer();
    csv.writeln(
      [
        'Reg No',
        'Name',
        'Total Days',
        'Present',
        'Absent',
        'Percentage',
      ].join(','),
    );
    studentSummary.forEach((reg, summary) {
      final name = summary['name'].contains(',')
          ? '"${summary['name']}"'
          : summary['name'];
      final row = [
        reg,
        name,
        summary['total_days'],
        summary['present'],
        summary['absent'],
        summary['percentage'],
      ];
      csv.writeln(row.join(','));
    });

    final file = File(
      '${(await getTemporaryDirectory()).path}/attendance_summary.csv',
    );
    await file.writeAsString(csv.toString());
    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Attendance - ${fromDate != null ? '${DateFormat('dd/MM').format(fromDate!)} - ${DateFormat('dd/MM').format(toDate!)}' : 'All Dates'}'
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: _showFilterDialog,
            ),
            IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
            Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    switch (tabController.index) {
                      case 0:
                        exportAndShareAbsentSheetCSV();
                        break;
                      case 1:
                        exportAndShareODSheetCSV();
                        break;
                      case 2:
                        exportAndShareSummaryCSV();
                        break;
                    }
                  },
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Absent Sheet'),
              Tab(text: 'OD Sheet'),
              Tab(text: 'Summary'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAbsentSheet(),
                  _buildODSheet(),
                  _buildSummarySheet(),
                ],
              ),
      ),
    );
  }

  Widget _buildAbsentSheet() {
    if (filteredDates.isEmpty) return const Center(child: Text("No records"));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Reg No')),
          const DataColumn(label: Text('Name')),
          ...filteredDates.map(
            (d) => DataColumn(
              label: Text(DateFormat('dd/MM').format(DateTime.parse(d))),
            ),
          ),
        ],
        rows: students.map((student) {
          return DataRow(
            cells: [
              DataCell(
                Text(student.regNum.substring(student.regNum.length - 3)),
              ),
              DataCell(Text(student.name)),
              ...filteredDates.map((d) {
                final isAbsent =
                    dateToAbsents[d]?.contains(student.regNum) ?? false;
                return DataCell(Text(isAbsent ? 'A' : 'P'));
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildODSheet() {
    if (filteredDates.isEmpty) return const Center(child: Text("No records"));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Reg No')),
          const DataColumn(label: Text('Name')),
          ...filteredDates.map(
            (d) => DataColumn(
              label: Text(DateFormat('dd/MM').format(DateTime.parse(d))),
            ),
          ),
        ],
        rows: students.map((student) {
          return DataRow(
            cells: [
              DataCell(
                Text(student.regNum.substring(student.regNum.length - 3)),
              ),
              DataCell(Text(student.name)),
              ...filteredDates.map((d) {
                final isInternal =
                    dateToInternalODs[d]?.contains(student.regNum) ?? false;
                final isExternal =
                    dateToExternalODs[d]?.contains(student.regNum) ?? false;
                String status = '-';
                if (isInternal) status = 'IOD';
                if (isExternal) status = 'EOD';
                return DataCell(Text(status));
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummarySheet() {
    final summaryList = studentSummary.entries.toList();
    if (summaryList.isEmpty) return const Center(child: Text("No records"));

    summaryList.sort(
      (a, b) => a.value['name'].toLowerCase().compareTo(
        b.value['name'].toLowerCase(),
      ),
    );

    return ListView.builder(
      itemCount: summaryList.length,
      itemBuilder: (context, index) {
        final entry = summaryList[index];
        final reg = entry.key;
        final summary = entry.value;
        final percentage = double.parse(summary['percentage']);
        final cardColor = percentage < 75 ? Colors.red.withOpacity(0.1) : null;

        return Card(
          color: cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(summary['name']),
            subtitle: Text('Reg: $reg'),
            trailing: Text('${summary['percentage']}%'),
            onTap: () {
              final absentDates = <String>[];
              for (final date in filteredDates) {
                if (dateToAbsents[date]?.contains(reg) ?? false) {
                  absentDates.add(DateFormat('dd/MM').format(DateTime.parse(date)));
                }
              }
              final absentDatesString = absentDates.isEmpty ? 'None' : absentDates.join(', ');

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(summary['name']),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Days: ${summary['total_days']}'),
                        Text('Present: ${summary['present']}'),
                        Text('Absent: ${summary['absent']}'),
                        Text('Percentage: ${summary['percentage']}%'),
                        const SizedBox(height: 16),
                        const Text('Absent Dates:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(absentDatesString),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}