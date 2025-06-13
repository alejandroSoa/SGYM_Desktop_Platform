import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget {
  final String username;
  final String profileImage;
  final String? currentViewTitle;
  final bool showBackButton;
  final bool showProfileIcon;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final bool showNotificationIcon;
  final VoidCallback? onNotificationsTap;

const CustomTopBar({
  super.key,
  required this.username,
  required this.profileImage,
  this.currentViewTitle,
  this.showBackButton = false,
  this.showProfileIcon = true,
  this.showNotificationIcon = true,
  this.onBack,
  this.onProfileTap,
  this.onNotificationsTap,
});

@override
  Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showBackButton
            ? GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(244, 242, 255, 1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Colors.black54),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        if (currentViewTitle != null && showBackButton)
          Text(
            currentViewTitle!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              if (showNotificationIcon)
                GestureDetector(
                  onTap: onNotificationsTap,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(244, 242, 255, 1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_none, color: Colors.black54, size: 22),
                  ),
                ),
              const SizedBox(width: 12),
              showProfileIcon
                  ? GestureDetector(
                      onTap: onProfileTap,
                      child: CircleAvatar(
                        backgroundImage: AssetImage(profileImage),
                        radius: 20,
                      ),
                    )
                  : const SizedBox(width: 35),
            ],
          ),
        ],
      ),
    );
  }
}
