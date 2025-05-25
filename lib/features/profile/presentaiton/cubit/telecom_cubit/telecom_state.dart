part of 'telecom_cubit.dart';

abstract class TelecomState {}

class TelecomInitial extends TelecomState {}

class TelecomLoading extends TelecomState {}

class TelecomSuccess extends TelecomState {
  final PaginatedResponse<TelecomModel> paginatedResponse;
  final int currentPage;

  TelecomSuccess({
    required this.paginatedResponse,
    this.currentPage = 1,
  });
}
class TelecomError extends TelecomState {
  final String error;

  TelecomError({required this.error});
}