class DiagnosisItem {
  final String name;
  final double confidence;
  
  DiagnosisItem({
    required this.name,
    required this.confidence,
  });
  
  factory DiagnosisItem.fromMap(Map<String, dynamic> map) {
    // Print the map for debugging
    print('Converting diagnosis item from: $map');
    
    return DiagnosisItem(
      name: map['name'] ?? 
            map['diagnosis'] ?? // Added to check for 'diagnosis' field
            map['diagnosisName'] ?? 
            'Unknown',
      confidence: (map['confidence'] is num) 
        ? (map['confidence'] as num).toDouble() 
        : ((map['confidenceScore'] is num) 
            ? (map['confidenceScore'] as num).toDouble() 
            : 0.9), // Default to 0.9 confidence when not specified
    );
  }
}

class DiagnosisModel {
  final String id;
  final String userId;
  final String date;
  final String? patientName;
  final String? patientEmail;
  final String? patientPhone;
  final List<DiagnosisItem> diagnosisList;
  final String? imageUrl;
  final String? notes; // Added notes property
  
  DiagnosisModel({
    required this.id,
    required this.userId,
    required this.date,
    this.patientName,
    this.patientEmail,
    this.patientPhone,
    required this.diagnosisList,
    this.imageUrl,
    this.notes, // Added to constructor
  });
  
  factory DiagnosisModel.fromMap(Map<String, dynamic> map) {
    // Print the map structure for debugging
    print('Converting diagnosis from map with keys: ${map.keys.toList()}');
    
    List<DiagnosisItem> diagnoses = [];
    if (map['diagnosisList'] != null) {
      if (map['diagnosisList'] is List) {
        try {
          diagnoses = (map['diagnosisList'] as List)
              .map((item) {
                if (item is Map) {
                  return DiagnosisItem.fromMap(item is Map<String, dynamic>
                      ? item
                      : (item as Map).cast<String, dynamic>());
                }
                return DiagnosisItem(name: 'Unknown Format', confidence: 0.0);
              })
              .toList();
        } catch (e) {
          print('Error parsing diagnosisList: $e');
        }
      }
    }
    
    return DiagnosisModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      patientName: map['patientName'],
      patientEmail: map['patientEmail'],
      patientPhone: map['patientPhone'],
      diagnosisList: diagnoses,
      imageUrl: map['image'],
      notes: map['notes'], // Added notes field extraction
    );
  }
}