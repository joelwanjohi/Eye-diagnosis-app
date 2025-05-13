// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
// import 'package:opt_app/library/opt_app.dart';
// import 'package:opt_app/models/savedDiagnosis.dart';
// import 'package:firebase_core/firebase_core.dart'; // Import Firebase
// import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Firebase Crashlytics
// import 'package:hive/hive.dart'; // Import Hive
// import 'package:hive_flutter/hive_flutter.dart'; // Import Hive Flutter

// late Box<SavedDiagnosis> diagnosesBox; // Declare diagnosesBox

// void main() async {
//   await dotenv.load(fileName: ".env"); // Load .env file first
//   WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter bindings
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
//   await RemoteConfigRepository.init();
//   PlatformDispatcher.instance.onError = (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     return true;
//   };

//   await Hive.initFlutter();

//   // Register adapters
//   if (!Hive.isAdapterRegistered(DiagnosisAdapter().typeId)) {
//     Hive.registerAdapter(DiagnosisAdapter());
//   }

//   if (!Hive.isAdapterRegistered(SavedDiagnosisAdapter().typeId)) {
//     Hive.registerAdapter(SavedDiagnosisAdapter());
//   }

//   // Open the box
//   await Hive.openBox<SavedDiagnosis>('diagnoses');
//   // await Hive.initFlutter(); // Initialize Hive
//   // Hive.registerAdapter(DiagnosisAdapter());
//   // Hive.registerAdapter(SavedDiagnosisAdapter());

//   // // Open only one Hive box
//   // diagnosesBox = await Hive.openBox<SavedDiagnosis>('diagnosisBox');

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'EyeCheckAi',
//       theme: AppTheme().light,
//       home: const OnboardingPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opt_app/providers/simple_sync_manager.dart';


late Box<SavedDiagnosis> diagnosesBox;

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await RemoteConfigRepository.init();
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(DiagnosisAdapter().typeId)) {
    Hive.registerAdapter(DiagnosisAdapter());
  }

  if (!Hive.isAdapterRegistered(SavedDiagnosisAdapter().typeId)) {
    Hive.registerAdapter(SavedDiagnosisAdapter());
  }

  await Hive.openBox<SavedDiagnosis>('diagnoses');

  // Wrap the app with ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize the sync manager
    ref.read(syncManagerProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background, attempt to sync
    if (state == AppLifecycleState.resumed) {
      ref.read(syncManagerProvider).onAppResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeCheckAi',
      theme: AppTheme().light,
      home: const OnboardingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}