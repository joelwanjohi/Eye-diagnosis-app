// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void didChangeDependencies() async {
//     setState(() {
//       diagnosesBox.get(0);
//     });

//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text(
//             "Your Saved Diagnoses",
//             style: AppTypography().largeSemiBold.copyWith(
//                   color: AppColors.white,
//                 ),
//           )),
//       floatingActionButton: diagnosesBox.isEmpty
//           ? const SizedBox.shrink()
//           : FloatingActionButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SelectComplaint(),
//                   ),
//                 );
//               },
//               elevation: 0,
//               child: const Icon(Icons.add),
//             ),
//       body: diagnosesBox.isEmpty
//           ? buildErrorPage()
//           : SizedBox(
//               height: double.infinity,
//               child: RefreshIndicator(
//                 onRefresh: () async {
//                   setState(() {
//                     diagnosesBox.get(0);
//                   });
//                 },
//                 child: Column(
//                   children: [
//                     // Text(
//                     //   "Your Saved Diagnoses",
//                     //   style: AppTypography().largeSemiBold,
//                     // ),
//                     // const SizedBox(height: 12),
//                     ListView.builder(
//                       itemCount: diagnosesBox.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         final SavedDiagnosis savedDiagnosis =
//                             diagnosesBox.getAt(index) as SavedDiagnosis;
//                         return DiagnosisHomeCard(
//                           diagnosis: savedDiagnosis,
//                           isLast: index == diagnosesBox.length - 1,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Container buildErrorPage() {
//     return Container(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 26.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "🥴",
//                 style: AppTypography().xxxxxlBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "You have not \nsaved any diagnoses yet",
//                 style: AppTypography().baseSemiBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: PrimaryButton(
//                   text: "Generate Diagnosis",
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SelectComplaint(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late Box<SavedDiagnosis> diagnosesBox;

//   @override
//   void initState() {
//     super.initState();
//     diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
//   }

//   Future<void> _refreshData() async {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             centerTitle: true,
//             title: Text(
//               "Your Saved Diagnoses",
//               style: AppTypography().largeSemiBold.copyWith(
//                     color: AppColors.white,
//                   ),
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const SelectComplaint(),
//                 ),
//               );
//             },
//             elevation: 0,
//             child: const Icon(Icons.add),
//           ),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerDocked,
//           bottomNavigationBar: BottomAppBar(
//             color: Colors.grey.shade700,
//             shape: const CircularNotchedRectangle(),
//             notchMargin: 6.0,
//             elevation: 8,
//             child: SizedBox(
//               height: 45, // Explicitly define height to prevent overflow
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildNavItem(
//                       Icons.location_pin, "Find Eye Clinic", Colors.blueAccent),
//                   _buildNavItem(Icons.help, "Help", Colors.greenAccent),
//                 ],
//               ),
//             ),
//           ),
//           body: ValueListenableBuilder<Box<SavedDiagnosis>>(
//             valueListenable: diagnosesBox.listenable(),
//             builder: (context, box, _) {
//               if (box.isEmpty) {
//                 return buildErrorPage();
//               }
//               return RefreshIndicator(
//                 onRefresh: _refreshData,
//                 child: CustomScrollView(
//                   slivers: [
//                     SliverPadding(
//                       padding: const EdgeInsets.all(16),
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                             final SavedDiagnosis? diagnosis = box.getAt(index);
//                             if (diagnosis == null) {
//                               return const SizedBox.shrink();
//                             }
//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 16),
//                               child: DiagnosisHomeCard(
//                                 diagnosis: diagnosis,
//                                 isLast: index == box.length - 1,
//                               ),
//                             );
//                           },
//                           childCount: box.length,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, Color color) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         IconButton(
//           icon: Icon(icon, color: color, size: 24), // Slightly smaller icon
//           onPressed: () {},
//         ),
//         Text(label,
//             style: const TextStyle(color: Colors.white70, fontSize: 10)),
//       ],
//     );
//   }

//   Widget buildErrorPage() {
//     return Container(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 26.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "🥴",
//                 style: AppTypography().xxxxxlBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 "You have not \nsaved any diagnoses yet",
//                 style: AppTypography().baseSemiBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: PrimaryButton(
//                   text: "Generate Diagnosis",
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SelectComplaint(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // No need to close the box here as it should be closed when the app terminates
//     super.dispose();
//   }
// }

// // Add this debug extension to help troubleshoot any issues
// extension DiagnosisBoxDebug on Box<SavedDiagnosis> {
//   void debugPrintContents() {
//     print('Diagnoses Box Contents:');
//     print('Total items: ${this.length}');
//     for (var i = 0; i < this.length; i++) {
//       final diagnosis = this.getAt(i);
//       print('Item $i:');
//       print('  ID: ${diagnosis?.id}');
//       print('  Date: ${diagnosis?.date}');
//       print('  Image: ${diagnosis?.image}');
//       print('  Number of diagnoses: ${diagnosis?.diagnosisList.length}');
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opt_app/features/chat/generative_text_view.dart';
import 'package:opt_app/features/dashboard/dashboard_screen.dart';
import 'package:opt_app/features/find%20ophthalmologist/ophthalmologist.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/models/savedDiagnosis.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<SavedDiagnosis> diagnosesBox;

  @override
  void initState() {
    super.initState();
    diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "Patients Saved Diagnoses",
              style: AppTypography().largeSemiBold.copyWith(
                    color: AppColors.white,
                  ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectComplaint(
                    patientName: "John Doe", // Replace with actual data
                    patientPhone: "1234567890", // Replace with actual data
                    patientEmail: "johndoe@example.com",
                  ),
                ),
              );
            },
            backgroundColor: Colors.white60,
            foregroundColor: AppColors.primary, // Green plus icon
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: AppColors.primary,
            height: 65,
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            notchMargin: 3.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed from spaceBetween
              children: [
                // Find Eye Clinic button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FindHospitalScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_pin,
                            color: Colors.white, size: 26),
                        const SizedBox(height: 4),
                        Text(
                          "Find Eye Clinic",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // // Empty space for FAB (left side)
                // const SizedBox(width: 40),
                
                // // Empty space for FAB (right side)
                // const SizedBox(width: 40),

                // // Dashboard button
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => const DashboardScreen()),
                //     );
                //   },
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Icon(Icons.analytics_outlined,
                //             color: Colors.white, size: 26),
                //         const SizedBox(height: 4),
                //         Text(
                //           "Analysis",
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 10,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.2,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

                // Chat Assistant button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatView()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_outlined,
                            color: Colors.white, size: 26),
                        const SizedBox(height: 4),
                        Text(
                          "Chat Assistant",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: ValueListenableBuilder<Box<SavedDiagnosis>>(
            valueListenable: diagnosesBox.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) {
                return buildErrorPage();
              }
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final SavedDiagnosis? diagnosis = box.getAt(index);
                            if (diagnosis == null) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: DiagnosisHomeCard(
                                diagnosis: diagnosis,
                                isLast: index == box.length - 1,
                              ),
                            );
                          },
                          childCount: box.length,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildErrorPage() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 26.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "🥴",
                style: AppTypography().xxxxxlBold,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "You have not \nsaved any diagnoses yet",
                style: AppTypography().baseSemiBold,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PrimaryButton(
                  text: "Generate Diagnosis",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectComplaint(
                          patientName: "John Doe",
                          patientPhone: "1234567890",
                          patientEmail: "johndoe@example.com",
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}