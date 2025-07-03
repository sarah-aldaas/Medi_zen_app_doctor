part of 'medication_cubit.dart';

@immutable
sealed class MedicationState {
  const MedicationState();
}

final class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {
  final bool isLoadMore;

  const MedicationLoading({this.isLoadMore = false});
}

class MedicationSuccess extends MedicationState {
  final bool hasMore;
  final PaginatedResponse<MedicationModel> paginatedResponse;

  const MedicationSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class MedicationDetailsSuccess extends MedicationState {
  final MedicationModel medication;

  const MedicationDetailsSuccess({
    required this.medication,
  });
}

class MedicationRequestSuccess extends MedicationState {
  final List<MedicationModel> medications;

  const MedicationRequestSuccess({
    required this.medications,
  });
}

class MedicationCreated extends MedicationState {
  final String message;

  const MedicationCreated({required this.message});
}

class MedicationUpdated extends MedicationState {
  final String message;

  const MedicationUpdated({required this.message});
}

class MedicationDeleted extends MedicationState {
  final String message;

  const MedicationDeleted({required this.message});
}

class MedicationStatusChanged extends MedicationState {
  final String message;

  const MedicationStatusChanged({required this.message});
}

class MedicationError extends MedicationState {
  final String error;

  const MedicationError({required this.error});
}