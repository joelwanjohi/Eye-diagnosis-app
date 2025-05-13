import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opt_app/models/savedDiagnosis.dart';

class DiagnosisAnalyzer {
  final List<SavedDiagnosis> diagnoses;
  final DateTimeRange dateRange;
  final String searchQuery;

  DiagnosisAnalyzer({
    required this.diagnoses,
    required this.dateRange,
    this.searchQuery = '',
  });

  /// Generate all dashboard data
  Future<Map<String, dynamic>> generateDashboardData() async {
    // Filter diagnoses by date range and search query
    final filteredDiagnoses = _filterDiagnoses();

    return {
      // Overview data
      'totalDiagnoses': filteredDiagnoses.length,
      'averagePerDay': _calculateAveragePerDay(filteredDiagnoses),
      'uniquePatients': _countUniquePatients(filteredDiagnoses),
      'mostCommonDiagnosis': _findMostCommonDiagnosis(filteredDiagnoses),
      
      // Trend data
      'visitTrends': _generateVisitTrends(filteredDiagnoses),
      'diagnosisDistribution': _generateDiagnosisDistribution(filteredDiagnoses),
      'busiestDays': _findBusiestDays(filteredDiagnoses),
      'monthlyComparison': _generateMonthlyComparison(),
      'diagnosisTrends': _generateDiagnosisTrends(filteredDiagnoses),
      
      // Patient data
      'topReturningPatients': _findTopReturningPatients(filteredDiagnoses),
      'noShowRate': _calculateNoShowRate(),  // Mock data for now
      'followUpSuggestions': _generateFollowUpSuggestions(filteredDiagnoses),
    };
  }

  /// Filter diagnoses based on date range and search query
  List<SavedDiagnosis> _filterDiagnoses() {
    return diagnoses.where((diagnosis) {
      // Filter by date
      if (diagnosis.date == null) return false;
      
      final diagnosisDate = DateTime.parse(diagnosis.date!);
      final withinDateRange = diagnosisDate.isAfter(dateRange.start) && 
                            diagnosisDate.isBefore(dateRange.end);
      
      // Filter by search query
      final matchesSearch = searchQuery.isEmpty || 
                           (diagnosis.patientName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      
      return withinDateRange && matchesSearch;
    }).toList();
  }

  /// Calculate average diagnoses per day
  double _calculateAveragePerDay(List<SavedDiagnosis> filteredDiagnoses) {
    if (filteredDiagnoses.isEmpty) return 0.0;
    
    final days = dateRange.duration.inDays;
    return days > 0 ? filteredDiagnoses.length / days : filteredDiagnoses.length.toDouble();
  }

  /// Count unique patients
  int _countUniquePatients(List<SavedDiagnosis> filteredDiagnoses) {
    final patientSet = <String>{};
    
    for (var diagnosis in filteredDiagnoses) {
      if (diagnosis.patientName != null && diagnosis.patientName!.isNotEmpty) {
        patientSet.add(diagnosis.patientName!);
      }
    }
    
    return patientSet.length;
  }

  /// Find most common diagnosis
  String? _findMostCommonDiagnosis(List<SavedDiagnosis> filteredDiagnoses) {
    if (filteredDiagnoses.isEmpty) return null;
    
    final diagnosisCounts = <String, int>{};
    
    for (var diagnosis in filteredDiagnoses) {
      for (var item in diagnosis.diagnosisList) {
        final diagnosisName = item.diagnosis; // Using the correct property name
        if (diagnosisName != null && diagnosisName.isNotEmpty) {
          diagnosisCounts[diagnosisName] = (diagnosisCounts[diagnosisName] ?? 0) + 1;
        }
      }
    }
    
    String? mostCommon;
    int maxCount = 0;
    
    diagnosisCounts.forEach((diagnosis, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = diagnosis;
      }
    });
    
    return mostCommon;
  }

