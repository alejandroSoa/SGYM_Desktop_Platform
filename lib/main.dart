import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sgym/screens/diets_screen.dart';
import 'package:sgym/screens/excersices_screen.dart';
import 'package:sgym/screens/foods_screen.dart';
import 'package:sgym/screens/home_screen.dart';
import 'package:sgym/screens/memberships_screen.dart';
import 'package:sgym/screens/reports_screen.dart';
import 'package:sgym/screens/routines_screen.dart';
import 'package:sgym/screens/profile_screen.dart';
import 'package:sgym/screens/users_screen.dart';
import 'screens/notifications_screen.dart';
import 'widgets/custom_top_bar.dart';
import 'widgets/oauth_callback_screen.dart';
import 'config/ScreenConfig.dart';
import 'services/AuthService.dart';
import 'services/UserService.dart';
import 'services/ProfileService.dart';
import 'dart:html' as html;

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
    // Check if current URL contains oauth callback
    final currentUrl = html.window.location.href;
    if (currentUrl.contains('#/oauth-callback') || currentUrl.contains('access_token=')) {
      return OAuthCallbackScreen();
    }
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
    // Redirigir al usuario al proceso de autenticación OAuth
    await AuthService.authenticateWithOAuth();
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

  final List<Screenconfig> viewConfigs = [
    Screenconfig(view: HomeScreen()), 
    Screenconfig(view: const ReportsScreen(), title: 'Reportes', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: RoutinesScreen(), title: 'Rutinas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: ExercisesScreen(), title: 'Ejercicios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const UsersScreen(), title: 'Usuarios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: MembershipsScreen(), title: 'Membresias', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const NotificationsScreen(), title: 'Eventos', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: FoodsScreen(), title: 'Alimentos', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: DietsScreen(), title: 'Dietas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const ProfileScreen(), title: 'Trabajadores', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
  ];

    @override
    void initState() {
      super.initState();
      _loadProfileName();
    }

    Future<void> _loadProfileName() async {
      final profile = await ProfileService.getProfile();
      setState(() {
        profileName = profile?.fullName ?? 'Usuario';
      });
    }

    @override
    Widget build(BuildContext context) {
      final config = viewConfigs[currentIndex];

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Row(
            children: [
              // Sidebar
              if (config.showBottomNav)
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
                      _buildSidebarButton(index: 0, label: 'Inicio', icon: Icons.home),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 1, label: 'Reportes', icon: Icons.report),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 2, label: 'Rutinas', icon: Icons.fitness_center),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 3, label: 'Ejercicios', icon: Icons.sports_gymnastics),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 4, label: 'Usuarios', icon: Icons.people),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 5, label: 'Membresias', icon: Icons.local_offer),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 6, label: 'Eventos', icon: Icons.event),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 7, label: 'Alimentos', icon: Icons.kebab_dining_sharp),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 8, label: 'Dietas', icon: Icons.restaurant_menu),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 9, label: 'Trabajadores', icon: Icons.people),
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

