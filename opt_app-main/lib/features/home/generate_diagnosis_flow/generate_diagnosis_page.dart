// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:opt_app/components/cards/diagnosis_card.dart';
// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';

// class GenerateDiagnosisPage extends StatefulWidget {
//   final List<String> complaints;
//   final EyeForComplaint location;
//   final List<String> ocularHealth;
//   final List<String> medicalHealth;
//   final List<Uint8List>? images;
//   final String path;
//   const GenerateDiagnosisPage(
//       {super.key,
//       required this.complaints,
//       required this.location,
//       required this.ocularHealth,
//       required this.medicalHealth,
//       this.images,
//       required this.path});

//   @override
//   State<GenerateDiagnosisPage> createState() => _GenerateDiagnosisPageState();
// }

// class _GenerateDiagnosisPageState extends State<GenerateDiagnosisPage> {
//   // final Gemini gemini = Gemini.instance;
//   bool loading = true;
//   String generatedText = "";
//   List<Diagnosis> diagnosisList = [];
//   bool error = false;
//   var uuid = const Uuid();
//   String id = "";
//   String imageLink = "";
//   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
//   final model = GenerativeModel(
//     model: 'gemini-1.5-flash-latest',
//     apiKey: Config.geminiApiKey,
//     safetySettings: [
//       SafetySetting(
//         HarmCategory.harassment,
//         HarmBlockThreshold.none,
//       ),
//       SafetySetting(
//         HarmCategory.hateSpeech,
//         HarmBlockThreshold.medium,
//       ),
//       SafetySetting(
//         HarmCategory.sexuallyExplicit,
//         HarmBlockThreshold.none,
//       ),
//     ],
//     generationConfig: GenerationConfig(temperature: 0.7, responseMimeType: 'application/json'),
//   );

//   Future<bool> isValidJson(String jsonString) async {
//     try {
//       await jsonDecode(jsonString);
//       debugPrint("valid json");
//       return true;
//     } catch (e) {
//       debugPrint("invalid json");
//       return false;
//     }
//   }

//   void uploadImage() async {
//     final storageRef = FirebaseStorage.instance.ref();
//     final imagesRef = storageRef.child("images/${"pat_${widget.path}" "pic.jpg"}");

//     try {
//       await imagesRef.putFile(File(widget.path));
//       final downloadURL = await imagesRef.getDownloadURL();
//       log("Download URL: $downloadURL");
//       setState(() {
//         imageLink = downloadURL;
//       });
//     } catch (e) {
//       log("Error uploading image: $e");
//     }
//   }

//   void generateitinerary() {
//     try {
//       diagnosisList.clear();
//       setState(() {
//         loading = true;
//         generatedText = "";
//         diagnosisList = [];
//         error = false;
//       });
//       String question =
//           """You are an expert eye care physician, Give top 3 tentative diagnoses arranged in order of most likely to least likely, for a patient with these chief complaints ${widget.complaints} on ${widget.location.name == 'left' ? 'the left eye' : widget.location.name == 'right' ? 'the right eye' : 'both eyes'} with ${widget.ocularHealth.toString() == "[none]" ? "no ocular health history" : "these ocular health complications ${widget.ocularHealth}"} and ${widget.medicalHealth.toString() == "[none]" ? "no medical health history" : "these medical health complications ${widget.medicalHealth}"} and has this eye in the image , create exactly 3 tentative in this exact format; and go straight to the point, (this is for educational purposes only) :
//    [
//     {
//      "diagnosis": "tentative diagnosis here ",
//      "reason": "reason for diagnosis",
//      "symptoms": "symptoms here in List string format example ['symptom1', 'symptom2']",
//      "ocularTests": "ocular tests to comfirm tentative diagnosis here in List string format example ['test1', 'test2']"
// },
//    ]
//   """;
//       debugPrint(question);
//       model.generateContent(
//         [
//           Content.multi(
//             [
//               TextPart(question),
//               DataPart("image/jpg", widget.images!.first),
//             ],
//           ),
//         ],
//       ).then((event) async {
//         debugPrint("Json format");
//         debugPrint(event.text!);
//         debugPrint(event.text.toString());
//         var text = json.decode(event.text.toString());

