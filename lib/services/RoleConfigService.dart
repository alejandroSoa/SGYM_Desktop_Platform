import 'package:flutter/material.dart';
import 'package:sgym/screens/nutrisionist_appointments_screen.dart';
import 'package:sgym/screens/schedules_screen.dart';
import 'package:sgym/screens/pending_stations_screen.dart';
import 'package:sgym/screens/screens_screen.dart';
import 'package:sgym/screens/trainer_appointments_screen.dart';
import '../config/ScreenConfig.dart';
import '../screens/home_screen.dart';
import '../screens/diets_screen.dart';
import '../screens/routines_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/users_screen.dart';
import '../screens/excersices_screen.dart';
import '../screens/memberships_screen.dart';
import '../screens/promotions_screen.dart';
import '../screens/foods_screen.dart';

class RoleConfigService {
  static List<Screenconfig> getScreensForRole(
    int roleId, {
    VoidCallback? onBack,
  }) {
    switch (roleId) {
      case 1: // Admin - TODO
        return [
          Screenconfig(view: const HomeScreen()),
          Screenconfig(view: const ReportsScreen(), title: 'Reportes', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: RoutinesScreen(), title: 'Rutinas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: ExercisesScreen(), title: 'Ejercicios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: const UsersScreen(), title: 'Usuarios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: MembershipsScreen(), title: 'Membresias', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: PromotionsScreen(), title: 'Promociones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: FoodsScreen(), title: 'Alimentos', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: DietsScreen(), title: 'Dietas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: SchedulesScreen(), title: 'Horarios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: StationsScreen(), title: 'Peticiones en estaciones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: PendingStationsScreen(), title: 'Estaciones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false)
        ];
      case 2: // Staff - TODO menos trabajadores
        return [
          Screenconfig(view: const HomeScreen()),
          Screenconfig(view: const ReportsScreen(), title: 'Reportes', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: RoutinesScreen(), title: 'Rutinas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: ExercisesScreen(), title: 'Ejercicios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: const UsersScreen(), title: 'Usuarios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: MembershipsScreen(), title: 'Membresias', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: PromotionsScreen(), title: 'Promociones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: FoodsScreen(), title: 'Alimentos', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: DietsScreen(), title: 'Dietas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: PendingStationsScreen(), title: 'Estaciones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false)
        ];
      case 3: // Solo rutinas y ejercicios
        return [
          Screenconfig(view: RoutinesScreen(), title: 'Rutinas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: ExercisesScreen(), title: 'Ejercicios', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: TrainerAppointmentsScreen(), title: 'Citas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
        ];
      case 4: // Membresias, promociones y notificaciones
        return [
          Screenconfig(view: MembershipsScreen(), title: 'Membresias', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: PromotionsScreen(), title: 'Promociones', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
        ];
      case 6: // Solo alimentos y dietas
        return [
          Screenconfig(view: FoodsScreen(), title: 'Alimentos', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: DietsScreen(), title: 'Dietas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
          Screenconfig(view: NutritionistAppointmentsScreen(), title: 'Citas', showBackButton: true, showProfileIcon: false, showNotificationIcon: false),
        ];
      default:
        return [
          Screenconfig(view: const HomeScreen()),
        ];
    }
  }

  static List<Map<String, dynamic>> getNavItemsForRole(int roleId) {
    switch (roleId) {
      case 1: // Admin - TODO
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
          {'index': 1, 'label': 'Reportes', 'icon': Icons.report},
          {'index': 2, 'label': 'Rutinas', 'icon': Icons.fitness_center},
          {'index': 3, 'label': 'Ejercicios', 'icon': Icons.sports_gymnastics},
          {'index': 4, 'label': 'Usuarios', 'icon': Icons.people},
          {'index': 5, 'label': 'Membresias', 'icon': Icons.local_offer},
          {'index': 6, 'label': 'Promociones', 'icon': Icons.local_offer},
          {'index': 7, 'label': 'Alimentos', 'icon': Icons.kebab_dining_sharp},
          {'index': 8, 'label': 'Dietas', 'icon': Icons.restaurant_menu},
          {'index': 9, 'label': 'Horarios', 'icon': Icons.schedule},
          {'index': 10, 'label': 'Estaciones', 'icon': Icons.location_on},
          {'index': 11, 'label': 'Peticiones en estaciones', 'icon': Icons.pending_actions},
        ];
      case 2:
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
          {'index': 1, 'label': 'Reportes', 'icon': Icons.report},
          {'index': 2, 'label': 'Rutinas', 'icon': Icons.fitness_center},
          {'index': 3, 'label': 'Ejercicios', 'icon': Icons.sports_gymnastics},
          {'index': 4, 'label': 'Usuarios', 'icon': Icons.people},
          {'index': 5, 'label': 'Membresias', 'icon': Icons.local_offer},
          {'index': 6, 'label': 'Promociones', 'icon': Icons.local_offer},
          {'index': 7, 'label': 'Alimentos', 'icon': Icons.kebab_dining_sharp},
          {'index': 8, 'label': 'Dietas', 'icon': Icons.restaurant_menu},
          {'index': 9, 'label': 'Estaciones', 'icon': Icons.location_on},
        ];
      case 3: // Solo rutinas y ejercicios
        return [
          {'index': 0, 'label': 'Rutinas', 'icon': Icons.fitness_center},
          {'index': 1, 'label': 'Ejercicios', 'icon': Icons.sports_gymnastics},
          {'index': 2, 'label': 'Citas', 'icon': Icons.calendar_today},
        ];
      case 4: // Membresias, promociones y notificaciones
        return [
          {'index': 0, 'label': 'Membresias', 'icon': Icons.local_offer},
          {'index': 1, 'label': 'Promociones', 'icon': Icons.local_offer},
        ];
      case 6: // Solo alimentos y dietas
        return [
          {'index': 0, 'label': 'Alimentos', 'icon': Icons.kebab_dining_sharp},
          {'index': 1, 'label': 'Dietas', 'icon': Icons.restaurant_menu},
          {'index': 2, 'label': 'Citas', 'icon': Icons.calendar_today},
        ];
      default:
        return [
          {'index': 0, 'label': 'Inicio', 'icon': Icons.home},
        ];
    }
  }
}
