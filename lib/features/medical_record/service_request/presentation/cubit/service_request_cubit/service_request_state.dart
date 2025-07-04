part of 'service_request_cubit.dart';

abstract class ServiceRequestState extends Equatable {
  const ServiceRequestState();

  @override
  List<Object> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {
  final bool isLoadMore;
  final bool isDetailsLoading;

  const ServiceRequestLoading({
    this.isLoadMore = false,
    this.isDetailsLoading = false,
  });

  @override
  List<Object> get props => [isLoadMore, isDetailsLoading];
}

class ServiceRequestLoaded extends ServiceRequestState {
  final PaginatedResponse<ServiceRequestModel>? paginatedResponse;
  final ServiceRequestModel? serviceRequestDetails;
  final bool hasMore;

  const ServiceRequestLoaded({
    this.paginatedResponse,
    this.serviceRequestDetails,
    required this.hasMore,
  });

  @override
  List<Object> get props => [
    paginatedResponse ?? Object(),
    serviceRequestDetails ?? Object(),
    hasMore,
  ];
}

class ServiceRequestCreated extends ServiceRequestState {
  final String message;

  const ServiceRequestCreated({required this.message});

  @override
  List<Object> get props => [message];
}

class ServiceRequestUpdated extends ServiceRequestState {
  final String message;

  const ServiceRequestUpdated({required this.message});

  @override
  List<Object> get props => [message];
}

class ServiceRequestDeleted extends ServiceRequestState {
  final String message;

  const ServiceRequestDeleted({required this.message});

  @override
  List<Object> get props => [message];
}

class ServiceRequestStatusChanged extends ServiceRequestState {
  final String message;

  const ServiceRequestStatusChanged({required this.message});

  @override
  List<Object> get props => [message];
}

class ServiceRequestError extends ServiceRequestState {
  final String message;

  const ServiceRequestError(this.message);

  @override
  List<Object> get props => [message];
}