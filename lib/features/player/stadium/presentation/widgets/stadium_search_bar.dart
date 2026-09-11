import 'package:flutter/material.dart';

class StadiumSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final String hintText;

  const StadiumSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.hintText = 'Search stadiums...',
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primaryGreen,
                  size: 24,
                ),
                suffixIcon:
                controller != null
                    ? _ClearButton(
                  controller: controller!,
                  onChanged: onChanged,
                )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),

        if (onFilterTap != null) ...[
          const SizedBox(width: 10),

          _FilterButton(
            onTap: onFilterTap!,
          ),
        ],
      ],
    );
  }
}

class _ClearButton extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _ClearButton({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_ClearButton> createState() =>
      _ClearButtonState();
}

class _ClearButtonState
    extends State<_ClearButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: 'Clear',
      onPressed: () {
        widget.controller.clear();
        widget.onChanged?.call('');
      },
      icon: Icon(
        Icons.close_rounded,
        size: 20,
        color: Colors.grey.shade500,
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FilterButton({
    required this.onTap,
  });

  static const Color primaryGreen =
  Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.black,
            size: 23,
          ),
        ),
      ),
    );
  }
}