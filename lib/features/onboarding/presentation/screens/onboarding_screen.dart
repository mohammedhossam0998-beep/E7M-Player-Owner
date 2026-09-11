import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/onboarding_controller.dart';
import '../../data/onboarding_data.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/page_indicator.dart';
import '../widgets/next_button.dart';
import '../widgets/skip_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final controller =
    context.read<OnboardingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // SKIP
            // ==================================================

            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SkipButton(),
                ],
              ),
            ),

            // ==================================================
            // PAGES
            // ==================================================

            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: OnboardingData.pages.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingCard(
                    item: OnboardingData.pages[index],
                  );
                },
              ),
            ),

            // ==================================================
            // PAGE INDICATOR
            // ==================================================

            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: OnboardingPageIndicator(),
            ),

            // ==================================================
            // NEXT / GET STARTED
            // ==================================================

            const Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                30,
              ),
              child: NextButton(),
            ),
          ],
        ),
      ),
    );
  }
}