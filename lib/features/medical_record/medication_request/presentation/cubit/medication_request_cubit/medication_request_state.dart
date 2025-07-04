part of 'medication_request_cubit.dart';

@immutable
sealed class MedicationRequestState {
  const MedicationRequestState();
}

final class MedicationRequestInitial extends MedicationRequestState {}

class MedicationRequestLoading extends MedicationRequestState {
  final bool isLoadMore;

  const MedicationRequestLoading({this.isLoadMore = false});
}

class MedicationRequestSuccess extends MedicationRequestState {
  final bool hasMore;
  final PaginatedResponse<MedicationRequestModel> paginatedResponse;

  const MedicationRequestSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class MedicationRequestDetailsSuccess extends MedicationRequestState {
  final MedicationRequestModel medicationRequest;

  const MedicationRequestDetailsSuccess({
    required this.medicationRequest,
  });
}

class MedicationRequestForConditionSuccess extends MedicationRequestState {
  final MedicationRequestModel medicationRequest;

  const MedicationRequestForConditionSuccess({
    required this.medicationRequest,
  });
}

class MedicationRequestCreated extends MedicationRequestState {
  final String message;

  const MedicationRequestCreated({required this.message});
}

class MedicationRequestUpdated extends MedicationRequestState {
  final String message;

  const MedicationRequestUpdated({required this.message});
}

class MedicationRequestDeleted extends MedicationRequestState {
  final String message;

  const MedicationRequestDeleted({required this.message});
}

class MedicationRequestStatusChanged extends MedicationRequestState {
  final String message;

  const MedicationRequestStatusChanged({required this.message});
}

class MedicationRequestError extends MedicationRequestState {
  final String error;

  const MedicationRequestError({required this.error});
}