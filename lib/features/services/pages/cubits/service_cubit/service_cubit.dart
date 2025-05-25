import 'package:bloc/bloc.dart';
import 'package:medi_zen_app_doctor/features/services/data/datasources/services_remote_datasoources.dart';
import 'package:medi_zen_app_doctor/features/services/data/model/health_care_services_model.dart';
import 'package:meta/meta.dart';
import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/model/health_care_service_filter.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServicesRemoteDataSource remoteDataSource;
  int _currentPage = 1;
  bool _hasMore = true;
  bool isLoading = false;
  List<HealthCareServiceModel> _allServices = [];
  HealthCareServiceFilter _currentFilter = HealthCareServiceFilter();

  ServiceCubit({required this.remoteDataSource}) : super(ServiceInitial());

  // Future<void> getAllServiceHealthCare({bool loadMore = false, HealthCareServiceFilter? filter}) async {
  //   if (isLoading || (!loadMore && _allServices.isNotEmpty)) return;
  //   isLoading = true;
  //
  //   if (!loadMore) {
  //     _currentPage = 1;
  //     _hasMore = true;
  //     _allServices.clear();
  //     emit(ServiceHealthCareLoading());
  //   }
  //
  //   if (filter != null) {
  //     _currentFilter = filter;
  //   }
  //
  //   // Convert filter to query parameters
  //   final queryParams = _currentFilter.toJson();
  //   queryParams['page'] = _currentPage;
  //   queryParams['pagination_count'] = _currentFilter.paginationCount ?? 10;
  //
  //   try {
  //     final result = await remoteDataSource.getAllHealthCareServices(
  //       page: _currentPage,
  //       perPage: _currentFilter.paginationCount ?? 10,
  //       filters: queryParams, // Pass the complete query parameters
  //     );
  //     if (result is Success<PaginatedResponse<HealthCareServiceModel>>) {
  //       final newServices = result.data.paginatedData?.items ?? [];
  //       _allServices.addAll(newServices);
  //
  //       final totalPages = result.data.meta?.lastPage ?? 1;
  //       _hasMore = _currentPage < totalPages;
  //
  //       if (loadMore) {
  //         _currentPage++;
  //       } else {
  //         _currentPage = 2; // Set to 2 because we already loaded page 1
  //       }
  //
  //       emit(ServiceHealthCareSuccess(
  //         paginatedResponse: result.data,
  //         allServices: _allServices,
  //         hasMore: _hasMore,
  //       ));
  //     } else if (result is ResponseError<PaginatedResponse<HealthCareServiceModel>>) {
  //       emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care services'));
  //     }
  //
  //     // ... rest of your existing code ...
  //   } finally {
  //     isLoading = false;
  //   }
  // }


  Map<String, dynamic> _currentFilters = {};
  List<HealthCareServiceModel> allServices = [];

  Future<void> getAllServiceHealthCare({Map<String, dynamic>? filters, bool loadMore = false}) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      allServices = [];
      emit(ServiceHealthCareLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllHealthCareServices(filters: _currentFilters, page: _currentPage, perPage: 5);

    if (result is Success<PaginatedResponse<HealthCareServiceModel>>) {
      try {
        allServices.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ServiceHealthCareSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<HealthCareServiceModel>(
              paginatedData: PaginatedData<HealthCareServiceModel>(items: allServices),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      }catch(e){
        emit(ServiceHealthCareError(error:result.data.msg ?? 'Failed to fetch Appointments'));

      }
    } else if (result is ResponseError<PaginatedResponse<HealthCareServiceModel>>) {
      emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch Appointments'));
    }
  }


  // Future<void> getAllServiceHealthCare({bool loadMore = false, HealthCareServiceFilter? filter}) async {
  //   if (isLoading || (!loadMore && _allServices.isNotEmpty)) return;
  //   isLoading = true;
  //
  //   if (!loadMore) {
  //     _currentPage = 1;
  //     _hasMore = true;
  //     _allServices.clear();
  //     emit(ServiceHealthCareLoading());
  //   }
  //
  //   if (filter != null) {
  //     _currentFilter = filter;
  //   }
  //
  //   try {
  //     final result = await remoteDataSource.getAllHealthCareServices(
  //       page: _currentPage,
  //       perPage: _currentFilter.paginationCount ?? 10,
  //       filters: _currentFilter.toJson(),
  //     );
  //
  //     if (result is Success<PaginatedResponse<HealthCareServiceModel>>) {
  //       final newServices = result.data.paginatedData?.items ?? [];
  //       _allServices.addAll(newServices);
  //
  //       final totalPages = result.data.meta?.lastPage ?? 1;
  //       _hasMore = _currentPage < totalPages;
  //
  //       if (loadMore) {
  //         _currentPage++;
  //       } else {
  //         _currentPage = 2; // Set to 2 because we already loaded page 1
  //       }
  //
  //       emit(ServiceHealthCareSuccess(
  //         paginatedResponse: result.data,
  //         allServices: _allServices,
  //         hasMore: _hasMore,
  //       ));
  //     } else if (result is ResponseError<PaginatedResponse<HealthCareServiceModel>>) {
  //       emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care services'));
  //     }
  //   } finally {
  //     isLoading = false;
  //   }
  // }

  // When returning from details page, reload if needed
  void checkAndReload() {
    if (state is! ServiceHealthCareSuccess) {
      getAllServiceHealthCare();
    }
  }

  Future<void> getSpecificServiceHealthCare({required String id}) async {
    emit(ServiceHealthCareLoading());
    try {
      final result = await remoteDataSource.getSpecificHealthCareServices(id: id);
      if (result is Success<HealthCareServiceModel>) {
        emit(ServiceHealthCareModelSuccess(healthCareServiceModel: result.data));
      } else if (result is ResponseError<HealthCareServiceModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service details');
        emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service details'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ServiceHealthCareError(error: e.toString()));
    }
  }

// Future<void> getAllServiceHealthCareEligibility({bool loadMore = false}) async {
//   if (isLoadingEligibility || (!loadMore && allEligibilityCodes.isNotEmpty)) return;
//   isLoadingEligibility = true;
//
//   if (!loadMore) {
//     currentEligibilityPage = 1;
//     hasMoreEligibility = true;
//     allEligibilityCodes.clear();
//     emit(ServiceHealthCareEligibilityLoading());
//   }
//
//   try {
//     final result = await remoteDataSource.getAllHealthCareServiceEligibilityCodes(
//       page: currentEligibilityPage,
//       perPage: 10, // Set your desired page size
//     );
//
//     if (result is Success<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>) {
//       final newEligibilityCodes = result.data.paginatedData?.items ?? [];
//       allEligibilityCodes.addAll(newEligibilityCodes);
//
//       // Update pagination info
//       final totalPages = result.data.meta?.lastPage ?? 1;
//       hasMoreEligibility = currentEligibilityPage < totalPages;
//
//       // Only increment page if we're loading more
//       if (loadMore) {
//         currentEligibilityPage++;
//       } else {
//         // For initial load, set to page 2 since we already loaded page 1
//         currentEligibilityPage = 2;
//       }
//
//       emit(ServiceHealthCareEligibilitySuccess(
//         paginatedResponse: result.data,
//         allEligibilityCodes: allEligibilityCodes,
//         hasMore: hasMoreEligibility,
//       ));
//     } else if (result is ResponseError<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>) {
//       emit(ServiceHealthCareEligibilityError(error: result.message ?? 'Failed to fetch health care service eligibility codes'));
//     }
//   } finally {
//     isLoadingEligibility = false;
//   }
// }
  // Future<HealthCareServiceEligibilityCodesModel?> getSpecificServiceHealthCareEligibilityCodes({required String id}) async {
  //   emit(ServiceHealthCareEligibilityLoading());
  //   final result = await remoteDataSource.getSpecificHealthCareServiceEligibilityCodes(id: id);
  //   if (result is Success<HealthCareServiceEligibilityCodesModel>) {
  //     return result.data;
  //   } else if (result is ResponseError<HealthCareServiceEligibilityCodesModel>) {
  //     ShowToast.showToastError(message: result.message ?? 'Failed to fetch health care service eligibility codes details');
  //     emit(ServiceHealthCareError(error: result.message ?? 'Failed to fetch health care service eligibility codes details'));
  //     return null;
  //   } else {
  //     return null;
  //   }
  // }
}
