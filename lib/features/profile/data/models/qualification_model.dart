import 'dart:io';

import '../../../../base/data/models/code_type_model.dart';

class QualificationModel {
  final String? id;
  final String? issuer;
  final String? startDate;
  final String? endDate;
  final String? pdfFileName;
  final CodeModel? type;
  final String? pdfUrl; // Add this to store the full URL

  QualificationModel({
    required this.id,
    required this.issuer,
    required this.startDate,
    this.endDate,
    this.pdfFileName,
    this.pdfUrl,
    this.type,
  });

  factory QualificationModel.fromJson(Map<String, dynamic> json) {
    String? pdfFileName;
    if (json['pdf'] != null) {
      pdfFileName = (json['pdf'] as String).split('/').last;
    }

    return QualificationModel(
      id: json['id'].toString(),
      issuer: json['issuer'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      pdfFileName: pdfFileName,
      pdfUrl: json['pdf'].toString(),
      type:json['type'] !=null? CodeModel.fromJson(json['type'] as Map<String, dynamic>):null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'issuer': issuer, 'start_date': startDate, 'end_date': endDate, 'pdf_file_name': pdfFileName, 'type_id': type!.id};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          issuer == other.issuer &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          pdfFileName == other.pdfFileName &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ issuer.hashCode ^ startDate.hashCode ^ endDate.hashCode ^ pdfFileName.hashCode ^ type.hashCode;
}

// import '../../../../base/data/models/code_type_model.dart';
//
// class QualificationModel {
//   final String? id;
//   final String? issuer;
//   final String? startDate;
//   final String? endDate;
//   final String? pdf;
//   final CodeModel type;
//
//   QualificationModel({
//     required this.id,
//     required this.issuer,
//     required this.startDate,
//     this.endDate,
//     this.pdf,
//     required this.type,
//   });
//
//   factory QualificationModel.fromJson(Map<String, dynamic> json) {
//     return QualificationModel(
//       id: json['id'].toString(),
//       issuer: json['issuer'] as String,
//       startDate: json['start_date'] as String,
//       endDate: json['end_date'] as String?,
//       pdf: json['pdf'] as String?,
//       type: CodeModel.fromJson(json['type'] as Map<String, dynamic>),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'issuer': issuer,
//       'start_date': startDate,
//       'end_date': endDate,
//       'pdf': pdf,
//       'type_id': type.id,
//     };
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is QualificationModel &&
//               runtimeType == other.runtimeType &&
//               id == other.id &&
//               issuer == other.issuer &&
//               startDate == other.startDate &&
//               endDate == other.endDate &&
//               pdf == other.pdf &&
//               type == other.type;
//
//   @override
//   int get hashCode =>
//       id.hashCode ^
//       issuer.hashCode ^
//       startDate.hashCode ^
//       endDate.hashCode ^
//       pdf.hashCode ^
//       type.hashCode;
// }
