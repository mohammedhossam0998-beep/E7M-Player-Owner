import 'package:flutter/material.dart';

import '../../domain/entities/ai_message_entity.dart';

class AIChatBubble extends StatelessWidget {
  const AIChatBubble({
    super.key,
    required this.message,
  });

  final AIMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final isUser =
        message.role == AIMessageRole.user;

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xff7CC000)
              : const Color(0xff1E1446),
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : Colors.white,
          ),
        ),
      ),
    );
  }
}