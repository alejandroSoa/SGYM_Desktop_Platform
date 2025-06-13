import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "username": "sofia_fit",
        "event": "El gimnasio exploto",
        "image": "assets/user1.png",
        "time": "hace 2h"
      },
      {
        "username": "coach_luis",
        "event": "te envió una rutina nueva",
        "image": "assets/user2.png",
        "time": "hace 3h"
      },
      {
        "username": "nutri_ana",
        "event": "actualizó tu plan de dieta",
        "image": "assets/user3.png",
        "time": "ayer"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2FF), 
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500, maxWidth: 2000),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(item["image"]!),
                        radius: 25,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: item["username"],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: " ${item["event"]}"),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        item["time"]!,
                        style: const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
