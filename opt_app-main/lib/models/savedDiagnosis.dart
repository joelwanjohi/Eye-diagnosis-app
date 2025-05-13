// import 'package:hive/hive.dart';
// import 'package:opt_app/models/diagnosis.dart';
// part 'savedDiagnosis.g.dart';

// @HiveType(typeId: 2)
// class SavedDiagnosis {
//   @HiveField(0)
//   String? id;
//   @HiveField(1)
//   String? image;
//   @HiveField(2)
//   List<Diagnosis> diagnosisList = [];
//   @HiveField(3)
//   String? date;

//   SavedDiagnosis(
//       {this.id = "",
//       this.image = "",
//       this.diagnosisList = const [],
//       this.date = ""});

//   SavedDiagnosis.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     image = json['image'];
//     diagnosisList = json['diagnosisList'].cast<Diagnosis>();
//     date = json['date'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['image'] = image;
//     data['diagnosisList'] = diagnosisList;
//     data['date'] = date;
//     return data;
//   }
// }

import 'package:hive/hive.dart';
import 'package:opt_app/models/diagnosis.dart';
part 'savedDiagnosis.g.dart';

@HiveType(typeId: 2)
class SavedDiagnosis {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? image;

  @HiveField(2)
  List<Diagnosis> diagnosisList = [];

  @HiveField(3)
  String? date;

  @HiveField(4)
  String? patientName;

  @HiveField(5)
  String? patientPhone;

  @HiveField(6)
  String? patientEmail;

  SavedDiagnosis(
      {this.id = "",
      this.image = "",
      this.diagnosisList = const [],
      this.date = "",
      this.patientName = "",
      this.patientPhone = "",
      this.patientEmail = ""});

  SavedDiagnosis.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    diagnosisList = json['diagnosisList'].cast<Diagnosis>();
    date = json['date'];
    patientName = json['patientName'];
    patientPhone = json['patientPhone'];
    patientEmail = json['patientEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['diagnosisList'] = diagnosisList;
    data['date'] = date;
    data['patientName'] = patientName;
    data['patientPhone'] = patientPhone;
    data['patientEmail'] = patientEmail;
    return data;
  }
}
