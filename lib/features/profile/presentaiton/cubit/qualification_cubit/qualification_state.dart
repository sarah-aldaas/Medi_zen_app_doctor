part of 'qualification_cubit.dart';

abstract class QualificationState {}

class QualificationInitial extends QualificationState {}

class QualificationLoading extends QualificationState {}
class QualificationDeleteSuccess extends QualificationState {}

class QualificationSuccess extends QualificationState {
  final PaginatedResponse<QualificationModel> paginatedResponse;
  final int currentPage;

  QualificationSuccess({
    required this.paginatedResponse,
    this.currentPage = 1,
  });
}

class QualificationError extends QualificationState {
  final String error;

  QualificationError({required this.error});
}