import '../models/onboarding_model.dart';

class OnboardingData {
  static const List<OnboardingModel> pages = [
    OnboardingModel(
      image: "assets/images/onboarding/onboarding_1.png",
      titleKey: "onboarding_title_1",
      descriptionKey: "onboarding_desc_1",
    ),
    OnboardingModel(
      image: "assets/images/onboarding/onboarding_2.png",
      titleKey: "onboarding_title_2",
      descriptionKey: "onboarding_desc_2",
    ),
    OnboardingModel(
      image: "assets/images/onboarding/onboarding_3.png",
      titleKey: "onboarding_title_3",
      descriptionKey: "onboarding_desc_3",
    ),
  ];
}