  /// Generate visit trends data (diagnoses per day/week)
  List<Map<String, dynamic>> _generateVisitTrends(List<SavedDiagnosis> filteredDiagnoses) {
    // Create a map of dates to count
    final dateCountMap = <String, int>{};
    
    // Initialize all dates in range with zero count
    for (int i = 0; i <= dateRange.duration.inDays; i++) {
      final date = dateRange.start.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      dateCountMap[dateStr] = 0;
    }
    
    // Count diagnoses per day
    for (var diagnosis in filteredDiagnoses) {
      if (diagnosis.date != null) {
        final diagnosisDate = DateTime.parse(diagnosis.date!);
        final dateStr = DateFormat('yyyy-MM-dd').format(diagnosisDate);
        dateCountMap[dateStr] = (dateCountMap[dateStr] ?? 0) + 1;
      }
    }
    
   // Convert to list format for charts
    final result = <Map<String, dynamic>>[];
    
    dateCountMap.forEach((date, count) {
      result.add({
        'date': date,
        'count': count,
      });
    });
    
    // Sort by date
    result.sort((a, b) => a['date'].compareTo(b['date']));
    
    return result;
  }

  /// Generate diagnosis distribution data (for pie chart)
  List<Map<String, dynamic>> _generateDiagnosisDistribution(List<SavedDiagnosis> filteredDiagnoses) {
    final diagnosisCounts = <String, int>{};
    
    for (var diagnosis in filteredDiagnoses) {
      for (var item in diagnosis.diagnosisList) {
        final diagnosisName = item.diagnosis; // Using the correct property name
        if (diagnosisName != null && diagnosisName.isNotEmpty) {
          diagnosisCounts[diagnosisName] = (diagnosisCounts[diagnosisName] ?? 0) + 1;
        }
      }
    }
    
    // Convert to list and sort by count (descending)
    final result = <Map<String, dynamic>>[];
    
    diagnosisCounts.forEach((diagnosis, count) {
      result.add({
        'label': diagnosis,
        'value': count,
      });
    });
    
    result.sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));
    
    // Limit to top 8 diagnoses, and group the rest as "Others"
    if (result.length > 8) {
      int othersCount = 0;
      for (int i = 8; i < result.length; i++) {
        othersCount += result[i]['value'] as int;
      }
      
      final topResults = result.sublist(0, 8);
      if (othersCount > 0) {
        topResults.add({
          'label': 'Others',
          'value': othersCount,
        });
      }
      
      return topResults;
    }
    
    return result;
  }

  /// Find busiest days of the week
  List<Map<String, dynamic>> _findBusiestDays(List<SavedDiagnosis> filteredDiagnoses) {
    final dayCounts = <int, int>{
      1: 0, // Monday
      2: 0, // Tuesday
      3: 0, // Wednesday
      4: 0, // Thursday
      5: 0, // Friday
      6: 0, // Saturday
      7: 0, // Sunday
    };
    
    // Count diagnoses per day of week
    for (var diagnosis in filteredDiagnoses) {
      if (diagnosis.date != null) {
        final diagnosisDate = DateTime.parse(diagnosis.date!);
        final dayOfWeek = diagnosisDate.weekday; // 1 for Monday, 7 for Sunday
        dayCounts[dayOfWeek] = (dayCounts[dayOfWeek] ?? 0) + 1;
      }
    }
    
    // Convert to list format for charts
    final result = <Map<String, dynamic>>[];
    final dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    for (int i = 0; i < 7; i++) {
      final dayIndex = i + 1; // 1 for Monday, 7 for Sunday
      result.add({
        'label': dayNames[i],
        'value': dayCounts[dayIndex] ?? 0,
        'highlighted': _isMaxValue(dayCounts, dayIndex),
      });
    }
    
    return result;
  }
  
  /// Check if the value for the given key is the maximum in the map
  bool _isMaxValue(Map<int, int> map, int key) {
    final value = map[key] ?? 0;
    for (final otherValue in map.values) {
      if (otherValue > value) return false;
    }
    return true;
  }

  /// Generate monthly comparison data
  List<Map<String, dynamic>> _generateMonthlyComparison() {
    // Mock data for monthly comparison (current month vs previous month)
    final now = DateTime.now();
    final currentMonth = now.month;
    final previousMonth = currentMonth - 1 > 0 ? currentMonth - 1 : 12;
    
    final currentMonthName = DateFormat('MMMM').format(DateTime(now.year, currentMonth));
    final previousMonthName = DateFormat('MMMM').format(DateTime(now.year, previousMonth));
    
    return [
      {
        'label': currentMonthName,
        'current': 28,
        'previous': 22,
        'target': 30,
      },
      {
        'label': previousMonthName,
        'current': 22,
        'previous': 18,
        'target': 25,
      },
    ];
  }

  /// Generate diagnosis trends over time
  List<Map<String, dynamic>> _generateDiagnosisTrends(List<SavedDiagnosis> filteredDiagnoses) {
    // Get top diagnoses
    final diagnosisCounts = <String, int>{};
    for (var diagnosis in filteredDiagnoses) {
      for (var item in diagnosis.diagnosisList) {
        final diagnosisName = item.diagnosis; // Using the correct property name
        if (diagnosisName != null && diagnosisName.isNotEmpty) {
          diagnosisCounts[diagnosisName] = (diagnosisCounts[diagnosisName] ?? 0) + 1;
        }
      }
    }
    
    // Sort and get top 3 diagnoses
    final sortedDiagnoses = diagnosisCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topDiagnoses = sortedDiagnoses.take(3).map((e) => e.key).toList();
    
    // Create a map to track trends over time
    final dateMap = <String, Map<String, int>>{};
    
    // Initialize all dates in range
    for (int i = 0; i <= dateRange.duration.inDays; i++) {
      final date = dateRange.start.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      dateMap[dateStr] = {
        for (var diagnosis in topDiagnoses) diagnosis: 0
      };
    }
    
    // Count diagnoses per day for each top diagnosis
    for (var diagnosis in filteredDiagnoses) {
      if (diagnosis.date != null) {
        final diagnosisDate = DateTime.parse(diagnosis.date!);
        final dateStr = DateFormat('yyyy-MM-dd').format(diagnosisDate);
        
        if (dateMap.containsKey(dateStr)) {
          for (var item in diagnosis.diagnosisList) {
            final diagnosisName = item.diagnosis; // Using the correct property name
            if (diagnosisName != null && 
                diagnosisName.isNotEmpty && 
                topDiagnoses.contains(diagnosisName)) {
              dateMap[dateStr]![diagnosisName] = (dateMap[dateStr]![diagnosisName] ?? 0) + 1;
            }
          }
        }
      }
    }
    
    // Convert to list format for charts
    final result = <Map<String, dynamic>>[];
    
    dateMap.forEach((date, counts) {
      final entry = <String, dynamic>{
        'date': date,
      };
      
      counts.forEach((diagnosis, count) {
        entry[diagnosis] = count;
      });
      
      result.add(entry);
    });
    
    // Sort by date
    result.sort((a, b) => a['date'].compareTo(b['date']));
    
    return result;
  }

  /// Find top returning patients - Updated to correctly count diagnoses per patient
  List<Map<String, dynamic>> _findTopReturningPatients(List<SavedDiagnosis> filteredDiagnoses) {
    final patientDiagnoses = <String, List<SavedDiagnosis>>{};
    
    // Group diagnoses by patient name
    for (var diagnosis in filteredDiagnoses) {
      if (diagnosis.patientName != null && 
          diagnosis.patientName!.isNotEmpty) {
        
        final patientName = diagnosis.patientName!;
        
        if (!patientDiagnoses.containsKey(patientName)) {
          patientDiagnoses[patientName] = [];
        }
        
        patientDiagnoses[patientName]!.add(diagnosis);
      }
    }
    
    // Convert to list format for display
    final result = <Map<String, dynamic>>[];
    
    patientDiagnoses.forEach((name, diagnoses) {
      // Get latest date
      DateTime? latestDate;
      for (var diagnosis in diagnoses) {
        if (diagnosis.date != null) {
          final diagnosisDate = DateTime.parse(diagnosis.date!);
          if (latestDate == null || diagnosisDate.isAfter(latestDate)) {
            latestDate = diagnosisDate;
          }
        }
      }
      
      // Use the first diagnosis to get patient contact info
      final firstDiagnosis = diagnoses.isNotEmpty ? diagnoses.first : null;
      
      result.add({
        'name': name,
        'visitCount': diagnoses.length, // Count of total diagnoses for this patient
        'lastVisit': latestDate != null ? DateFormat('dd/MM/yyyy').format(latestDate) : 'N/A',
        'email': firstDiagnosis?.patientEmail,
        'phone': firstDiagnosis?.patientPhone,
      });
    });
    
    // Sort by number of diagnoses (descending)
    result.sort((a, b) => (b['visitCount'] as int).compareTo(a['visitCount'] as int));
    
    // Return top 10 patients (or all if less than 10)
    return result.take(10).toList();
  }

  /// Find patient email by name
  String? _findPatientEmail(String name, List<SavedDiagnosis> diagnoses) {
    for (var diagnosis in diagnoses) {
      if (diagnosis.patientName == name && diagnosis.patientEmail != null) {
        return diagnosis.patientEmail;
      }
    }
    return null;
  }

  /// Find patient phone by name
  String? _findPatientPhone(String name, List<SavedDiagnosis> diagnoses) {
    for (var diagnosis in diagnoses) {
      if (diagnosis.patientName == name && diagnosis.patientPhone != null) {
        return diagnosis.patientPhone;
      }
    }
    return null;
  }

  /// Calculate mock no-show rate
  double _calculateNoShowRate() {
    // Mock data for now
    return 0.12; // 12% no-show rate
  }

  /// Generate follow-up suggestions
  List<Map<String, dynamic>> _generateFollowUpSuggestions(List<SavedDiagnosis> filteredDiagnoses) {
    // For simplicity, suggest follow-ups for patients who haven't had a checkup in the last month
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    final patientLastVisit = <String, DateTime>{};
    
    // Find the most recent visit for each patient
    for (var diagnosis in filteredDiagnoses) {
      if (diagnosis.patientName != null && 
          diagnosis.patientName!.isNotEmpty && 
          diagnosis.date != null) {
        
        final patientName = diagnosis.patientName!;
        final visitDate = DateTime.parse(diagnosis.date!);
        
        if (!patientLastVisit.containsKey(patientName) || 
            visitDate.isAfter(patientLastVisit[patientName]!)) {
          patientLastVisit[patientName] = visitDate;
        }
      }
    }
    
    // Generate follow-up suggestions
    final result = <Map<String, dynamic>>[];
    
    patientLastVisit.forEach((name, lastVisit) {
      if (lastVisit.isBefore(oneMonthAgo)) {
        // Calculate due date (3 months after last visit)
        final dueDate = lastVisit.add(const Duration(days: 90));
        
        result.add({
          'patientName': name,
          'lastVisit': DateFormat('dd/MM/yyyy').format(lastVisit),
          'dueDate': DateFormat('dd/MM/yyyy').format(dueDate),
          'email': _findPatientEmail(name, filteredDiagnoses),
          'phone': _findPatientPhone(name, filteredDiagnoses),
          'isDue': dueDate.isBefore(now),
        });
      }
    });
    
    // Sort by due date (earliest first)
    result.sort((a, b) {
      final dateA = DateFormat('dd/MM/yyyy').parse(a['dueDate']);
      final dateB = DateFormat('dd/MM/yyyy').parse(b['dueDate']);
      return dateA.compareTo(dateB);
    });
    
    return result;
  }
}