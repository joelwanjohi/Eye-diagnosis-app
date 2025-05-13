import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opt_app/models/diagnosis.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:opt_app/providers/firebase_provider.dart';
import 'package:opt_app/services/SyncServiceProvider.dart';

import 'package:uuid/uuid.dart';

final diagnosisServiceProvider = Provider((ref) => DiagnosisService(ref));

class DiagnosisService {
  DiagnosisService(this.ref);
  final ProviderRef ref;

  // Get current user ID 
  String? get _currentUserId => ref.read(firebaseProvider).currentUser?.uid;

  // Save a new diagnosis
  Future<String?> saveDiagnosis({
    required String? image,
    required List<dynamic> diagnosisList,
    required String? patientName,
    required String? patientPhone,
    required String? patientEmail,
  }) async {
    try {
      // Generate a unique ID for this diagnosis
      final String id = const Uuid().v4();
      
      // Create the diagnosis object
      final SavedDiagnosis diagnosis = SavedDiagnosis(
        id: id,
        image: image,
        diagnosisList: diagnosisList.cast<Diagnosis>(),
        date: DateTime.now().toIso8601String(),
        patientName: patientName,
        patientPhone: patientPhone,
        patientEmail: patientEmail,
      );

      // Use the sync service to save to both Hive and Firebase
      final syncService = ref.read(diagnosisSyncServiceProvider);
      await syncService.saveDiagnosis(diagnosis);
      
      print('Diagnosis saved with ID: $id');
      return id;
    } catch (e) {
      print('Failed to save diagnosis: $e');
      return null;
    }
  }

  // Get all diagnoses from Hive
  List<SavedDiagnosis> getAllDiagnoses() {
    try {
      final Box<SavedDiagnosis> diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
      return diagnosesBox.values.toList();
    } catch (e) {
      print('Failed to get all diagnoses: $e');
      return [];
    }
  }

  // Sync all local diagnoses with Firebase
  Future<void> syncAllDiagnoses() async {
    if (_currentUserId == null) {
      print('Cannot sync diagnoses: User not authenticated');
      return;
    }

    try {
      final syncService = ref.read(diagnosisSyncServiceProvider);
      await syncService.syncAllDiagnosesToFirebase();
    } catch (e) {
      print('Failed to sync all diagnoses: $e');
      rethrow;
    }
  }

  // Update an existing diagnosis
  Future<bool> updateDiagnosis(SavedDiagnosis diagnosis) async {
    try {
      final syncService = ref.read(diagnosisSyncServiceProvider);
      await syncService.saveDiagnosis(diagnosis);
      return true;
    } catch (e) {
      print('Failed to update diagnosis: $e');
      return false;
    }
  }

  // Get diagnosis by ID
  SavedDiagnosis? getDiagnosisById(String id) {
    try {
      final Box<SavedDiagnosis> diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
      return diagnosesBox.get(id);
    } catch (e) {
      print('Failed to get diagnosis by ID: $e');
      return null;
    }
  }
}