import 'package:flutter/material.dart';
import 'package:sgym/screens/diets_screen.dart';
import 'package:sgym/screens/home_screen.dart';
import 'package:sgym/screens/appointments_screen.dart';
import 'package:sgym/screens/routines_screen.dart';
import 'package:sgym/screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'widgets/custom_top_bar.dart';
import 'config/ScreenConfig.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainLayout extends StatefulWidget {
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Screenconfig> viewConfigs = [
    Screenconfig(view: HomeScreen()), 
    Screenconfig(view: const ReportsScreen(), title: 'Reportes', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const DietsScreen(), title: 'Dietas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const RoutinesScreen(), title: 'Rutinas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
    Screenconfig(view: const ProfileScreen(), title: 'Suscripciones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false, showBottomNav: false),
    Screenconfig(view: const NotificationsScreen(), title: 'Eventos', showBackButton: true, showProfileIcon: false, showNotificationIcon: false, showBottomNav: false),
    Screenconfig(view: const ProfileScreen(), title: 'Trabajadores', showBackButton: true, showProfileIcon: false, showNotificationIcon: false, showBottomNav: false),
  ];

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
                      _buildSidebarButton(index: 1, label: 'Reportes', icon: Icons.calendar_today),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 2, label: 'Dietas', icon: Icons.restaurant),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 3, label: 'Rutinas', icon: Icons.fitness_center),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 4, label: 'Ofertas', icon: Icons.local_offer),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 5, label: 'Eventos', icon: Icons.event),
                      const SizedBox(height: 10),
                      _buildSidebarButton(index: 6, label: 'Trabajadores', icon: Icons.people),
                    ],
                  ),
                ),

              // Contenido principal
              Expanded(
                child: Column(
                  children: [
                    CustomTopBar(
                      username: 'Cholico',
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

