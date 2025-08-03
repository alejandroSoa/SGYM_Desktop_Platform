import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/custom_top_bar.dart';
import 'config/ScreenConfig.dart';
import 'services/AuthService.dart';
import 'services/UserService.dart';
import 'services/ProfileService.dart';
import 'services/RoleConfigService.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Could not load .env file: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _getInitialScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getInitialScreen() {
    // Solo desktop: siempre AuthCheckScreen
    return AuthCheckScreen();
  }
}

class AuthCheckScreen extends StatefulWidget {
  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool isLoading = true;
  bool hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await UserService.getToken();
      print('🔍 Checking auth status - Token: ${token != null ? "exists" : "null"}');
      setState(() {
        hasToken = token != null && token.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        hasToken = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    print('🔍 AuthCheckScreen - hasToken: $hasToken');
    return hasToken ? MainLayout() : OAuthRedirectScreen();
  }
}

class OAuthRedirectScreen extends StatefulWidget {
  @override
  _OAuthRedirectScreenState createState() => _OAuthRedirectScreenState();
}

class _OAuthRedirectScreenState extends State<OAuthRedirectScreen> {
  @override
  void initState() {
    super.initState();
    _redirectToOAuth();
  }

  Future<void> _redirectToOAuth() async {
    try {
      final result = await AuthService.authenticateWithOAuth(context);
      if (result && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainLayout()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de autenticación: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}


class MainLayout extends StatefulWidget {
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;
  String? profileName;
  int? userRoleId;
  List<Screenconfig> viewConfigs = [];
  List<Map<String, dynamic>> navItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    final user = await UserService.getUser();
    final profile = await ProfileService.fetchProfile();
    final roleId = user != null ? (user['roleId'] ?? user['role_id'] ?? 1) : 1;
    setState(() {
      print('🔍 User data loaded - Profile: ${profile?.fullName}, Role ID: $roleId');
      profileName = profile?.fullName ?? (profile != null ? profile.fullName : 'Usuario');
      userRoleId = roleId;
      viewConfigs = RoleConfigService.getScreensForRole(roleId);
      navItems = RoleConfigService.getNavItemsForRole(roleId);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (viewConfigs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay pantallas disponibles para este rol.')),
      );
    }
    final config = viewConfigs[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 300,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (final item in navItems) ...[
                    _buildSidebarButton(
                      index: item['index'],
                      label: item['label'],
                      icon: item['icon'],
                    ),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: Column(
                children: [
                  CustomTopBar(
                    username: profileName ?? 'Usuario',
                    profileImage: 'assets/profile.png',
                    currentViewTitle: config.title,
                    showBackButton: config.showBackButton,
                    showProfileIcon: config.showProfileIcon,
                    showNotificationIcon: config.showNotificationIcon,
                    onBack: () => setState(() => currentIndex = 0),
                    onProfileTap: () => setState(() => currentIndex = 4),
                    onNotificationsTap: () => setState(() => currentIndex = 5),
                  ),
                  Expanded(child: config.view),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

