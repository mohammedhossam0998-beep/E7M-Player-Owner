import 'package:flutter/material.dart';

class AIAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AIAppBar({
    super.key,
    this.onClearChat,
  });

  final VoidCallback? onClearChat;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'E7M AI',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onClearChat,
          icon: const Icon(
            Icons.delete_outline_rounded,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}