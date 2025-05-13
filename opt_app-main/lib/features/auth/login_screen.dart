import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Importing Material for ThemeData
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/providers/email_provider.dart';
import 'package:opt_app/services/firebase_service.dart';
import 'package:opt_app/services/navigation.dart';
import 'package:opt_app/theme/theme.dart'; // Assuming theme contains your surface color definitions
import 'package:opt_app/widgets/responsive_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode (Light or Dark)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Select surface color based on the theme
    final Color surfaceColor = isDarkMode
        ? cFlexSchemeDark().surface // Dark theme surface color
        : cFlexSchemeLight().surface; // Light theme surface color

    return SafeArea(
      child: Scaffold(
        body: ResponsiveLayout(
          child: Container(
            color: surfaceColor, // Apply the selected surface color here
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: emailController,
                    onChanged: (String email) {
                      final String trimmedEmail = email.trim();
                      ref.read(emailProvider.notifier).state = trimmedEmail;
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
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigation.navigateToSignupScreen(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300], // Subtle grey background
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    12.0), // Padding to make it more button-like
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  50.0), // Rounded corners
                            ),
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.black), // Text color
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            // Log in user. Show snackbar on success or error.
                            await FirebaseService(ref).logIn(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                // If anything goes wrong:
                                (Object error) {
                              showErrorSnack(context, error);
                            },
                                // If everything goes well:
                                (String success) {
                              Navigation.navigateToHomePage(context);
                              showSuccessSnack(context, success);
                            });
                          },
                          child: const Text(
                            'Login',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigation.navigateToPasswordScreen(context);
                        },
                        child: const Text('Forgot Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showErrorSnack(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString(),
          style: TextStyle(
            color: Colors
                .white, // Ensure the text is white or another contrasting color
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red, // Background color for error
      ),
    );
  }

  void showSuccessSnack(BuildContext context, String success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success,
          style: TextStyle(
            color: Colors
                .white, // Ensure the text is white or another contrasting color
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green, // Background color for success
      ),
    );
  }
}
