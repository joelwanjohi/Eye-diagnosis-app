import 'package:intl/intl.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:flutter/material.dart';

class DiagnosisHomeCard extends StatelessWidget {
  final SavedDiagnosis diagnosis;
  final bool isLast;
  const DiagnosisHomeCard({
    super.key,
    required this.diagnosis,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DiagnoseDetails(savedDiagnosis: diagnosis),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color.fromARGB(255, 184, 167, 142)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            "d MMM yyyy",
                          ).format(DateTime.parse(diagnosis.date!)),
                          style: AppTypography().largeBold.copyWith(
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (diagnosis.patientName != null &&
                            diagnosis.patientName!.isNotEmpty)
                          Text(
                            "Patient: ${diagnosis.patientName}",
                            style: AppTypography().largeSemiBold.copyWith(
                                  color: Colors.black87,
                                ),
                          ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Diagnoses: ",
                                style: AppTypography().largeSemiBold.copyWith(
                                      color: Colors.black87,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                              TextSpan(
                                text:
                                    "${diagnosis.diagnosisList.map((e) => e.diagnosis!).join(", ")}",
                                style: AppTypography().baseMedium.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Hero(
                    tag: diagnosis.image!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedImageWidget(
                        image: diagnosis.image!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        isSmall: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) Divider(color: AppColors.gray.shade300, thickness: 1.5),
      ],
    );
  }
}
