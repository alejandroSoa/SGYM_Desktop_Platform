import 'package:flutter/material.dart';
import '../config/ScreenConfig.dart';
import '../screens/home_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/diets_screen.dart';
import '../screens/routines_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';

class RoleConfigService {
  static List<Screenconfig> getScreensForRole(
    int roleId, {
    VoidCallback? onBack,
  }) {
    switch (roleId) {
      case 3: // Trainer - SIN DIETAS
        return [
          Screenconfig(view: const HomeScreen()),
          Screenconfig(view: const AppointmentsScreen()),
          Screenconfig(
            view: RoutinesScreen(showExerciseButton: true, onBack: onBack),
            showTopBar: false,
          ),
          Screenconfig(
            view: const ProfileScreen(),
            showBackButton: true,
            showBottomNav: false,
            showProfileIcon: false,
            showNotificationIcon: false,
          ),
          Screenconfig(
            view: const NotificationsScreen(),
            showBackButton: true,
            showBottomNav: false,
            showProfileIcon: false,
            showNotificationIcon: false,
          ),
        ];

      case 5: // User - TODOS
        return [
          Screenconfig(view: const HomeScreen()),
          Screenconfig(view: const AppointmentsScreen()),
          Screenconfig(
            view: const ProfileScreen(),
            showBackButton: true,
            showBottomNav: false,
            showProfileIcon: false,
            showNotificationIcon: false,
          ),
          Screenconfig(
            view: const NotificationsScreen(),
            showBackButton: true,
            showBottomNav: false,
            showProfileIcon: false,
            showNotificationIcon: false,
          ),
        ];

      case 6: // Nutritionist - SIN RUTINAS
        return [
          Screenconfig(view: const HomeScreen()),
          Screenconfig(view: const AppointmentsScreen()),
          Screenconfig(view: DietsScreen(onBack: onBack), showTopBar: false),
          Screenconfig(
            view: const ProfileScreen(),
            showBackButton: true,
            showBottomNav: false,
            showProfileIcon: false,
            showNotificationIcon: false,
          ),
          Screenconfig(
            view: const NotificationsScreen(),
            showBackButton: true,
            showBottomNav: false,
            showProfileIcon: false,
            showNotificationIcon: false,
          ),
        ];

      default:
        return [
          Screenconfig(view: const HomeScreen()),
          Screenconfig(view: const ProfileScreen(), showBottomNav: false),
        ];
    }
  }

  static List<Map<String, dynamic>> getNavItemsForRole(int roleId) {
    switch (roleId) {
      case 3: // Trainer - SIN DIETAS
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
          {'index': 1, 'label': 'Citas', 'icon': Icons.calendar_today},
          {'index': 2, 'label': 'Rutinas', 'icon': Icons.fitness_center},
        ];

      case 5: // User - TODOS
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
          {'index': 1, 'label': 'Citas', 'icon': Icons.calendar_today},
          {'index': 2, 'label': 'Dietas', 'icon': Icons.restaurant},
          {'index': 3, 'label': 'Rutinas', 'icon': Icons.fitness_center},
        ];

      case 6: // Nutritionist - SIN RUTINAS
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
          {'index': 1, 'label': 'Citas', 'icon': Icons.calendar_today},
          {'index': 2, 'label': 'Dietas', 'icon': Icons.restaurant},
        ];

      default:
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
        ];
    }
  }
}
