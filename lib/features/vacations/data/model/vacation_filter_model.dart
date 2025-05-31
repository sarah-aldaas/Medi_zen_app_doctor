import 'package:intl/intl.dart';

class VacationFilterModel {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? scheduleId;
  final int? practitionerId;


  VacationFilterModel({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.scheduleId,
    this.practitionerId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (startDate != null) {
      map['start_date'] = _formatDate(startDate!);
    }

    if (endDate != null) {
      map['end_date'] = _formatDate(endDate!);
    }

    if (scheduleId != null) {
      map['schedule_id'] = scheduleId;
    }

    if (practitionerId != null) {
      map['practitioner_id'] = practitionerId;
    }

    return map;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  VacationFilterModel copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int? scheduleId,
    int? practitionerId,
   }) {
    return VacationFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      scheduleId: scheduleId ?? this.scheduleId,
      practitionerId: practitionerId ?? this.practitionerId,
    );
  }
}