part of 'service_cubit.dart';

@immutable
sealed class ServiceState {}

final class ServiceInitial extends ServiceState {}

class ServiceHealthCareLoading extends ServiceState {
  final bool isLoadMore;

   ServiceHealthCareLoading({this.isLoadMore = false});
}

class ServiceHealthCareSuccess extends ServiceState {
  final PaginatedResponse<HealthCareServiceModel> paginatedResponse;
  final bool hasMore;

  ServiceHealthCareSuccess({required this.paginatedResponse, required this.hasMore});
}

class ServiceHealthCareModelSuccess extends ServiceState {
  final HealthCareServiceModel healthCareServiceModel;

  ServiceHealthCareModelSuccess({required this.healthCareServiceModel});
}

class ServiceHealthCareError extends ServiceState {
  final String error;

  ServiceHealthCareError({required this.error});
}

// class ServiceHealthCareEligibilityLoading extends ServiceState {}
//
// class ServiceHealthCareEligibilitySuccess extends ServiceState {
//   final PaginatedResponse<HealthCareServiceEligibilityCodesModel> paginatedResponse;
//   final List<HealthCareServiceEligibilityCodesModel> allEligibilityCodes;
//   final bool hasMore;
//
//   ServiceHealthCareEligibilitySuccess({
//     required this.paginatedResponse,
//     required this.allEligibilityCodes,
//     required this.hasMore,
//   });
// }
//
// class ServiceHealthCareEligibilityError extends ServiceState {
//   final String error;
//
//   ServiceHealthCareEligibilityError({required this.error});
// }
