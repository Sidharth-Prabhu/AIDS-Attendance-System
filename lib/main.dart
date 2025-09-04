import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      debugPrint('Checking for updates...');
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      debugPrint('Current version: $currentVersion');

      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest',
        ),
      );
      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('Failed to fetch releases: ${response.body}');
        return false;
      }

      final release = jsonDecode(response.body);
      final String latestVersion = release['tag_name'].replaceAll('v', '');
      debugPrint('Latest version: $latestVersion');

      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final latestParts = latestVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) {
          return true;
        } else if (latestParts[i] < currentParts[i]) {
          return false;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Update check error: $e');
      return false;
    }
  }

  static Future<void> openReleasesPage(BuildContext context) async {
    final Uri url = Uri.parse(releasesUrl);
    try {
      // Try external application first
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        debugPrint('Successfully launched $releasesUrl');
      } else {
        // Fallback to in-app web view
        debugPrint('Falling back to platform web view for $releasesUrl');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.platformDefault);
        } else {
          throw 'No suitable app found to open $releasesUrl';
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to open releases page. Please visit $releasesUrl manually.',
          ),
          backgroundColor: warningColor,
          duration: const Duration(seconds: 5),
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
  bool _biometricAuthRequired = false;
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
        _biometricAuthRequired = false;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getInt('last_login') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const authTimeout = 24 * 60 * 60 * 1000;

    if (now - lastLogin > authTimeout) {
      setState(() => _biometricAuthRequired = true);
      final authenticated = await _authenticateUser();
      if (authenticated) {
        await prefs.setInt('last_login', now);
        setState(() {
          _biometricAuthRequired = false;
          _isBiometricChecked = true;
          _authMessage = 'Authenticated successfully';
        });
      } else {
        await FirebaseAuth.instance.signOut();
        await prefs.remove('last_login');
        setState(() {
          _biometricAuthRequired = false;
          _isBiometricChecked = true;
          _authMessage = 'Authentication failed. Please log in again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authMessage), backgroundColor: warningColor),
        );
      }
    } else {
      setState(() {
        _isBiometricChecked = true;
        _biometricAuthRequired = false;
        _authMessage = 'Recent login detected';
      });
    }
  }

  Future<bool> _authenticateUser() async {
    try {
      bool canUseBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isDeviceSupported) {
        setState(() => _authMessage = 'Device does not support authentication');
        return true;
      }

      if (canUseBiometrics) {
        setState(() => _authMessage = 'Please authenticate using biometrics');
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason:
              'Use your fingerprint, face, or device passcode to access the app',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (didAuthenticate) return true;

        setState(() => _authMessage = 'Biometric authentication failed');
        didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please enter your device passcode',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
        return didAuthenticate;
      } else {
        setState(() => _authMessage = 'Please enter your device passcode');
        bool didAuthenticate = await _localAuth.authenticate(
          localizedReason: 'Please enter your device PIN, pattern, or password',
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
        return didAuthenticate;
      }
    } catch (e) {
      setState(() => _authMessage = 'Authentication error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authMessage), backgroundColor: warningColor),
      );
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          letterSpacing: 2,
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
                          prefixIcon: Icon(Icons.email, color: primaryColor),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryColor,
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
                const SizedBox(height: 20),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isUpdateAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    final bool updateAvailable = await UpdateManager.isUpdateAvailable();
    if (mounted) {
      setState(() {
        _isUpdateAvailable = updateAvailable;
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance System'),
        actions: [
          if (_isUpdateAvailable)
            IconButton(
              onPressed: () =>
                  UpdateManager.openReleasesPage(context), // Pass context
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
                    user?.email ?? 'User',
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
                        builder: (_) => const ViewAttendancePage(),
                      ),
                    ),
                  ),
                  // _buildActionCard(
                  //   context,
                  //   icon: Icons.bar_chart,
                  //   title: 'Reports &\nAnalytics',
                  //   color: warningColor,
                  //   onTap: () {},
                  // ),
                  // _buildActionCard(
                  //   context,
                  //   icon: Icons.settings,
                  //   title: 'Settings &\nPreferences',
                  //   color: primaryColor,
                  //   onTap: () {},
                  // ),
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
            colorScheme: const ColorScheme.light(
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
        content: const Text('Attendance submitted successfully!'),
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
        'Present Count: ${presentCount + internalODCount + externalODCount}\n'
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
          content: const Text(
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: accentColor,
                          child: const Row(
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: successColor,
                          child: const Row(
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
                              student['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
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
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => fromDate = picked);
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
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => toDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Attendance Records'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 48,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Attendance Records',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'View and analyze attendance data',
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: useDateRange,
                            onChanged: (value) {
                              setState(() {
                                useDateRange = value ?? false;
                                if (!useDateRange) fromDate = toDate = null;
                              });
                            },
                            activeColor: primaryColor,
                          ),
                          const Text('Use Date Range'),
                        ],
                      ),
                      if (useDateRange) ...[
                        const SizedBox(height: 16),
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
                                    side: const BorderSide(color: primaryColor),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _selectToDate(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: primaryColor),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 8),
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
                          const Padding(
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (useDateRange && (fromDate == null || toDate == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select both from and to dates'),
                        backgroundColor: warningColor,
                      ),
                    );
                    return;
                  }
                  if (useDateRange && fromDate!.isAfter(toDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
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
                child: const Text(
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
      filteredDates = allDates
          .where(
            (date) =>
                date.compareTo(fromStr) >= 0 && date.compareTo(toStr) <= 0,
          )
          .toList();
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

      for (final date in filteredDates) {
        if (dateToAbsents[date]?.contains(reg) ?? false) absentCount++;
      }

      final present = totalDaysInRange - absentCount;
      final percentage = totalDaysInRange > 0
          ? (present / totalDaysInRange * 100).toStringAsFixed(2)
          : '0.00';

      studentSummary[reg] = {
        'name': student['name'],
        'total_days': totalDaysInRange,
        'present': present,
        'absent': absentCount,
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
        ...filteredDates.map(
          (date) => dateToAbsents[date]?.contains(reg) ?? false
              ? 'Absent'
              : 'Present',
        ),
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
        if (dateToInternalODs[date]?.contains(reg) ?? false) internalODCount++;
        if (dateToExternalODs[date]?.contains(reg) ?? false) externalODCount++;
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
    csvBuffer.writeln('Reg No,Name,Total Days,Present,Absent,Percentage');

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
            'percentage': '0.00',
            'name': student['name'],
          };

      csvBuffer.writeln(
        '$reg,$name,${data['total_days']},${data['present']},${data['absent']},${data['percentage']}',
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
          bottom: const TabBar(
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
              onPressed: loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
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
                decoration: const BoxDecoration(
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
            const SizedBox(height: 16),
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
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Date Range: $rangeText',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: exportAndShareAbsentSheetCSV,
                  child: const Row(
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => primaryColor.withOpacity(0.1),
                  ),
                  columns: [
                    const DataColumn(
                      label: Text(
                        'Reg No',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...filteredDates.map(
                      (date) => DataColumn(
                        label: Text(
                          DateFormat('dd-MM-yy').format(DateTime.parse(date)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  rows: students.map((student) {
                    final reg = student['reg']!;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            reg,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        DataCell(Text(student['name']!)),
                        ...filteredDates.map((date) {
                          final isAbsent =
                              dateToAbsents[date]?.contains(reg) ?? false;
                          return DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isAbsent
                                    ? warningColor.withOpacity(0.2)
                                    : successColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isAbsent ? 'Absent' : 'Present',
                                style: TextStyle(
                                  color: isAbsent ? warningColor : successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }),
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
            const SizedBox(height: 16),
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
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.directions_run, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'OD Summary - $rangeText',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: exportAndShareODSheetCSV,
                  child: const Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard(
                'Total Days',
                filteredDates.length.toString(),
                primaryColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Students',
                students.length.toString(),
                successColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => primaryColor.withOpacity(0.1),
                  ),
                  columns: const [
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
                      if (dateToInternalODs[date]?.contains(reg) ?? false)
                        internalODCount++;
                      if (dateToExternalODs[date]?.contains(reg) ?? false)
                        externalODCount++;
                    }
                    final totalOD = internalODCount + externalODCount;
                    final totalDays = filteredDates.length;
                    final percentage = totalDays > 0
                        ? (totalOD / totalDays * 100).toStringAsFixed(2)
                        : '0.00';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            reg,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
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
    if (filteredDates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: textColor.withOpacity(0.3)),
            const SizedBox(height: 16),
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
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Summary - $rangeText',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: exportAndShareSummaryCSV,
                  child: const Row(
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatCard(
                'Total Days',
                studentSummary.values.firstOrNull?['total_days']?.toString() ??
                    '0',
                primaryColor,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Students',
                students.length.toString(),
                successColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) => primaryColor.withOpacity(0.1),
                  ),
                  columns: const [
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
                          'percentage': '0.00',
                          'name': student['name'],
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
                          Text(
                            reg,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        DataCell(Text(student['name']!)),
                        DataCell(Text(data['total_days'].toString())),
                        DataCell(Text(data['present'].toString())),
                        DataCell(Text(data['absent'].toString())),
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
          padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 4),
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
