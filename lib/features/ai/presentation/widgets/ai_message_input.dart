import 'package:flutter/material.dart';

class AIMessageInput extends StatelessWidget {
  const AIMessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;

  final VoidCallback onSend;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 6,
                decoration:
                InputDecoration(
                  hintText:
                  'Ask E7M AI...',
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onSend,
              icon: const Icon(
                Icons.send_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}