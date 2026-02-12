import 'package:flutter/material.dart';

import 'package:pixelpad/core/app/main_shell.dart';
import 'package:pixelpad/core/app/splash_screen.dart';
import 'package:pixelpad/features/auth/presentation/screens/login_screen.dart';
import 'package:pixelpad/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:pixelpad/features/auth/presentation/screens/register_guide_screen.dart';
import 'package:pixelpad/features/logs/presentation/screens/logs_screen.dart';
import 'package:pixelpad/features/onboarding/presentation/screens/onboarding_page_four.dart';
import 'package:pixelpad/features/onboarding/presentation/screens/onboarding_page_three.dart';
import 'package:pixelpad/features/onboarding/presentation/screens/onboarding_page_two.dart';
import 'package:pixelpad/features/profile/presentation/screens/onboarding/profile_guide_age_screen.dart';
import 'package:pixelpad/features/profile/presentation/screens/onboarding/profile_guide_gender_screen.dart';
import 'package:pixelpad/features/profile/presentation/screens/onboarding/profile_guide_intro_screen.dart';
import 'package:pixelpad/features/profile/presentation/screens/onboarding/profile_guide_username_screen.dart';
import 'package:pixelpad/features/profile/presentation/screens/profile_edit_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String mainShell = '/main';
  static const String logs = '/logs';
  static const String login = '/login';
  static const String phoneLogin = '/login/phone';
  static const String register = '/register';
  static const String onboardingTwo = '/onboarding/2';
  static const String onboardingThree = '/onboarding/3';
  static const String onboardingFour = '/onboarding/4';
  static const String profileGuideIntro = '/profile/guide/intro';
  static const String profileGuideGender = '/profile/guide/gender';
  static const String profileGuideAge = '/profile/guide/age';
  static const String profileGuideUsername = '/profile/guide/username';
  static const String profileEdit = '/profile/edit';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    mainShell: (_) => const MainShell(),
    logs: (_) => const LogsScreen(),
    login: (_) => const LoginScreen(),
    phoneLogin: (_) => const PhoneLoginScreen(),
    register: (_) => const RegisterGuideScreen(),
    onboardingTwo: (_) => const OnboardingPageTwo(),
    onboardingThree: (_) => const OnboardingPageThree(),
    onboardingFour: (_) => const OnboardingPageFour(),
    profileGuideIntro: (_) => const ProfileGuideIntroScreen(),
    profileGuideGender: (_) => const ProfileGuideGenderScreen(),
    profileGuideAge: (_) => const ProfileGuideAgeScreen(),
    profileGuideUsername: (_) => const ProfileGuideUsernameScreen(),
    profileEdit: (_) => const ProfileEditScreen(),
  };
}
