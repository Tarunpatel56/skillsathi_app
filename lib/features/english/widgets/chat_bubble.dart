import 'package:flutter/material.dart';

/// Chat bubble widget for messages.
class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
        bottom: 8,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? const Color(0xFF4A90D9)
                : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser
                ? null
                : Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (timestamp != null) ...[
                const SizedBox(height: 4),
                Text(
                  timestamp!,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
