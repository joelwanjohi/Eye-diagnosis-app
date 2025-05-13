import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/diagnosis_model.dart';
import '../models/user_model.dart';

// Providers for Firebase services
final adminFirebaseServiceProvider = Provider((ref) => AdminFirebaseService());

class AdminFirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin login credentials
  static const String adminEmail = 'joyletics207@gmail.com';
  static const String adminPassword = '12345678';

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Create admin user (use this to ensure the admin exists)
  Future<UserCredential> createAdminUser({required String email, required String password}) async {
    try {
      // Try to create the admin user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Set admin privileges in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isAdmin': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // If user exists, try to sign in instead
        return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // Rethrow other exceptions
      rethrow;
    }
  }

  // Get all app users
  Future<List<UserModel>> getAllUsers() async {
    try {
      // Debug Firebase path
      print('Fetching users from Firestore collection: users');
      
      final snapshot = await _firestore.collection('users').get();
      print('Found ${snapshot.docs.length} users in Firebase');
      
      // Debug the first user if available
      if (snapshot.docs.isNotEmpty) {
        print('Sample user data: ${snapshot.docs.first.data()}');
      }
      
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }).toList();

      // Get diagnosis counts for each user
      for (var i = 0; i < users.length; i++) {
        final diagnosisCount = await _getDiagnosisCountForUser(users[i].id);
        users[i] = users[i].copyWith(diagnosisCount: diagnosisCount);
      }
      
      return users;
    } catch (e) {
      print('Failed to fetch users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Get diagnosis count for a specific user
  Future<int> _getDiagnosisCountForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('diagnoses')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      
      // Return the count or 0 if it's null
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Get all diagnoses
  Future<List<DiagnosisModel>> getAllDiagnoses() async {
    try {
      final snapshot = await _firestore
          .collection('diagnoses')
          .orderBy('date', descending: true)
          .get();
      
      // Debug log to see what we're getting from Firebase
      print('Found ${snapshot.docs.length} diagnoses in Firebase');
      if (snapshot.docs.isNotEmpty) {
        print('Sample diagnosis data: ${snapshot.docs.first.data()}');
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Debug log for diagnosis conversion
        try {
          final diagnosis = DiagnosisModel.fromMap(data);
          return diagnosis;
        } catch (e) {
          print('Error converting diagnosis ${doc.id}: $e');
          // Return a placeholder diagnosis for debugging
          return DiagnosisModel(
            id: doc.id,
            userId: data['userId'] ?? '',
            date: data['date'] ?? DateTime.now().toIso8601String(),
            diagnosisList: [],
          );
        }
      }).toList();
    } catch (e) {
      print('Failed to fetch diagnoses: $e');
      throw Exception('Failed to fetch diagnoses: $e');
    }
  }

  // Get diagnoses for a specific user
  Future<List<DiagnosisModel>> getUserDiagnoses(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('diagnoses')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DiagnosisModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user diagnoses: $e');
    }
  }

  // Get diagnoses for a date range
  Future<List<DiagnosisModel>> getDiagnosesForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final startStr = startDate.toIso8601String();
      final endStr = endDate.toIso8601String();
      
      final snapshot = await _firestore
          .collection('diagnoses')
          .where('date', isGreaterThanOrEqualTo: startStr)
          .where('date', isLessThanOrEqualTo: endStr)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DiagnosisModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch diagnoses for date range: $e');
    }
  }

  // Get user data by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        throw Exception('User not found');
      }
      
      final data = doc.data()!;
      data['id'] = doc.id;
      
      final diagnosisCount = await _getDiagnosisCountForUser(userId);
      return UserModel.fromMap(data, diagnosisCount: diagnosisCount);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Get diagnoses statistics
  Future<Map<String, dynamic>> getDiagnosisStatistics() async {
    try {
      final snapshot = await _firestore.collection('diagnoses').get();
      
      // Log diagnoses count for debugging
      print('Fetched ${snapshot.docs.length} diagnoses for statistics');
      
      final diagnoses = snapshot.docs.map((doc) => doc.data()).toList();
      
      // Diagnoses per day
      final Map<String, int> diagnosesPerDay = {};
      // Diagnoses per user
      final Map<String, int> diagnosesPerUser = {};
      // Diagnoses by type
      final Map<String, int> diagnosisByType = {};
      
      for (final diagnosis in diagnoses) {
        // Count by day
        if (diagnosis['date'] != null) {
          final dateStr = diagnosis['date'].toString().split('T')[0];
          diagnosesPerDay[dateStr] = (diagnosesPerDay[dateStr] ?? 0) + 1;
        }
        
        // Count by user
        if (diagnosis['userId'] != null) {
          final userId = diagnosis['userId'];
          diagnosesPerUser[userId] = (diagnosesPerUser[userId] ?? 0) + 1;
        }
        
        // Count by diagnosis type
        if (diagnosis['diagnosisList'] != null) {
          try {
            final diagnosisList = diagnosis['diagnosisList'] as List<dynamic>;
            print('Processing diagnosisList with ${diagnosisList.length} items');
            
            for (final item in diagnosisList) {
              if (item is Map) {
                // Try different field names that might be present in your data
                final name = item['name'] ?? 
                            item['diagnosisName'] ?? 
                            item.keys.firstWhere((k) => k.contains('name'), orElse: () => null);
                
                if (name != null) {
                  final type = name.toString();
                  diagnosisByType[type] = (diagnosisByType[type] ?? 0) + 1;
                  print('Added diagnosis type: $type (count: ${diagnosisByType[type]})');
                }
              }
            }
          } catch (e) {
            print('Error processing diagnosisList: $e');
          }
        }
      }
      
      // Sort diagnosis types by count for most common - WITH NULL SAFETY FIX
      final List<Map<String, dynamic>> mostCommonDiagnoses = diagnosisByType.entries
          .map((entry) => {'name': entry.key, 'count': entry.value})
          .toList()
        ..sort((a, b) {
          // Handle potential null values safely
          final countA = a['count'] as int?;
          final countB = b['count'] as int?;
          
          if (countA == null && countB == null) return 0;
          if (countA == null) return 1; // null counts go to the end
          if (countB == null) return -1;
          
          return countB.compareTo(countA); // Descending order
        });
      
      // Take top 5 or all if less than 5
      final topDiagnoses = mostCommonDiagnoses.take(5).toList();
      print('Top diagnoses: $topDiagnoses');
      
      // Get diagnoses per month for trend analysis
      Map<String, int> diagnosesPerMonth = {};
      for (var dateStr in diagnosesPerDay.keys) {
        try {
          final date = DateTime.parse(dateStr);
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          diagnosesPerMonth[monthKey] = (diagnosesPerMonth[monthKey] ?? 0) + diagnosesPerDay[dateStr]!;
        } catch (_) {
          // Skip invalid dates
        }
      }
      
      // Get users data for enhanced statistics
      List<UserModel> users = await getAllUsers();
      Map<String, UserModel> userMap = {for (var user in users) user.id: user};
      
      return {
        'totalDiagnoses': diagnoses.length,
        'diagnosesPerDay': diagnosesPerDay,
        'diagnosesPerMonth': diagnosesPerMonth,
        'diagnosesPerUser': diagnosesPerUser,
        'diagnosisByType': diagnosisByType,
        'uniqueUsers': diagnosesPerUser.keys.length,
        'totalUsers': users.length,
        'mostCommonDiagnoses': topDiagnoses,
        'mostActiveDiagnosers': _getMostActiveDiagnosers(diagnosesPerUser, userMap),
      };
    } catch (e) {
      print('Failed to fetch diagnosis statistics: $e');
      throw Exception('Failed to fetch diagnosis statistics: $e');
    }
  }
  
  // Helper to get most active diagnosers
  List<Map<String, dynamic>> _getMostActiveDiagnosers(
      Map<String, int> diagnosesPerUser, Map<String, UserModel> userMap) {
    final sortedEntries = diagnosesPerUser.entries.toList()
      ..sort((a, b) {
        // Handle potential null values safely
        final countA = a.value;
        final countB = b.value;
        
        if (countA == null && countB == null) return 0;
        if (countA == null) return 1; // null counts go to the end
        if (countB == null) return -1;
        
        return countB.compareTo(countA); // Descending order
      });
    
    return sortedEntries.take(5).map((entry) {
      final user = userMap[entry.key];
      return {
        'userId': entry.key,
        'email': user?.email ?? 'Unknown',
        'name': user?.name ?? 'Unknown',
        'count': entry.value,
      };
    }).toList();
  }
  
  // Helper to get most common diagnoses (no longer used - logic moved to getDiagnosisStatistics)
  List<Map<String, dynamic>> _getMostCommonDiagnoses(Map<String, int> diagnosisByType) {
    final sortedEntries = diagnosisByType.entries.toList()
      ..sort((a, b) {
        // Handle potential null values safely
        final countA = a.value;
        final countB = b.value;
        
        if (countA == null && countB == null) return 0;
        if (countA == null) return 1;
        if (countB == null) return -1;
        
        return countB.compareTo(countA);
      });
    
    return sortedEntries.take(5).map((entry) {
      return {
        'name': entry.key,
        'count': entry.value,
      };
    }).toList();
  }

  // Generate a formatted report for printing
  Future<String> generatePrintableReport({DateTime? startDate, DateTime? endDate}) async {
    try {
      QuerySnapshot snapshot;
      if (startDate != null && endDate != null) {
        final startStr = startDate.toIso8601String();
        final endStr = endDate.toIso8601String();
        
        snapshot = await _firestore
            .collection('diagnoses')
            .where('date', isGreaterThanOrEqualTo: startStr)
            .where('date', isLessThanOrEqualTo: endStr)
            .get();
      } else {
        snapshot = await _firestore.collection('diagnoses').get();
      }
      
      final diagnoses = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      // Format the report
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      final StringBuffer report = StringBuffer();
      
      report.writeln('EyeCheckAI Diagnosis Report');
      report.writeln('Generated: ${dateFormat.format(DateTime.now())}');
      report.writeln('Total Diagnoses: ${diagnoses.length}');
      report.writeln('--------------------------------------');
      
      // Group by date
      final Map<String, List<Map<String, dynamic>>> byDate = {};
      for (final diagnosis in diagnoses) {
        if (diagnosis['date'] != null) {
          final dateStr = diagnosis['date'].toString().split('T')[0];
          if (!byDate.containsKey(dateStr)) {
            byDate[dateStr] = [];
          }
          byDate[dateStr]?.add(diagnosis);
        }
      }
      
      // Format each day's diagnoses
      for (final date in byDate.keys.toList()..sort()) {
        final dayDiagnoses = byDate[date]!;
        report.writeln('\nDate: $date - ${dayDiagnoses.length} diagnoses');
        
        for (final diagnosis in dayDiagnoses) {
          report.writeln('  Patient: ${diagnosis['patientName'] ?? 'N/A'}');
          report.writeln('  Email: ${diagnosis['patientEmail'] ?? 'N/A'}');
          report.writeln('  Results:');
          
          if (diagnosis['diagnosisList'] != null) {
            for (final item in (diagnosis['diagnosisList'] as List)) {
              if (item is Map) {
                final name = item['name'] ?? 'Unknown';
                final confidence = item['confidence'] ?? 0.0;
                report.writeln('    - $name (${(confidence * 100).toStringAsFixed(1)}%)');
              }
            }
          }
          report.writeln('  ---');
        }
      }
      
      return report.toString();
    } catch (e) {
      throw Exception('Failed to generate printable report: $e');
    }
  }

  // Admin logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}