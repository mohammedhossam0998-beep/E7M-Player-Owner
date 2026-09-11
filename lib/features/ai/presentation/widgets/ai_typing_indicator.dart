import 'package:flutter/material.dart';

class AITypingIndicator
    extends StatelessWidget {
  const AITypingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'E7M AI is typing...',
          ),
        ],
      ),
    );
  }
}