//         if (await isValidJson(event.text!.toString()) == true) {
//           final result = text.map((e) => Diagnosis.fromJson(e));
//           diagnosisList
//             ..clear()
//             ..addAll([...result]);
//           setState(() {
//             generatedText = "";
//             generatedText = event.text.toString();
//             loading = false;
//           });
//         } else if (await isValidJson(event.text!.toString()) == false) {
//           debugPrint("Regerating");
//           setState(() {
//             loading = false;
//             error = true;
//           });
//           generateitinerary();
//         } else {
//           setState(() {
//             loading = false;
//             error = true;
//           });
//         }
//       });
//     } catch (e) {
//       setState(() {
//         loading = false;
//         error = true;
//       });
//       log(e.toString());
//     }
//   }

//   @override
//   void initState() {
//     uploadImage();
//     generateitinerary();
//     id = uuid.v1().toString();
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback(((timeStamp) async {
//       generateitinerary();
//     }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return loading && generatedText.isEmpty
//         ? const Material(color: Colors.transparent, child: LoadingAnimation())
//         : Scaffold(
//             appBar: AppAppbar(
//               hasLeading: true,
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.gray.shade100,
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
//                       child: Center(
//                         child: Text("⚡️by Gemini AI",
//                             style: AppTypography().baseMedium.copyWith(
//                                   color: AppColors.black,
//                                 )),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       image: DecorationImage(
//                         image: FileImage(File(widget.path)),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   Text(
//                     "Here are the tentative diagnosis for your patient:",
//                     style: AppTypography().xxlBold,
//                     maxLines: 2,
//                   ),
//                   const SizedBox(
//                     height: 16,
//                   ),
//                   generatedText.isEmpty || generatedText == "[]" || error
//                       ? buildErrorPage()
//                       : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: diagnosisList.take(3).toList().map((diagnosis) {
//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 12),
//                               child: DiagnosisCard(
//                                 diagnosis: diagnosis,
//                                 index: diagnosisList.take(3).toList().indexOf(diagnosis) + 1,
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                   (loading && generatedText.isEmpty) || error
//                       ? const SizedBox.shrink()
//                       : Padding(
//                           padding: const EdgeInsets.only(top: 24),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               PrimaryButton(
//                                 text: "Save",
//                                 onPressed: () {
//                                   diagnosesBox
//                                       .put(
//                                     id,
//                                     SavedDiagnosis(
//                                         id: id,
//                                         image: imageLink,
//                                         diagnosisList: diagnosisList.take(3).toList(),
//                                         date: DateTime.now().toString()),
//                                   )
//                                       .then((value) {
//                                     Navigator.pushAndRemoveUntil(
//                                       context,
//                                       MaterialPageRoute(builder: (context) => const HomePage()),
//                                       (Route<dynamic> route) => false,
//                                     );
//                                   });
//                                 },
//                               ),
//                               Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 16),
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       generateitinerary();
//                                     },
//                                     child: Text(
//                                       "Doesn't look right? Regenerate",
//                                       style: AppTypography().baseSemiBold.copyWith(
//                                           color: AppColors.primary.shade400,
//                                           decoration: TextDecoration.underline,
//                                           decorationColor: AppColors.primary.shade400),
//                                     ),
//                                   )),
//                               const SizedBox(
//                                 height: 16,
//                               ),
//                             ],
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           );
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
//                 style: AppTypography().xxxxlBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "We couldn't generate a tentative diagnosis for your patient. Please try again.",
//                 style: AppTypography().baseSemiBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                   width: 190,
//                   child: PrimaryButton(
//                     text: "Regenerate",
//                     onPressed: () => generateitinerary(),
//                   )),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LoadingAnimation extends StatefulWidget {
//   const LoadingAnimation({
//     super.key,
//   });

//   @override
//   State<LoadingAnimation> createState() => _LoadingAnimationState();
// }

// class _LoadingAnimationState extends State<LoadingAnimation> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               AppLottie.generating,
//               height: 180,
//               width: 200,
//             ),
//             Text(
//               "Generating Diagnosis...",
//               style: AppTypography().baseSemiBold.copyWith(color: AppColors.black),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:hive/hive.dart';
// import 'package:lottie/lottie.dart';
// import 'package:connectivity_plus/connectivity_plus.dart'; // For network connectivity check
// import 'package:opt_app/components/cards/diagnosis_card.dart';
// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';
// import 'package:opt_app/models/diagnosis.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv

// class GenerateDiagnosisPage extends StatefulWidget {
//   final List<String> complaints;
//   final EyeForComplaint location;
//   final List<String> ocularHealth;
//   final List<String> medicalHealth;
//   final List<Uint8List>? images;
//   final String path;
//   final String patientName;
//   final String patientPhone;
//   final String patientEmail;

//   const GenerateDiagnosisPage({
//     super.key,
//     required this.complaints,
//     required this.location,
//     required this.ocularHealth,
//     required this.medicalHealth,
//     this.images,
//     required this.path,
//     required this.patientName,
//     required this.patientPhone,
//     required this.patientEmail,
//   });

//   @override
//   State<GenerateDiagnosisPage> createState() => _GenerateDiagnosisPageState();
// }

// class _GenerateDiagnosisPageState extends State<GenerateDiagnosisPage> {
//   bool loading = true;
//   String generatedText = "";
//   List<Diagnosis> diagnosisList = [];
//   bool error = false;
//   String id = "";
//   bool isGenerating = false;

//   final uuid = const Uuid();
//   GenerativeModel? model;
//   Box<SavedDiagnosis>? diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
//   final Connectivity _connectivity = Connectivity(); // Initialize Connectivity

//   @override
//   void initState() {
//     super.initState();

//     try {
//       id = uuid.v1();
//       initializeModel();

//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         if (!mounted) return;

//         try {
//           if (mounted) {
//             await generateDiagnosis();
//           }
//         } catch (e) {
//           log("Error in initialization: $e");
//           if (mounted) {
//             setState(() {
//               error = true;
//               loading = false;
//             });
//           }
//         }
//       });
//     } catch (e) {
//       log("Error in initState: $e");
//     }
//   }

//   void initializeModel() {
//     try {
//       final apiKey = dotenv.env['API_KEY']; // Load the API key from .env
//       if (apiKey == null) {
//         throw Exception("API key not found in .env file");
//       }

//       model = GenerativeModel(
//         model: 'gemini-1.5-flash-latest',
//         apiKey: apiKey, // Use the API key from .env
//         safetySettings: [
//           SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
//           SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
//           SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
//         ],
//         generationConfig: GenerationConfig(
//           temperature: 0.7,
//           responseMimeType: 'application/json',
//         ),
//       );
//     } catch (e) {
//       log("Error initializing model: $e");
//     }
//   }

//   Future<bool> isValidJson(String? jsonString) async {
//     if (jsonString == null) return false;
//     try {
//       await json.decode(jsonString);
//       return true;
//     } catch (e) {
//       log("Invalid JSON: $e");
//       return false;
//     }
//   }

//   Future<bool> checkNetworkConnectivity() async {
//     final connectivityResult = await _connectivity.checkConnectivity();
//     return connectivityResult != ConnectivityResult.none;
//   }

//   Future<void> generateDiagnosis() async {
//     if (!mounted || isGenerating || model == null) return;

//     setState(() {
//       isGenerating = true;
//       loading = true;
//       error = false;
//       generatedText = "";
//       diagnosisList.clear();
//     });

//     try {
//       if (widget.images == null || widget.images!.isEmpty) {
//         throw Exception("No images provided");
//       }

//       // Ensure the image is in Uint8List format
//       final Uint8List imageBytes = widget.images!.first;

//       // Check if the image is valid
//       if (imageBytes.isEmpty) {
//         throw Exception("Invalid image file");
//       }

//       final question =
//           """You are an expert eye care physician, Give top 3 tentative diagnoses arranged in order of most likely to least likely, for a patient with these chief complaints ${widget.complaints} on ${widget.location.name == 'left' ? 'the left eye' : widget.location.name == 'right' ? 'the right eye' : 'both eyes'} with ${widget.ocularHealth.toString() == "[none]" ? "no ocular health history" : "these ocular health complications ${widget.ocularHealth}"} and ${widget.medicalHealth.toString() == "[none]" ? "no medical health history" : "these medical health complications ${widget.medicalHealth}"} and has this eye in the image , create exactly 3 tentative in this exact format; and go straight to the point, (this is for educational purposes only) :
//    [
//     {
//      "diagnosis": "tentative diagnosis here ",
//      "reason": "reason for diagnosis",
//      "symptoms": "symptoms here in List string format example ['symptom1', 'symptom2']",
//      "ocularTests": "ocular tests to confirm tentative diagnosis here in List string format example ['test1', 'test2']"
//     }
//    ]
//   """;

//       final event = await model!.generateContent([
//         Content.multi([
//           TextPart(question),
//           DataPart("image/jpg", imageBytes), // Pass the image as Uint8List
//         ]),
//       ]);

//       log("Gemini API Response: ${event.text}");

//       if (!mounted) return;

//       if (event.text != null) {
//         final isValid = await isValidJson(event.text);

//         if (isValid) {
//           final text = json.decode(event.text!) as List;
//           log("Parsed Diagnoses: $text");

//           final result = text
//               .map((e) {
//                 if (e == null) return null;
//                 try {
//                   return Diagnosis.fromJson(e as Map<String, dynamic>);
//                 } catch (e) {
//                   log("Error parsing diagnosis: $e");
//                   return null;
//                 }
//               })
//               .whereType<Diagnosis>()
//               .toList();

//           if (result.isEmpty) {
//             throw Exception("No valid diagnoses generated");
//           }

//           setState(() {
//             diagnosisList = result;
//             generatedText = event.text!;
//             loading = false;
//             error = false;
//           });
//         } else {
//           throw Exception("Invalid response format");
//         }
//       }
//     } catch (e) {
//       log("Error generating diagnosis: $e");
//       if (mounted) {
//         setState(() {
//           error = true;
//           loading = false;
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isGenerating = false;
//         });
//       }
//     }
//   }

//   Future<void> saveDiagnosis() async {
//     if (diagnosesBox == null) {
//       log("diagnosesBox is null");
//       return;
//     }

//     try {
//       await diagnosesBox!.put(
//         id,
//         SavedDiagnosis(
//           id: id,
//           image: widget.path, // Use the local file path
//           diagnosisList: diagnosisList.take(3).toList(),
//           date: DateTime.now().toString(),
//           patientName: widget.patientName,
//           patientPhone: widget.patientPhone,
//           patientEmail: widget.patientEmail,
//         ),
//       );

//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const HomePage()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     } catch (e) {
//       log("Error saving diagnosis: $e");
//     }
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
//                 style: AppTypography().xxxxlBold,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "We couldn't generate a tentative diagnosis for your patient. Please try again.",
//                 style: AppTypography().baseSemiBold,
//                 maxLines: 2,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: 190,
//                 child: PrimaryButton(
//                   text: "Regenerate",
//                   onPressed: isGenerating ? null : generateDiagnosis,
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
//   Widget build(BuildContext context) {
//     if (!mounted) return const SizedBox.shrink();

//     final file = File(widget.path);
//     if (!file.existsSync()) {
//       return const Material(
//         child: Center(
//           child: Text("Image file not found"),
//         ),
//       );
//     }

//     return loading && generatedText.isEmpty
//         ? const Material(
//             color: Colors.transparent,
//             child: LoadingAnimation(),
//           )
//         : Scaffold(
//             appBar: AppAppbar(
//               hasLeading: true,
//               actions: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.gray.shade100,
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsetsDirectional.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       child: Center(
//                         child: Text(
//                           "⚡️Results",
//                           style: AppTypography().baseMedium.copyWith(
//                                 color: AppColors.black,
//                               ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Patient info card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: AppColors.gray.shade100,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Patient Information",
//                           style: AppTypography().largeSemiBold,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Name: ${widget.patientName}",
//                           style: AppTypography().baseMedium,
//                         ),
//                         Text(
//                           "Phone: ${widget.patientPhone}",
//                           style: AppTypography().baseMedium,
//                         ),
//                         Text(
//                           "Email: ${widget.patientEmail}",
//                           style: AppTypography().baseMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       image: DecorationImage(
//                         image: FileImage(file),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Here are the tentative diagnosis for your patient:",
//                     style: AppTypography().xxlBold,
//                     maxLines: 2,
//                   ),
//                   const SizedBox(height: 16),
//                   if (generatedText.isEmpty || generatedText == "[]" || error)
//                     buildErrorPage()
//                   else
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: diagnosisList.take(3).map((diagnosis) {
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: DiagnosisCard(
//                             diagnosis: diagnosis,
//                             index: diagnosisList.indexOf(diagnosis) + 1,
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   if (!(loading && generatedText.isEmpty) && !error)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 24),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           PrimaryButton(
//                             text: "Save",
//                             onPressed: saveDiagnosis,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             child: GestureDetector(
//                               onTap: isGenerating ? null : generateDiagnosis,
//                               child: Text(
//                                 "Doesn't look right? Regenerate",
//                                 style: AppTypography().baseSemiBold.copyWith(
//                                     color: AppColors.primary.shade400,
//                                     decoration: TextDecoration.underline,
//                                     decorationColor:
//                                         AppColors.primary.shade400),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           );
//   }
// }

// class LoadingAnimation extends StatelessWidget {
//   const LoadingAnimation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               AppLottie.generating,
//               height: 180,
//               width: 200,
//             ),
//             Text(
//               "Generating Diagnosis...",
//               style: AppTypography().baseSemiBold.copyWith(
//                     color: AppColors.black,
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:opt_app/components/cards/diagnosis_card.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:opt_app/models/diagnosis.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GenerateDiagnosisPage extends StatefulWidget {
  final List<String> complaints;
  final EyeForComplaint location;
  final List<String> ocularHealth;
  final List<String> medicalHealth;
  final List<Uint8List>? images;
  final String path;
  final String patientName;
  final String patientPhone;
  final String patientEmail;

  const GenerateDiagnosisPage({
    super.key,
    required this.complaints,
    required this.location,
    required this.ocularHealth,
    required this.medicalHealth,
    this.images,
    required this.path,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
  });

  @override
  State<GenerateDiagnosisPage> createState() => _GenerateDiagnosisPageState();
}

class _GenerateDiagnosisPageState extends State<GenerateDiagnosisPage> {
  bool loading = true;
  String generatedText = "";
  List<Diagnosis> diagnosisList = [];
  bool error = false;
  String id = "";
  bool isGenerating = false;
  bool isValidatingImage = false;
  bool isValidEyeImage = true;
  String validationError = "";
  double eyeConfidence = 0.0;
  List<String> classLabels = ["Normal", "Cataract", "Glaucoma", "Retinal Disease"];
  
  // Model paths and settings
  static const String eyeModelPath = 'assets/models/eye_classifier.tflite';
  static const double confidenceThreshold = 0.6; // Minimum confidence to consider an image as a valid eye

  Interpreter? _interpreter;
  GenerativeModel? model;
  Box<SavedDiagnosis>? diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
  final Connectivity _connectivity = Connectivity();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();

    try {
      id = uuid.v1();
      initializeModel();
      loadEyeClassifierModel();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        try {
          if (mounted) {
            // First validate the image before proceeding to diagnosis
            await validateEyeImage();
          }
        } catch (e) {
          log("Error in initialization: $e");
          if (mounted) {
            setState(() {
              error = true;
              loading = false;
              validationError = "Failed to initialize the service";
            });
          }
        }
      });
    } catch (e) {
      log("Error in initState: $e");
    }
  }
  
  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> loadEyeClassifierModel() async {
    try {
      final interpreterOptions = InterpreterOptions()
        ..threads = 4;
        
      _interpreter = await Interpreter.fromAsset(
        eyeModelPath,
        options: interpreterOptions,
      );
      log("Eye classifier model loaded successfully");
    } catch (e) {
      log("Error loading eye classifier model: $e");
    }
  }

  void initializeModel() {
    try {
      final apiKey = dotenv.env['API_KEY'];
      if (apiKey == null) {
        throw Exception("API key not found in .env file");
      }

      model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        ],
        generationConfig: GenerationConfig(
          temperature: 0.7,
          responseMimeType: 'application/json',
        ),
      );
    } catch (e) {
      log("Error initializing model: $e");
    }
  }

  Future<bool> isValidJson(String? jsonString) async {
    if (jsonString == null) return false;
    try {
      await json.decode(jsonString);
      return true;
    } catch (e) {
      log("Invalid JSON: $e");
      return false;
    }
  }

  Future<bool> checkNetworkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> validateEyeImage() async {
    if (!mounted) return;

    setState(() {
      isValidatingImage = true;
      loading = true;
      error = false;
      isValidEyeImage = true;
      validationError = "";
      eyeConfidence = 0.0;
    });

    try {
      if (widget.images == null || widget.images!.isEmpty) {
        throw Exception("No images provided");
      }

      final Uint8List imageBytes = widget.images!.first;
      if (imageBytes.isEmpty) {
        throw Exception("Invalid image file");
      }
      
      // Try to use TensorFlow Lite for validation
      if (_interpreter != null) {
        final result = await classifyImage(imageBytes);
        
        if (!mounted) return;
        
        // Check if the image contains an eye with sufficient confidence
        if (result >= confidenceThreshold) {
          setState(() {
            isValidEyeImage = true;
            eyeConfidence = result;
          });
          
          // If image is valid, proceed to generate diagnosis
          if (model != null) {
            await generateDiagnosis();
          } else {
            throw Exception("Gemini model not initialized");
          }
        } else {
          setState(() {
            isValidEyeImage = false;
            loading = false;
            error = true;
            eyeConfidence = result;
            validationError = _getValidationErrorMessage(result);
          });
        }
      } else {
        // Fallback to Gemini API for validation if TensorFlow model failed to load
        log("TensorFlow model not available, falling back to API validation");
        await validateEyeImageWithGemini(imageBytes);
      }
    } catch (e) {
      log("Error validating eye image: $e");
      if (mounted) {
        setState(() {
          isValidEyeImage = false;
          error = true;
          loading = false;
          validationError = "Failed to validate the image. Please try again.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isValidatingImage = false;
        });
      }
    }
  }
  
  // Fallback validation using Gemini API
  Future<void> validateEyeImageWithGemini(Uint8List imageBytes) async {
    if (!mounted || model == null) return;
    
    try {
      final validationQuestion = """
      Analyze this image and determine if it shows a clear close-up of an eye or eyes suitable for medical diagnosis. 
      The image should show the eye clearly without being blurry, and should not be a picture of a full face or other body part.
      Respond with a JSON object in this exact format:
      {
        "isValidEyeImage": true/false,
        "reason": "Brief explanation of why the image is or is not valid for eye diagnosis"
      }
      """;

      final validationEvent = await model!.generateContent([
        Content.multi([
          TextPart(validationQuestion),
          DataPart("image/jpg", imageBytes),
        ]),
      ]);

      log("Gemini Image Validation Response: ${validationEvent.text}");

      if (!mounted) return;

      if (validationEvent.text != null) {
        final isValidJson = await this.isValidJson(validationEvent.text);

        if (isValidJson) {
          final validationResult = json.decode(validationEvent.text!) as Map<String, dynamic>;
          
          final bool isValid = validationResult['isValidEyeImage'] as bool? ?? false;
          final String reason = validationResult['reason'] as String? ?? "Unknown validation error";

          if (isValid) {
            setState(() {
              isValidEyeImage = true;
              eyeConfidence = 0.8; // Arbitrary confidence value for API validation
            });
            // If image is valid, proceed to generate diagnosis
            await generateDiagnosis();
          } else {
            setState(() {
              isValidEyeImage = false;
              loading = false;
              error = true;
              validationError = reason;
            });
          }
        } else {
          setState(() {
            isValidEyeImage = false;
            loading = false;
            error = true;
            validationError = "Unable to validate the image properly. Please upload a clear image of an eye.";
          });
        }
      }
    } catch (e) {
      log("Error in Gemini validation: $e");
      throw e; // Propagate the error
    }
  }
  
  // Helper function to classify image using TensorFlow Lite
Future<double> classifyImage(Uint8List imageBytes) async {
  try {
    // Decode the image
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Failed to decode image");
    }
    
    // Resize image to match model input size (128x128 for this model)
    final resizedImage = img.copyResize(image, width: 128, height: 128);
    
    // Convert the image to a normalized float array (0-1)
    var inputBuffer = List.filled(1 * 128 * 128 * 3, 0.0).reshape([1, 128, 128, 3]);
    
    for (var y = 0; y < 128; y++) {
      for (var x = 0; x < 128; x++) {
        final pixel = resizedImage.getPixel(x, y);
        // For Pixel objects from the image package
        inputBuffer[0][y][x][0] = pixel.r / 255.0;  // Red channel
        inputBuffer[0][y][x][1] = pixel.g / 255.0;  // Green channel
        inputBuffer[0][y][x][2] = pixel.b / 255.0;  // Blue channel
      }
    }
    
    // Prepare output tensor - 4 classes
    var outputBuffer = List.filled(1 * 4, 0.0).reshape([1, 4]);
    
    // Run inference
    _interpreter!.run(inputBuffer, outputBuffer);
    
    // Log the results
    log("Classification results: ${outputBuffer[0]}");
    
    // Get the highest confidence score
    double maxConfidence = 0.0;
    int maxIndex = 0;
    
    for (int i = 0; i < 4; i++) {
      if (outputBuffer[0][i] > maxConfidence) {
        maxConfidence = outputBuffer[0][i];
        maxIndex = i;
      }
    }
    
    log("Highest confidence class: ${classLabels[maxIndex]} with score: $maxConfidence");
    
    return maxConfidence;
  } catch (e) {
    log("Error in image classification: $e");
    return 0.0;
  }
}
  
  String _getValidationErrorMessage(double confidence) {
    if (confidence < 0.3) {
      return "This doesn't appear to be an eye image. Please provide a clear photo of the eye.";
    } else if (confidence < 0.5) {
      return "The image is unclear or may only show a partial eye. Please provide a clearer, centered photo of the eye.";
    } else {
      return "The image quality isn't sufficient for diagnosis. Please ensure the eye is clearly visible, well-lit, and in focus.";
    }
  }

  Future<void> generateDiagnosis() async {
    if (!mounted || isGenerating || model == null) return;

    setState(() {
      isGenerating = true;
      loading = true;
      error = false;
      generatedText = "";
      diagnosisList.clear();
    });

    try {
      if (widget.images == null || widget.images!.isEmpty) {
        throw Exception("No images provided");
      }

      final Uint8List imageBytes = widget.images!.first;
      if (imageBytes.isEmpty) {
        throw Exception("Invalid image file");
      }

      final question =
          """You are an expert eye care physician, Give top 3 tentative diagnoses arranged in order of most likely to least likely, for a patient with these chief complaints ${widget.complaints} on ${widget.location.name == 'left' ? 'the left eye' : widget.location.name == 'right' ? 'the right eye' : 'both eyes'} with ${widget.ocularHealth.toString() == "[none]" ? "no ocular health history" : "these ocular health complications ${widget.ocularHealth}"} and ${widget.medicalHealth.toString() == "[none]" ? "no medical health history" : "these medical health complications ${widget.medicalHealth}"} and has this eye in the image , create exactly 3 tentative in this exact format; and go straight to the point, (this is for educational purposes only) :
   [
    {
     "diagnosis": "tentative diagnosis here ",
     "reason": "reason for diagnosis",
     "symptoms": "symptoms here in List string format example ['symptom1', 'symptom2']",
     "ocularTests": "ocular tests to confirm tentative diagnosis here in List string format example ['test1', 'test2']"
    }
   ]
  """;

      final event = await model!.generateContent([
        Content.multi([
          TextPart(question),
          DataPart("image/jpg", imageBytes),
        ]),
      ]);

      log("Gemini API Response: ${event.text}");

      if (!mounted) return;

      if (event.text != null) {
        final isValid = await isValidJson(event.text);

        if (isValid) {
          final text = json.decode(event.text!) as List;
          log("Parsed Diagnoses: $text");

          final result = text
              .map((e) {
                if (e == null) return null;
                try {
                  return Diagnosis.fromJson(e as Map<String, dynamic>);
                } catch (e) {
                  log("Error parsing diagnosis: $e");
                  return null;
                }
              })
              .whereType<Diagnosis>()
              .toList();

          if (result.isEmpty) {
            throw Exception("No valid diagnoses generated");
          }

          setState(() {
            diagnosisList = result;
            generatedText = event.text!;
            loading = false;
            error = false;
          });
        } else {
          throw Exception("Invalid response format");
        }
      }
    } catch (e) {
      log("Error generating diagnosis: $e");
      if (mounted) {
        setState(() {
          error = true;
          loading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  Future<void> saveDiagnosis() async {
    if (diagnosesBox == null) {
      log("diagnosesBox is null");
      return;
    }

    try {
      await diagnosesBox!.put(
        id,
        SavedDiagnosis(
          id: id,
          image: widget.path, // Use the local file path
          diagnosisList: diagnosisList.take(3).toList(),
          date: DateTime.now().toString(),
          patientName: widget.patientName,
          patientPhone: widget.patientPhone,
          patientEmail: widget.patientEmail,
        ),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      log("Error saving diagnosis: $e");
    }
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
                !isValidEyeImage ? "👁️❌" : "🥴",
                style: AppTypography().xxxxlBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                !isValidEyeImage ? 
                  "The uploaded image is not a clear picture of an eye. $validationError" :
                  "We couldn't generate a tentative diagnosis for your patient. Please try again.",
                style: AppTypography().baseSemiBold,
                maxLines: 4,
                textAlign: TextAlign.center,
              ),
              if (!isValidEyeImage && eyeConfidence > 0) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Confidence score: ${(eyeConfidence * 100).toStringAsFixed(1)}% (minimum required: ${(confidenceThreshold * 100).toStringAsFixed(0)}%)",
                    style: AppTypography().smallMedium.copyWith(
                      color: AppColors.gray.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: 190,
                child: PrimaryButton(
                  text: !isValidEyeImage ? "Go Back" : "Regenerate",
                  onPressed: !isValidEyeImage ? 
                    () => Navigator.pop(context) : 
                    (isGenerating || isValidatingImage) ? null : validateEyeImage,
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
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    final file = File(widget.path);
    if (!file.existsSync()) {
      return const Material(
        child: Center(
          child: Text("Image file not found"),
        ),
      );
    }

    return loading && generatedText.isEmpty
        ? Material(
            color: Colors.transparent,
            child: isValidatingImage ? 
              const ImageValidationLoadingAnimation() : 
              const LoadingAnimation(),
          )
        : Scaffold(
            appBar: AppAppbar(
              hasLeading: true,
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gray.shade100,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gray.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Patient Information",
                          style: AppTypography().largeSemiBold,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Name: ${widget.patientName}",
                          style: AppTypography().baseMedium,
                        ),
                        Text(
                          "Phone: ${widget.patientPhone}",
                          style: AppTypography().baseMedium,
                        ),
                        Text(
                          "Email: ${widget.patientEmail}",
                          style: AppTypography().baseMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (generatedText.isEmpty || generatedText == "[]" || error || !isValidEyeImage)
                    buildErrorPage()
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Here are the tentative diagnosis for your patient:",
                          style: AppTypography().xxlBold,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        ...diagnosisList.take(3).map((diagnosis) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DiagnosisCard(
                              diagnosis: diagnosis,
                              index: diagnosisList.indexOf(diagnosis) + 1,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  if (!(loading && generatedText.isEmpty) && !error && isValidEyeImage)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PrimaryButton(
                            text: "Save",
                            onPressed: saveDiagnosis,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: GestureDetector(
                              onTap: (isGenerating || isValidatingImage) ? null : validateEyeImage,
                              child: Text(
                                "Doesn't look right? Regenerate",
                                style: AppTypography().baseSemiBold.copyWith(
                                    color: AppColors.primary.shade400,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        AppColors.primary.shade400),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppLottie.generating,
              height: 180,
              width: 200,
            ),
            Text(
              "Generating Diagnosis...",
              style: AppTypography().baseSemiBold.copyWith(
                    color: AppColors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageValidationLoadingAnimation extends StatelessWidget {
  const ImageValidationLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppLottie.generating,
              height: 180,
              width: 200,
            ),
            Text(
              "Validating Eye Image...",
              style: AppTypography().baseSemiBold.copyWith(
                    color: AppColors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}