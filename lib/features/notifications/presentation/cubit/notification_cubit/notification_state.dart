part of 'notification_cubit.dart';

@immutable
sealed class NotificationState {
  const NotificationState();
}

final class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {
  final bool isLoadMore;

  const NotificationLoading({this.isLoadMore = false});
}

class NotificationOperationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final bool hasMore;
  final PaginatedResponse<NotificationModel> paginatedResponse;

  const NotificationSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class FCMOperationSuccess extends NotificationState {
  final PublicResponseModel response;

  const FCMOperationSuccess({
    required this.response,
  });
}

class NotificationError extends NotificationState {
  final String error;

  const NotificationError({required this.error});
}