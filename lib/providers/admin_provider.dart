import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diagnosis_model.dart';
import '../models/user_model.dart';
import '../services/admin_firebase_service.dart';

// Authentication state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for the current admin user
final currentAdminUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return null;
  
  final service = ref.read(adminFirebaseServiceProvider);
  try {
    return await service.getUserById(authState.uid);
  } catch (e) {
    return null;
  }
});

// Provider for all users
final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final service = ref.read(adminFirebaseServiceProvider);
  return await service.getAllUsers();
});

// Provider for all diagnoses
final diagnosesProvider = FutureProvider<List<DiagnosisModel>>((ref) async {
  final service = ref.read(adminFirebaseServiceProvider);
  return await service.getAllDiagnoses();
});

// Provider for diagnoses statistics
final diagnosisStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(adminFirebaseServiceProvider);
  return await service.getDiagnosisStatistics();
});

// Provider for user diagnoses
final userDiagnosesProvider = FutureProvider.family<List<DiagnosisModel>, String>((ref, userId) async {
  final service = ref.read(adminFirebaseServiceProvider);
  return await service.getUserDiagnoses(userId);
});

// Provider for date range diagnoses
final dateRangeDiagnosesProvider = FutureProvider.family<List<DiagnosisModel>, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final service = ref.read(adminFirebaseServiceProvider);
  return await service.getDiagnosesForDateRange(params.startDate, params.endDate);
});

// Provider to track the selected date range
final selectedDateRangeProvider = StateProvider<({DateTime? startDate, DateTime? endDate})>((ref) => (startDate: null, endDate: null));

// Provider for the selected user
final selectedUserProvider = StateProvider<String?>((ref) => null);

// Provider for loading state
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for error messages
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Provider for success messages
final successMessageProvider = StateProvider<String?>((ref) => null);



// Logout function provider
final logoutProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.read(adminFirebaseServiceProvider);
  await service.logout();
  return true;
});