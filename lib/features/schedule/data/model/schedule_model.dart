import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/features/authentication/data/models/doctor_model.dart';
import 'package:medi_zen_app_doctor/features/vacations/data/model/vacation_model.dart';

class ScheduleModel {
  final String id;
  final String name;
  final bool active;
  final DateTime planningHorizonStart;
  final DateTime planningHorizonEnd;
  final RepeatPattern repeat;
  final String? comment;
  final DoctorModel? doctorModel;
  final List<VacationModel>? vacations;

  ScheduleModel({
    required this.id,
    required this.name,
    required this.active,
    required this.planningHorizonStart,
    required this.planningHorizonEnd,
    required this.repeat,
    this.comment,
    this.doctorModel,
    this.vacations,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'].toString(),
      name: json['name'],
      active: json['active'] == 1,
      planningHorizonStart: DateTime.parse(json['planning_horizon_start']),
      planningHorizonEnd: DateTime.parse(json['planning_horizon_end']),
      repeat: RepeatPattern.fromJson(json['repeat']),
      comment: json['comment'],
      doctorModel: DoctorModel.fromJson(json['practitioner']),
      vacations:
      json.containsKey('vacations')?
      json['vacations'] != null
          ? (json['vacations'] as List).map((vacationJson) => VacationModel.fromJson(vacationJson as Map<String, dynamic>)).toList()
          : []:[],
    );
  }
  ScheduleModel copyWith({
    String? id,
    String? name,
    bool? active,
    DateTime? planningHorizonStart,
    DateTime? planningHorizonEnd,
    RepeatPattern? repeat,
    String? comment,
    DoctorModel? doctorModel,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      planningHorizonStart: planningHorizonStart ?? this.planningHorizonStart,
      planningHorizonEnd: planningHorizonEnd ?? this.planningHorizonEnd,
      repeat: repeat ?? this.repeat,
      comment: comment ?? this.comment,
      doctorModel: doctorModel ?? this.doctorModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active ? 1 : 0,
      'planning_horizon_start': planningHorizonStart.toIso8601String(),
      'planning_horizon_end': planningHorizonEnd.toIso8601String(),
      'repeat': repeat.toJson(),
      'comment': comment,
      'practitioner': doctorModel!.toJson(),
    };
  }


  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'active': active?1:0,
      'planning_horizon_start': DateFormat('yyyy-MM-dd').format(planningHorizonStart),
      'planning_horizon_end': DateFormat('yyyy-MM-dd').format(planningHorizonEnd),
      'dayOfWeek': repeat.daysOfWeek,
      'timeOfDay': repeat.timeOfDay,
      'duration': repeat.duration,
      'comment': comment,
      'practitioner_id': doctorModel!.id,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'active': active?1:0,
      'planning_horizon_start': DateFormat('yyyy-MM-dd').format(planningHorizonStart),
      'planning_horizon_end': DateFormat('yyyy-MM-dd').format(planningHorizonEnd),
      'dayOfWeek': repeat.daysOfWeek,
      'timeOfDay': repeat.timeOfDay,
      'duration': repeat.duration,
      'comment': comment,
      'practitioner_id': doctorModel!.id,
    };
  }
}

class RepeatPattern {
  final List<String> daysOfWeek; // Contains values like 'sun', 'mon', etc.
  final String timeOfDay; // Format: 'HH:mm:ss'
  final int duration; // Duration in hours

  RepeatPattern({
    required this.daysOfWeek,
    required this.timeOfDay,
    required this.duration,
  });

  factory RepeatPattern.fromJson(Map<String, dynamic> json) {
    return RepeatPattern(
      daysOfWeek: List<String>.from(json['dayOfWeek']),
      timeOfDay: json['timeOfDay'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': daysOfWeek,
      'timeOfDay': timeOfDay,
      'duration': duration,
    };
  }

  RepeatPattern copyWith({
    List<String>? daysOfWeek,
    String? timeOfDay,
    int? duration,
  }) {
    return RepeatPattern(
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      duration: duration ?? this.duration,
    );
  }

}
