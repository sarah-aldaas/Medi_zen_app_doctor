import 'package:intl/intl.dart';

class ScheduleFilterModel {
  final String? searchQuery;
  final DateTime? planningHorizonStart;
  final DateTime? planningHorizonEnd;
  final bool? active;

  ScheduleFilterModel({
    this.searchQuery,
    this.planningHorizonStart,
    this.planningHorizonEnd,
    this.active,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (planningHorizonStart != null) {
      map['planning_horizon_start'] = _formatDate(planningHorizonStart!);
    }

    if (planningHorizonEnd != null) {
      map['planning_horizon_end'] = _formatDate(planningHorizonEnd!);
    }

    if (active != null) {
      map['active'] = active! ? 1 : 0;
    }

    return map;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  ScheduleFilterModel copyWith({
    String? searchQuery,
    DateTime? planningHorizonStart,
    DateTime? planningHorizonEnd,
    bool? active,
  }) {
    return ScheduleFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      planningHorizonStart: planningHorizonStart ?? this.planningHorizonStart,
      planningHorizonEnd: planningHorizonEnd ?? this.planningHorizonEnd,
      active: active ?? this.active,
    );
  }
}