import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/services/firebase_service.dart';
import 'package:opt_app/services/navigation.dart';
import 'package:opt_app/theme/theme.dart';
import 'package:opt_app/widgets/responsive_layout.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() {
    return PasswordScreenState();
  }
}

class PasswordScreenState extends ConsumerState<PasswordScreen> {
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = sIsDark.value; // Check current theme mode
    final surfaceColor =
        isDarkTheme ? cFlexSchemeDark().surface : cFlexSchemeLight().surface;
    final primaryColor =
        isDarkTheme ? cFlexSchemeDark().primary : cFlexSchemeLight().primary;

    return SafeArea(
      child: Scaffold(
        backgroundColor: surfaceColor, // Set background color based on theme
        body: ResponsiveLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email,
                        color: Colors.black), // Email icon color set to black
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color:
                            primaryColor), // Set label text color based on theme
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: primaryColor), // Focused border color
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: primaryColor), // Enabled border color
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          // Reset password via Firebase and show success or error
                          await FirebaseService(ref)
                              .resetPassword(emailController.text.trim(),
                                  // If anything goes wrong:
                                  (Object error) {
                            showErrorSnack(context, error);
                          }, // If everything goes well
                                  (String success) {
                            Navigation.navigateToLoginScreen(context);
                            showSuccessSnack(context, success);
                          });
                        },
                        child: const Text(
                          'Reset Email', // Button text, no loading indicator
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigation.navigateToLoginScreen(context);
                  },
                  child: const Text('Back to login'),
                ),
              ],
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
        backgroundColor: Colors.red, // Set background color for error
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
        backgroundColor: Colors.green, // Set background color for success
      ),
    );
  }
}
