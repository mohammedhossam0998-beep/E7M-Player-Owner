import 'package:flutter/material.dart';

class StadiumFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onPressed;
  final double size;

  const StadiumFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onPressed,
    this.size = 22,
  });

  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey<bool>(isFavorite),
                size: size,
                color: isFavorite ? Colors.redAccent : darkNavy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}