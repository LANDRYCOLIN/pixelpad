import 'package:pixelpad/core/services/log_service.dart';
import 'package:pixelpad/features/profile/data/profile_repository.dart';
import 'package:pixelpad/features/profile/data/user_repository.dart';

class AppDependencies {
  final UserRepository userRepository;
  final ProfileRepository profileRepository;
  final LogService logService;

  AppDependencies({
    UserRepository? userRepository,
    ProfileRepository? profileRepository,
    LogService? logService,
  })  : userRepository = userRepository ?? UserRepository(),
        profileRepository = profileRepository ?? ProfileRepository(),
        logService = logService ?? LogService();
}
