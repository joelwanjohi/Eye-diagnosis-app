import 'package:opt_app/features/auth/login_screen.dart';
import 'package:opt_app/features/auth/password_screen.dart';
import 'package:opt_app/features/auth/signup_screen.dart';
import 'package:opt_app/library/opt_app.dart';

class Navigation {
  static void navigateToHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) {
          return const HomePage();
        },
      ),
    );
  }

  static void navigateToLoginScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) {
          return const LoginScreen();
        },
      ),
    );
  }

  static void navigateToSignupScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) {
          return const SignupScreen();
        },
      ),
    );
  }

  static void navigateToPasswordScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) {
          return const PasswordScreen();
        },
      ),
    );
  }
}
