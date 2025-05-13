import 'package:opt_app/library/opt_app.dart';
import 'package:flutter/material.dart';

class DiagnosisCard extends StatelessWidget {
  final Diagnosis diagnosis;
  final int index;
  const DiagnosisCard({
    super.key,
    required this.diagnosis,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 0.5, right: 0.5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Use the same gradient as DiagnosisHomeCard
          gradient: const LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 184, 167, 142)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$index - ${diagnosis.diagnosis}",
              style: AppTypography().extraLargeBold.copyWith(
                    color: Colors.black87, // Match text color
                  ),
              maxLines: 2,
            ),
            const SizedBox(height: 6),
            Text(
              diagnosis.reason!,
              style: AppTypography().baseMedium.copyWith(color: Colors.black54),
              maxLines: 10,
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Symptoms: ",
                    style: AppTypography().largeSemiBold.copyWith(
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  TextSpan(
                    text: "${diagnosis.symptoms.join(", ")}",
                    style: AppTypography().baseMedium.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Ocular Tests: ",
                    style: AppTypography().largeSemiBold.copyWith(
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  TextSpan(
                    text: "${diagnosis.ocularTests.join(", ")}",
                    style: AppTypography().baseMedium.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
