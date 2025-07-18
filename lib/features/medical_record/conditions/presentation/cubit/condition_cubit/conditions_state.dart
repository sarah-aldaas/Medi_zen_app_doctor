part of 'conditions_cubit.dart';

sealed class ConditionsState {
  const ConditionsState();
}

final class ConditionsInitial extends ConditionsState {}

class ConditionsLoading extends ConditionsState {
  final bool isLoadMore;

  const ConditionsLoading({this.isLoadMore = false});
}

class ConditionsSuccess extends ConditionsState {
  final bool hasMore;
  final PaginatedResponse<ConditionsModel> paginatedResponse;

  const ConditionsSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class ConditionDetailsSuccess extends ConditionsState {
  final ConditionsModel condition;

  const ConditionDetailsSuccess({
    required this.condition,
  });
}

class ConditionCreatedSuccess extends ConditionsState {
  final String message;

  const ConditionCreatedSuccess({
    required this.message,
  });
}

class ConditionUpdatedSuccess extends ConditionsState {
  final String message;

  const ConditionUpdatedSuccess({
    required this.message,
  });
}

class ConditionDeletedSuccess extends ConditionsState {
  final String message;

  const ConditionDeletedSuccess({
    required this.message,
  });
}

class ServiceRequestsLoading extends ConditionsState {}

class ServiceRequestsLoaded extends ConditionsState {
  final List<ServiceRequestModel> serviceRequests;
  final bool hasMore;

  const ServiceRequestsLoaded({
    required this.serviceRequests,
    required this.hasMore,
  });
}
class ObservationServiceRequestsLoaded extends ConditionsState {
  final List<ServiceRequestModel> serviceRequests;
  final bool hasMore;

  const ObservationServiceRequestsLoaded({
    required this.serviceRequests,
    required this.hasMore,
  });
}

class ImagingStudyServiceRequestsLoaded extends ConditionsState {
  final List<ServiceRequestModel> serviceRequests;
  final bool hasMore;

  const ImagingStudyServiceRequestsLoaded({
    required this.serviceRequests,
    required this.hasMore,
  });
}

class Last10EncountersLoaded extends ConditionsState {
  final List<EncounterModel> encounters;

  const Last10EncountersLoaded({
    required this.encounters,
  });
}

class ConditionsError extends ConditionsState {
  final String error;

  const ConditionsError({required this.error});
}