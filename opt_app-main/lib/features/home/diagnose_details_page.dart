// import 'package:intl/intl.dart';
// import 'package:opt_app/components/cards/diagnosis_card.dart';
// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';

// class DiagnoseDetails extends StatefulWidget {
//   final SavedDiagnosis savedDiagnosis;
//   const DiagnoseDetails({super.key, required this.savedDiagnosis});

//   @override
//   State<DiagnoseDetails> createState() => _DiagnoseDetailsState();
// }

// class _DiagnoseDetailsState extends State<DiagnoseDetails> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppAppbar(
//           hasLeading: true,
//           actions: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.gray.shade100,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
//                   child: Center(
//                     child: Text("⚡️by Gemini AI",
//                         style: AppTypography().baseMedium.copyWith(
//                               color: AppColors.black,
//                             )),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//         body: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Hero(
//                 tag: widget.savedDiagnosis.image!,
//                 child: SizedBox(
//                     height: 200,
//                     width: double.infinity,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(14),
//                       child: CachedImageWidget(
//                         image: widget.savedDiagnosis.image!,
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.fill,
//                       ),
//                     )),
//               ),
//               const SizedBox(
//                 height: 12,
//               ),
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: "Date: ",
//                       style: AppTypography().largeSemiBold.copyWith(
//                             color: AppColors.black,
//                           ),
//                     ),
//                     TextSpan(
//                       text: DateFormat("dd/MM/yyy")
//                           .format(DateTime.parse(widget.savedDiagnosis.date!)),
//                       style: AppTypography().baseMedium.copyWith(color: AppColors.black),
//                     ),
//                   ],
//                 ),
//                 maxLines: 2,
//                 textAlign: TextAlign.right,
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               Text(
//                 "Tentative diagnosis for patient:",
//                 style: AppTypography().xxlBold,
//                 maxLines: 2,
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: widget.savedDiagnosis.diagnosisList.toList().map((diagnosis) {
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: DiagnosisCard(
//                       diagnosis: diagnosis,
//                       index: widget.savedDiagnosis.diagnosisList.toList().indexOf(diagnosis) + 1,
//                     ),
//                   );
//                 }).toList(),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 0, bottom: 30),
//                 child: GestureDetector(
//                   onTap: () {
//                     diagnosesBox
//                         .delete(
//                       widget.savedDiagnosis.id,
//                     )
//                         .then((value) {
//                       Navigator.pop(context);
//                     });
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     height: 56,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                     ),
//                     decoration: ShapeDecoration(
//                       color: AppColors.red.shade100,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Delete",
//                         textAlign: TextAlign.center,
//                         style: AppTypography().largeSemiBold.copyWith(color: AppColors.red),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ])));
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:opt_app/components/cards/diagnosis_card.dart';
// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';

// class DiagnoseDetails extends StatefulWidget {
//   final SavedDiagnosis savedDiagnosis;
//   const DiagnoseDetails({super.key, required this.savedDiagnosis});

//   @override
//   State<DiagnoseDetails> createState() => _DiagnoseDetailsState();
// }

// class _DiagnoseDetailsState extends State<DiagnoseDetails> {
//   late Box<SavedDiagnosis> diagnosesBox;
//   bool isDeleting = false;

//   @override
//   void initState() {
//     super.initState();
//     diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
//   }

//   Future<void> _deleteDiagnosis() async {
//     if (isDeleting) return; // Prevent multiple delete attempts

//     setState(() {
//       isDeleting = true;
//     });

//     try {
//       await diagnosesBox.delete(widget.savedDiagnosis.id);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Diagnosis deleted successfully'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to delete diagnosis: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isDeleting = false;
//         });
//       }
//     }
//   }

//   Future<bool> _confirmDelete() async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Diagnosis'),
//         content: const Text('Are you sure you want to delete this diagnosis?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.red,
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     return result ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppAppbar(
//         hasLeading: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.gray.shade100,
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: Padding(
//                 padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
//                 child: Center(
//                   child: Text(
//                     "⚡️by Gemini AI",
//                     style: AppTypography().baseMedium.copyWith(
//                           color: AppColors.black,
//                         ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (widget.savedDiagnosis.image != null)
//               Hero(
//                 tag: widget.savedDiagnosis.image!,
//                 child: SizedBox(
//                   height: 200,
//                   width: double.infinity,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(14),
//                     child: CachedImageWidget(
//                       image: widget.savedDiagnosis.image!,
//                       height: 200,
//                       width: double.infinity,
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 12),
//             RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: "Date: ",
//                     style: AppTypography().largeSemiBold.copyWith(
//                           color: AppColors.black,
//                         ),
//                   ),
//                   TextSpan(
//                     text: widget.savedDiagnosis.date != null
//                         ? DateFormat("dd/MM/yyy").format(
//                             DateTime.parse(widget.savedDiagnosis.date!),
//                           )
//                         : 'N/A',
//                     style: AppTypography().baseMedium.copyWith(
//                           color: AppColors.black,
//                         ),
//                   ),
//                 ],
//               ),
//               maxLines: 2,
//               textAlign: TextAlign.right,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Tentative diagnosis for patient:",
//               style: AppTypography().xxlBold,
//               maxLines: 2,
//             ),
//             const SizedBox(height: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: widget.savedDiagnosis.diagnosisList.toList().map((diagnosis) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 12),
//                   child: DiagnosisCard(
//                     diagnosis: diagnosis,
//                     index: widget.savedDiagnosis.diagnosisList.toList().indexOf(diagnosis) + 1,
//                   ),
//                 );
//               }).toList(),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 0, bottom: 30),
//               child: GestureDetector(
//                 onTap: () async {
//                   if (await _confirmDelete()) {
//                     await _deleteDiagnosis();
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 56,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   decoration: ShapeDecoration(
//                     color: AppColors.red.shade100,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: Center(
//                     child: isDeleting
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
//                             ),
//                           )
//                         : Text(
//                             "Delete",
//                             textAlign: TextAlign.center,
//                             style: AppTypography().largeSemiBold.copyWith(
//                                   color: AppColors.red,
//                                 ),
//                           ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opt_app/components/cards/diagnosis_card.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:opt_app/services/SyncServiceProvider.dart';


class DiagnoseDetails extends ConsumerStatefulWidget {
  final SavedDiagnosis savedDiagnosis;
  const DiagnoseDetails({super.key, required this.savedDiagnosis});

  @override
  ConsumerState<DiagnoseDetails> createState() => _DiagnoseDetailsState();
}

class _DiagnoseDetailsState extends ConsumerState<DiagnoseDetails> {
  late Box<SavedDiagnosis> diagnosesBox;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
  }

  Future<void> _deleteDiagnosis() async {
    if (isDeleting) return;

    setState(() {
      isDeleting = true;
    });

    try {
      // Use the sync service to delete from both Hive and Firebase
      final syncService = ref.read(diagnosisSyncServiceProvider);
      await syncService.deleteDiagnosis(widget.savedDiagnosis.id!);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete diagnosis: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(
        hasLeading: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray.shade100,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 12, vertical: 8),
                child: Center(
                  child: Text(
                    "⚡️Results",
                    style: AppTypography().baseMedium.copyWith(
                          color: AppColors.black,
                        ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.savedDiagnosis.image != null)
              Hero(
                tag: widget.savedDiagnosis.image!,
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedImageWidget(
                      image: widget.savedDiagnosis.image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),
            // Display patient details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Patient: ${widget.savedDiagnosis.patientName ?? 'N/A'}",
                    style: AppTypography().baseSemiBold,
                  ),
                  Text(
                    "Phone: ${widget.savedDiagnosis.patientPhone ?? 'N/A'}",
                    style: AppTypography().baseMedium,
                  ),
                  Text(
                    "Email: ${widget.savedDiagnosis.patientEmail ?? 'N/A'}",
                    style: AppTypography().baseMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Date: ",
                    style: AppTypography().largeSemiBold.copyWith(
                          color: AppColors.black,
                        ),
                  ),
                  TextSpan(
                    text: widget.savedDiagnosis.date != null
                        ? DateFormat("dd/MM/yyy").format(
                            DateTime.parse(widget.savedDiagnosis.date!),
                          )
                        : 'N/A',
                    style: AppTypography().baseMedium.copyWith(
                          color: AppColors.black,
                        ),
                  ),
                ],
              ),
              maxLines: 2,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              "Tentative diagnosis for patient:",
              style: AppTypography().xxlBold,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  widget.savedDiagnosis.diagnosisList.toList().map((diagnosis) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DiagnosisCard(
                    diagnosis: diagnosis,
                    index: widget.savedDiagnosis.diagnosisList
                            .toList()
                            .indexOf(diagnosis) +
                        1,
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 30),
              child: GestureDetector(
                onTap: _deleteDiagnosis,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: ShapeDecoration(
                    color: AppColors.red.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: isDeleting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : Text(
                            "Delete",
                            textAlign: TextAlign.center,
                            style: AppTypography().largeSemiBold.copyWith(
                                  color: AppColors.red,
                                ),
                          ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}