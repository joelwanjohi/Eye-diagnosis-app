import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:opt_app/providers/firebase_provider.dart';
import 'package:opt_app/providers/firestore_provider.dart';
import 'dart:convert';

final diagnosisSyncServiceProvider = Provider((ref) => DiagnosisSyncService(ref));

class DiagnosisSyncService {
  DiagnosisSyncService(this.ref);
  final ProviderRef ref;

  // Get current user ID
  String? get _currentUserId => ref.read(firebaseProvider).currentUser?.uid;

  // Get Firestore instance
  FirebaseFirestore get _firestore => ref.read(firestoreProvider);

  // Save diagnosis to both Hive and Firebase
  Future<void> saveDiagnosis(SavedDiagnosis diagnosis) async {
    try {
      // First save to Hive for offline access
      final Box<SavedDiagnosis> diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
      await diagnosesBox.put(diagnosis.id, diagnosis);

      // If user is logged in, sync with Firebase
      if (_currentUserId != null) {
        await _syncDiagnosisToFirebase(diagnosis);
        print('Diagnosis saved locally and synced to Firebase');
      } else {
        print('Diagnosis saved locally only - user not authenticated');
      }
    } catch (e) {
      print('Failed to save diagnosis: $e');
      rethrow;
    }
  }

  // Upload a single diagnosis to Firebase
  Future<void> _syncDiagnosisToFirebase(SavedDiagnosis diagnosis) async {
    if (_currentUserId == null) return;

    try {
      // Create base data map
      final Map<String, dynamic> data = {
        'id': diagnosis.id,
        'image': diagnosis.image,
        'date': diagnosis.date,
        'patientName': diagnosis.patientName,
        'patientPhone': diagnosis.patientPhone,
        'patientEmail': diagnosis.patientEmail,
        'userId': _currentUserId,
        'syncedAt': DateTime.now().toIso8601String(),
      };
      
      // Handle diagnosisList conversion in a way that doesn't depend on specific properties
      final List<Map<String, dynamic>> diagnosisListMaps = [];
      
      for (final diagnosisItem in diagnosis.diagnosisList) {
        try {
          // Method 1: Try using a safe conversion approach
          // This converts the object to json string and back to a map to ensure it's serializable
          final String jsonString = jsonEncode(diagnosisItem);
          final Map<String, dynamic> itemMap = jsonDecode(jsonString) as Map<String, dynamic>;
          diagnosisListMaps.add(itemMap);
        } catch (e) {
          print('Error serializing diagnosis item: $e');
          
          // Method 2: Manual approach - create an empty map and add all serializable properties
          final Map<String, dynamic> itemMap = {};
          
          // Get properties using reflection (this is a simplified version)
          try {
            // Try to use toJson() if it exists
            if (diagnosisItem.toJson != null) {
              final Map<String, dynamic> jsonMap = diagnosisItem.toJson();
              diagnosisListMaps.add(jsonMap);
              continue;
            }
          } catch (e) {
            print('No toJson method available: $e');
          }
          
          // If we get here, we need a fallback approach
          // Add a placeholder since we couldn't serialize the item
          diagnosisListMaps.add({
            'serialization_error': true,
            'diagnosis_toString': diagnosisItem.toString(),
          });
        }
      }
      
      data['diagnosisList'] = diagnosisListMaps;

      // Save to Firestore
      await _firestore
          .collection('diagnoses')
          .doc(diagnosis.id)
          .set(data);
    } catch (e) {
      print('Failed to sync diagnosis to Firebase: $e');
      rethrow;
    }
  }

  // Sync all local diagnoses to Firebase
  Future<void> syncAllDiagnosesToFirebase() async {
    if (_currentUserId == null) return;

    try {
      final Box<SavedDiagnosis> diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
      final List<SavedDiagnosis> allDiagnoses = diagnosesBox.values.toList();

      for (final diagnosis in allDiagnoses) {
        await _syncDiagnosisToFirebase(diagnosis);
      }

      print('Successfully synced all diagnoses to Firebase');
    } catch (e) {
      print('Failed to sync all diagnoses to Firebase: $e');
      rethrow;
    }
  }

  // Delete a diagnosis from both Hive and Firebase
  Future<void> deleteDiagnosis(String diagnosisId) async {
    try {
      // Delete from Hive
      final Box<SavedDiagnosis> diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
      await diagnosesBox.delete(diagnosisId);

      // Delete from Firebase if user is logged in
      if (_currentUserId != null) {
        await _firestore
            .collection('diagnoses')
            .doc(diagnosisId)
            .delete();
            
        print('Diagnosis deleted locally and from Firebase');
      } else {
        print('Diagnosis deleted locally only - user not authenticated');
      }
    } catch (e) {
      print('Failed to delete diagnosis: $e');
      rethrow;
    }
  }

  // Get all diagnoses for the current user from Firebase
  Future<List<SavedDiagnosis>> fetchUserDiagnosesFromFirebase() async {
    if (_currentUserId == null) return [];

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('diagnoses')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final List<SavedDiagnosis> diagnoses = [];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        try {
          diagnoses.add(SavedDiagnosis.fromJson(data));
        } catch (e) {
          print('Error converting Firestore data to SavedDiagnosis: $e');
        }
      }

      return diagnoses;
    } catch (e) {
      print('Failed to fetch diagnoses from Firebase: $e');
      return [];
    }
  }
}