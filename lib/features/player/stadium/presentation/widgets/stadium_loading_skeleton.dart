import 'package:flutter/material.dart';

class StadiumLoadingSkeleton extends StatefulWidget {
  final int itemCount;

  const StadiumLoadingSkeleton({
    super.key,
    this.itemCount = 4,
  });

  @override
  State<StadiumLoadingSkeleton> createState() =>
      _StadiumLoadingSkeletonState();
}

class _StadiumLoadingSkeletonState
    extends State<StadiumLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 16),
      itemBuilder: (_, __) {
        return FadeTransition(
          opacity: _animation,
          child: const _SkeletonCard(),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFEAEAEA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: _SkeletonBox(
              height: 180,
              width: double.infinity,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const _SkeletonBox(
                  height: 20,
                  width: 190,
                ),

                const SizedBox(height: 10),

                const _SkeletonBox(
                  height: 14,
                  width: 130,
                ),

                const SizedBox(height: 14),

                Row(
                  children: const [
                    _SkeletonBox(
                      height: 28,
                      width: 80,
                    ),
                    SizedBox(width: 8),
                    _SkeletonBox(
                      height: 28,
                      width: 80,
                    ),
                    Spacer(),
                    _SkeletonBox(
                      height: 28,
                      width: 90,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;

  const _SkeletonBox({
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}