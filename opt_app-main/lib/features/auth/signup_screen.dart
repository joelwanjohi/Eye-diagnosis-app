import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/providers/displayname_provider.dart';
import 'package:opt_app/providers/email_provider.dart';
import 'package:opt_app/services/firebase_service.dart';
import 'package:opt_app/services/navigation.dart';

import 'package:opt_app/widgets/responsive_layout.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() {
    return SignupScreenState();
  }
}

class SignupScreenState extends ConsumerState<SignupScreen> {
  late TextEditingController displayNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool isSigningUp = false;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    displayNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? Color(0xff121212) : Color(0xfff1f8e9);

    return SafeArea(
      child: Scaffold(
        backgroundColor: surfaceColor,
        body: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: displayNameController,
                  onChanged: (String value) {
                    ref.read(displayNameProvider.notifier).state = value;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_2_rounded),
                    labelText: 'Username',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  onChanged: (String value) {
                    ref.read(emailProvider.notifier).state = value;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'email',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: passwordController,
                  obscureText: isPasswordObscured,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordObscured = !isPasswordObscured;
                        });
                      },
                      icon: isPasswordObscured
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: isConfirmPasswordObscured,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: 'confirm password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordObscured =
                              !isConfirmPasswordObscured;
                        });
                      },
                      icon: isConfirmPasswordObscured
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (!isSigningUp) {
                            setState(() {
                              isSigningUp = true;
                            });
                          }

                          await FirebaseService(ref).signUp(
                            displayNameController.text.trim(),
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            confirmPasswordController.text.trim(),
                            (Object error) {
                              showErrorSnack(context, error);
                              setState(() {
                                isSigningUp = false;
                              });
                            },
                            (String success) {
                              Navigation.navigateToLoginScreen(context);
                              showSuccessSnack(context, success);
                              setState(() {
                                isSigningUp = false;
                              });
                            },
                          );
                        },
                        child: isSigningUp
                            ? const Text('Signing Up...')
                            : const Text('Sign Up'),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigation.navigateToLoginScreen(context);
                  },
                  child: const Text('Back To Login '),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showErrorSnack(BuildContext context, Object onError) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          onError.toString(),
          style: TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode ? Colors.redAccent : Colors.red,
      ),
    );
  }

  void showSuccessSnack(BuildContext context, String onSuccess) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          onSuccess,
          style: TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode ? Colors.greenAccent : Colors.green,
      ),
    );
  }
}
