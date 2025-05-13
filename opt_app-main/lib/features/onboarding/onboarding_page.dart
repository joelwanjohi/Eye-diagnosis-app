import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:opt_app/providers/firebase_provider.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:lottie/lottie.dart';
import 'package:opt_app/services/logger.dart';
import 'package:opt_app/services/navigation.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: screenSize.height,
        width: screenSize.width,
        color: AppColors.white,
        child: Stack(
          children: [
            // Top wave design
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: screenSize.height * 0.4,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // Animation centered in screen
                  SizedBox(
                    height: screenSize.height * 0.4,
                    child: Lottie.asset(
                      AppLottie.intro,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),

                  // Bottom content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to EyeCheck",
                          style: AppTypography().xxlBold.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Eye Diagnosis with AI 😊",
                          style: AppTypography().largeBold.copyWith(
                                color: AppColors.gray[700],
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Get accurate eye diagnoses in seconds with our advanced AI technology",
                          style: AppTypography().baseMedium.copyWith(
                                color: AppColors.gray[600],
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: "Let's go",
                          onPressed: () async {
                            // Get the current user
                            final User? currentUser =
                                ref.read(firebaseProvider).currentUser;

                            if (currentUser != null) {
                              // Store the initial verification status
                              final bool wasVerified =
                                  currentUser.emailVerified;

                              // If already verified, navigate immediately
                              if (wasVerified) {
                                Logs.userKnown();
                                Navigation.navigateToHomePage(context);
                              } else {
                                // If not verified, reload silently then check
                                await currentUser.reload();
                                final refreshedUser =
                                    ref.read(firebaseProvider).currentUser;

                                if (refreshedUser != null &&
                                    refreshedUser.emailVerified) {
                                  Logs.userKnown();
                                  Navigation.navigateToHomePage(context);
                                } else {
                                  Logs.userUnknown();
                                  Navigation.navigateToLoginScreen(context);
                                }
                              }
                            } else {
                              Logs.userUnknown();
                              Navigation.navigateToLoginScreen(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wave clipper for the top decoration
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.8);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    final secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    final secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        color: AppColors.white,
        child: Stack(
          children: [
            // Top curved background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: screenSize.height * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                SizedBox(height: screenSize.height * 0.15),

                // Logo animation
                Lottie.asset(
                  AppLottie.logo,
                  height: screenSize.height * 0.3,
                  width: screenSize.width * 0.8,
                ),

                const Spacer(),

                // Bottom content section
                Container(
                  width: double.infinity, 
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 24), 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      // Keep rounded edges at the top
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "EyeCheck",
                        style: AppTypography().xxlBold.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Welcome to EyeCheck, your AI-powered eye diagnosis assistant",
                        textAlign: TextAlign.center,
                        style: AppTypography().baseSemiBold.copyWith(
                              color: AppColors.gray[700],
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Get Started",
                                style: AppTypography().baseSemiBold.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
