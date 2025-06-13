import 'package:flutter/widgets.dart';

class Screenconfig {
  final Widget view;
  final String? title;
  final bool showProfileIcon;
  final bool showNotificationIcon;
  final bool showBackButton;
  final bool showBottomNav;

  Screenconfig({
    required this.view,
    this.title,
    this.showProfileIcon = true,
    this.showNotificationIcon = true,
    this.showBackButton = false,
    this.showBottomNav = true,
  });
}
