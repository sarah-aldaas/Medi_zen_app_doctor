import 'package:intl/intl.dart';

import '../../../schedule/data/model/schedule_model.dart';

class VacationModel {
  final String? id;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reason;
  final ScheduleModel? schedule;

  VacationModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.schedule,
  });

  factory VacationModel.fromJson(Map<String, dynamic> json) {
    return VacationModel(
      id: json['id'].toString(),
      startDate: DateTime.parse(json['start_date'].toString()),
      endDate: DateTime.parse(json['end_date'].toString()),
      reason: json['reason'],
      schedule: json['schedule'] != null
          ? ScheduleModel.fromJson(json['schedule'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'reason': reason,
      'schedule': schedule?.toJson(),
    };
  }
  Map<String, dynamic> createJson() {
    return {
      'id': id?.toString(),
      'start_date':DateFormat('yyyy-MM-dd').format(startDate!),
      'end_date':DateFormat('yyyy-MM-dd').format(endDate!),
      'reason': reason,
      'schedule_id': schedule?.id,
    };
  }
  VacationModel copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    ScheduleModel? schedule,
  }) {
    return VacationModel(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      schedule: schedule ?? this.schedule,
    );
  }
}