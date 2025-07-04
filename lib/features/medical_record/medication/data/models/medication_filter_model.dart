import 'package:intl/intl.dart';

class MedicationFilterModel {
  final String? searchQuery;
  final String? statusId;
  final String? doseForm;
  final String? routeId;
  final String? siteId;
  final bool? asNeeded;
  final String? medicationRequestId;
  final DateTime? startFrom;
  final DateTime? endUntil;

  MedicationFilterModel({
    this.searchQuery,
    this.statusId,
    this.doseForm,
    this.routeId,
    this.siteId,
    this.asNeeded,
    this.medicationRequestId,
    this.startFrom,
    this.endUntil,
  });

  Map<String, dynamic> toJson() {
    return {
      if (searchQuery != null && searchQuery!.isNotEmpty)
        'search_query': searchQuery,
      if (statusId != null) 'status_id': statusId,
      if (doseForm != null) 'dose_form': doseForm,
      if (routeId != null) 'route_id': routeId,
      if (siteId != null) 'site_id': siteId,
      if (asNeeded != null) 'as_needed': asNeeded! ? 1 : 0,
      if (medicationRequestId != null) 'medication_request_id': medicationRequestId,
      if (startFrom != null) 'start_from': DateFormat('yyyy-MM-dd').format(startFrom!),
      if (endUntil != null) 'end_until': DateFormat('yyyy-MM-dd').format(endUntil!),
    };
  }

  MedicationFilterModel copyWith({
    String? searchQuery,
    String? statusId,
    String? doseForm,
    String? routeId,
    String? siteId,
    bool? asNeeded,
    String? medicationRequestId,
    DateTime? startFrom,
    DateTime? endUntil,
  }) {
    return MedicationFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      statusId: statusId ?? this.statusId,
      doseForm: doseForm ?? this.doseForm,
      routeId: routeId ?? this.routeId,
      siteId: siteId ?? this.siteId,
      asNeeded: asNeeded ?? this.asNeeded,
      medicationRequestId: medicationRequestId ?? this.medicationRequestId,
      startFrom: startFrom ?? this.startFrom,
      endUntil: endUntil ?? this.endUntil,
    );
  }
}