import 'package:shared_preferences/shared_preferences.dart';

class OnBoardServiceSharedPrefs {
  static const String _onboardingCompleteKey = 'onboardingComplete';

  // Save onboarding status as complete
  static Future<void> setOnboardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  // Retrieve onboarding status
  static Future<bool> hasCompletedOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }
}
