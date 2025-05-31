class ReactionFilterModel {
  final String? searchQuery;
  final int? severityId;
  final int? exposureRouteId;
  final int? paginationCount;
  
  ReactionFilterModel({
    this.searchQuery,
    this.severityId,
    this.exposureRouteId,
    this.paginationCount,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      map['search_query'] = searchQuery;
    }

    if (severityId != null) {
      map['severity_id'] = severityId;
    }

    if (exposureRouteId != null) {
      map['exposure_route_id'] = exposureRouteId;
    }

    if (paginationCount != null) {
      map['pagination_count'] = paginationCount;
    }


    return map;
  }

  ReactionFilterModel copyWith({
    String? searchQuery,
    int? severityId,
    int? exposureRouteId,
    int? paginationCount,

  }) {
    return ReactionFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      severityId: severityId ?? this.severityId,
      exposureRouteId: exposureRouteId ?? this.exposureRouteId,
      paginationCount: paginationCount ?? this.paginationCount,
    );
  }
}