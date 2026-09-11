import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../controller/onboarding_controller.dart';

class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OnboardingController>();

    return SmoothPageIndicator(
      controller: controller.pageController,
      count: 3,
      effect: ExpandingDotsEffect(
        expansionFactor: 3,
        spacing: 8,
        radius: 10,
        dotHeight: 8,
        dotWidth: 8,
        activeDotColor: const Color(0xff43A047),
        dotColor: Colors.grey.shade300,
      ),
    );
  }
}
