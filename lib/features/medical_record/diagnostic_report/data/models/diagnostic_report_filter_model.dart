
class DiagnosticReportFilterModel {
  final String? searchQuery;
  final String? statusId;
  final String? conditionId;

  DiagnosticReportFilterModel({
    this.searchQuery,
    this.statusId,
    this.conditionId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
      if (statusId != null) 'status_id': statusId,
      if (conditionId != null) 'condition_id': conditionId,
    };
  }

  DiagnosticReportFilterModel copyWith({
    String? searchQuery,
    String? statusId,
    String? conditionId,
  }) {
    return DiagnosticReportFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      statusId: statusId ?? this.statusId,
      conditionId: conditionId ?? this.conditionId,
    );
  }
}