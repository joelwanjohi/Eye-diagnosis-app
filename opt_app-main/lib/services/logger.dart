import 'package:logger/logger.dart';

class Logs {
  static void userUnknown() {
    Logger().w('User is not logged in or verified, going to LoginScreen');
  }

  static void userKnown() {
    Logger().i('User is logged in or verified, going to HomeScreen');
  }

  static void signupComplete() {
    Logger().i('User is created, verification email sent');
  }

  static void signupFailed() {
    Logger().w('User creation failed');
  }

  static void loginComplete() {
    Logger().i('User is logged in');
  }

  static void loginFailed() {
    Logger().w('User login failed');
  }

  static void resetPasswordComplete() {
    Logger().i('Password reset email sent');
  }

  static void resetPasswordFailed() {
    Logger().w('Password reset email failed');
  }
}
