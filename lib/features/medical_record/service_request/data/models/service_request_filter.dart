import 'package:intl/intl.dart';

class ServiceRequestFilter {
  final String? statusId;
  final String? categoryId;
  final String? bodySiteId;
  final String? healthCareServiceId;
  final String? priorityId;

  ServiceRequestFilter({
    this.statusId,
    this.categoryId,
    this.bodySiteId,
    this.healthCareServiceId,
    this.priorityId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (statusId != null) 'status_id': statusId,
      if (categoryId != null) 'category_id': categoryId,
      if (bodySiteId != null) 'body_site_id': bodySiteId,
      if (healthCareServiceId != null) 'health_care_service_id': healthCareServiceId,
      if (priorityId != null) 'priority_id': priorityId,
    };}

  ServiceRequestFilter copyWith({
    String? statusId,
    String? categoryId,
    String? bodySiteId,
    String? healthCareServiceId,
    String? priorityId,

  }) {
    return ServiceRequestFilter(
      statusId: statusId ?? this.statusId,
      categoryId: categoryId ?? this.categoryId,
      bodySiteId: bodySiteId ?? this.bodySiteId,
      healthCareServiceId: healthCareServiceId ?? this.healthCareServiceId,
      priorityId: priorityId ?? this.priorityId,
    );
  }
}