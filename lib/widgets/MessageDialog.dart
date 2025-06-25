import 'package:flutter/material.dart';

enum MessageType {
  success,
  error,
  info,
  warning
}

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final MessageType type;
  final VoidCallback? onDismiss;
  final List<Widget>? actions;

  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = MessageType.info,
    this.onDismiss,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getColor(),
              ),
            ),
            const SizedBox(height: 12),
            // Message body
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Align(
              alignment: Alignment.centerRight,
              child: actions != null 
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                )
                : TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onDismiss != null) {
                      onDismiss!();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _getColor(),
                  ),
                  child: const Text('Aceptar'),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case MessageType.success:
        return Colors.green;
      case MessageType.error:
        return Colors.red;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.info:
      default:
        return const Color(0xFF755FE3); // Your app's primary color
    }
  }

  // Static method for easy showing of message
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    MessageType type = MessageType.info,
    VoidCallback? onDismiss,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Translucent background
      builder: (context) => MessageDialog(
        title: title,
        message: message,
        type: type,
        onDismiss: onDismiss,
        actions: actions,
      ),
    );
  }
}