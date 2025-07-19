import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/data/models/public_response_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../../encounters/data/models/encounter_model.dart';
import '../../../../service_request/data/models/service_request_model.dart';
import '../../../data/data_source/condition_remote_data_source.dart';
import '../../../data/models/conditions_model.dart';

part 'conditions_state.dart';

class ConditionsCubit extends Cubit<ConditionsState> {
  final ConditionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ConditionsCubit({required this.remoteDataSource, required this.networkInfo})
      : super(ConditionsInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ConditionsModel> _allConditions = [];

  Future<void> getAllConditions({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required String patientId,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allConditions = [];
      emit(ConditionsLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }



    final result = await remoteDataSource.getAllConditions(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId,
    );

    if (result is Success<PaginatedResponse<ConditionsModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allConditions.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ConditionsSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<ConditionsModel>(
            paginatedData: PaginatedData<ConditionsModel>(items: _allConditions),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(ConditionsError(error: result.data.msg ?? 'Failed to fetch conditions'));
      }
    } else if (result is ResponseError<PaginatedResponse<ConditionsModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch conditions'));
    }
  }

  Future<void> getConditionsForAppointment({
    required String appointmentId,
    required String patientId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allConditions = [];
      emit(ConditionsLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllConditionForAppointment(
      appointmentId: appointmentId,
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ConditionsModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allConditions.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ConditionsSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<ConditionsModel>(
            paginatedData: PaginatedData<ConditionsModel>(items: _allConditions),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(ConditionsError(error: result.data.msg ?? 'Failed to fetch conditions'));
      }
    } else if (result is ResponseError<PaginatedResponse<ConditionsModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch conditions'));
    }
  }

  Future<void> getConditionDetails({
    required String conditionId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());



    final result = await remoteDataSource.getDetailsConditions(
      conditionId: conditionId,
      patientId: patientId,
    );

    if (result is Success<ConditionsModel>) {
      if (result.data.healthIssue == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ConditionDetailsSuccess(condition: result.data));
    } else if (result is ResponseError<ConditionsModel>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch condition details'));
    }
  }

  Future<void> createCondition({
    required ConditionsModel condition,
    required String patientId,
    required String appointmentId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());


        try{
      final result = await remoteDataSource.createConditions(
        condition: condition,
        patientId: patientId,
        appointmentId: appointmentId,
      );

      if (result is Success<PublicResponseModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.login.name);
        }
        if (result.data.status) {
          emit(ConditionCreatedSuccess(message: result.data.msg));
          ShowToast.showToastSuccess(message: result.data.msg);
        }
        else {
          emit(ConditionsError(error: result.data.msg));
          ShowToast.showToastError(message: result.data.msg);
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        emit(ConditionsError(error: result.message ?? 'Failed to create condition'));
        ShowToast.showToastError(message: result.message ?? 'Failed to create condition');
      }
    }catch(e){
          emit(ConditionsError(error: e.toString() ?? 'Failed to create condition'));
          ShowToast.showToastError(message: e.toString() ?? 'Failed to create condition');

        }
  }

  Future<void> updateCondition({
    required ConditionsModel condition,
    required String conditionId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());


    try{
      final result = await remoteDataSource.updateConditions(
        condition: condition,
        conditionId: conditionId,
        patientId: patientId,
      );

      if (result is Success<PublicResponseModel>) {
        if (result.data.msg == "Unauthorized. Please login first.") {
          context.pushReplacementNamed(AppRouter.login.name);
        }
        if (result.data.status) {
          emit(ConditionUpdatedSuccess(message: result.data.msg));
          ShowToast.showToastSuccess(message: result.data.msg);
        } else {
          emit(ConditionsError(error: result.data.msg ?? 'Failed to update condition'));
          ShowToast.showToastError(message: result.data.msg ?? 'Failed to update condition');
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        emit(ConditionsError(error: result.message ?? 'Failed to update condition'));
        ShowToast.showToastError(message: result.message ?? 'Failed to update condition');
      }
    }catch(e){
      emit(ConditionsError(error: e.toString() ?? 'Failed to update condition'));
      ShowToast.showToastError(message: e.toString() ?? 'Failed to update condition');

    }
  }

  Future<void> deleteCondition({
    required String conditionId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());



    final result = await remoteDataSource.deleteConditions(
      conditionId: conditionId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ConditionDeletedSuccess(message: result.data.msg));
      ShowToast.showToastSuccess(message: result.data.msg);
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ConditionsError(error: result.message ?? 'Failed to delete condition'));
      ShowToast.showToastError(message: result.message ?? 'Failed to delete condition');
    }
  }

  Future<void> getCombinedServiceRequests({
    required String patientId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      emit(ServiceRequestsLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    try {
      // Make both API calls concurrently
      final results = await Future.wait([
        remoteDataSource.getAllObservationServiceRequest(
          patientId: patientId,
          filters: _currentFilters,
          page: _currentPage,
          perPage: 10,
        ),
        remoteDataSource.getAllImagingStudyServiceRequest(
          patientId: patientId,
          filters: _currentFilters,
          page: _currentPage,
          perPage: 10,
        ),
      ]);

      final observationResult = results[0];
      final imagingResult = results[1];

      // Handle errors first
      if (observationResult is ResponseError<PaginatedResponse<ServiceRequestModel>> || imagingResult is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
        final errorMessage = observationResult is ResponseError<PaginatedResponse<ServiceRequestModel>>
            ? observationResult.message
            :imagingResult is ResponseError<PaginatedResponse<ServiceRequestModel>>? imagingResult.message:"some thing is wrong";
        emit(ConditionsError(
            error: errorMessage ?? 'Failed to fetch service requests'
        ));
        return;
      }

      // Check for unauthorized
      if ((observationResult as Success).data.msg == "Unauthorized. Please login first." ||
          (imagingResult as Success).data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
        return;
      }

      // Combine the results
      final combinedList = [
        ...(observationResult as Success<PaginatedResponse<ServiceRequestModel>>).data.paginatedData!.items,
        ...(imagingResult as Success<PaginatedResponse<ServiceRequestModel>>).data.paginatedData!.items,
      ];

      // Determine if there's more data
      final hasMoreData = combinedList.isNotEmpty &&
          ((observationResult).data.meta!.currentPage < (observationResult).data.meta!.lastPage ||
              (imagingResult).data.meta!.currentPage < (imagingResult).data.meta!.lastPage);

      emit(ServiceRequestsLoaded(
        serviceRequests: combinedList,
        hasMore: hasMoreData,
      ));

      _currentPage++;
    } catch (e) {
      emit(ConditionsError(error: 'An error occurred while fetching service requests'));
    }
  }
  // Future<void> getObservationServiceRequests({
  //   required String patientId,
  //   Map<String, dynamic>? filters,
  //   bool loadMore = false,
  //   required BuildContext context,
  // }) async {
  //   if (!loadMore) {
  //     _currentPage = 1;
  //     _hasMore = true;
  //     emit(ServiceRequestsLoading());
  //   } else if (!_hasMore) {
  //     return;
  //   }
  //
  //   if (filters != null) {
  //     _currentFilters = filters;
  //   }
  //
  //   // final isConnected = await networkInfo.isConnected;
  //   // if (!isConnected) {
  //   //   context.pushNamed('noInternet');
  //   //   emit(ConditionsError(error: 'No internet connection'));
  //   //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
  //   //   return;
  //   // }
  //
  //   final result = await remoteDataSource.getAllObservationServiceRequest(
  //     patientId: patientId,
  //     filters: _currentFilters,
  //     page: _currentPage,
  //     perPage: 10,
  //   );
  //
  //   if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
  //     if (result.data.msg == "Unauthorized. Please login first.") {
  //       context.pushReplacementNamed(AppRouter.login.name);
  //     }
  //     emit(ServiceRequestsLoaded(
  //       serviceRequests: result.data.paginatedData!.items,
  //       hasMore: result.data.paginatedData!.items.isNotEmpty &&
  //           result.data.meta!.currentPage < result.data.meta!.lastPage,
  //     ));
  //     _currentPage++;
  //   } else if (result is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
  //     emit(ConditionsError(error: result.message ?? 'Failed to fetch observation service requests'));
  //   }
  // }

  // Future<void> getImagingStudyServiceRequests({
  //   required String patientId,
  //   Map<String, dynamic>? filters,
  //   bool loadMore = false,
  //   required BuildContext context,
  // }) async {
  //   if (!loadMore) {
  //     _currentPage = 1;
  //     _hasMore = true;
  //     emit(ServiceRequestsLoading());
  //   } else if (!_hasMore) {
  //     return;
  //   }
  //
  //   if (filters != null) {
  //     _currentFilters = filters;
  //   }
  //
  //   // final isConnected = await networkInfo.isConnected;
  //   // if (!isConnected) {
  //   //   context.pushNamed('noInternet');
  //   //   emit(ConditionsError(error: 'No internet connection'));
  //   //   ShowToast.showToastError(message: 'No internet connection. Please check your network.');
  //   //   return;
  //   // }
  //
  //   final resultImagingStudy = await remoteDataSource.getAllImagingStudyServiceRequest(
  //     patientId: patientId,
  //     filters: _currentFilters,
  //     page: _currentPage,
  //     perPage: 10,
  //   );
  //
  //   final resultObservation = await remoteDataSource.getAllObservationServiceRequest(
  //     patientId: patientId,
  //     filters: _currentFilters,
  //     page: _currentPage,
  //     perPage: 10,
  //   );
  //
  //   if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
  //     if (result.data.msg == "Unauthorized. Please login first.") {
  //       context.pushReplacementNamed(AppRouter.login.name);
  //     }
  //     emit(ServiceRequestsLoaded(
  //       observationServiceRequests: resultObservation.data.paginatedData!.items,
  //       hasMore: result.data.paginatedData!.items.isNotEmpty &&
  //           result.data.meta!.currentPage < result.data.meta!.lastPage,
  //     ));
  //     _currentPage++;
  //   } else if (result is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
  //     emit(ConditionsError(error: result.message ?? 'Failed to fetch imaging study service requests'));
  //   }
  // }

  Future<void> getLast10Encounters({
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());



    final result = await remoteDataSource.getLast10Encounters(patientId: patientId);

    if (result is Success<List<EncounterModel>>) {
      emit(Last10EncountersLoaded(encounters: result.data));
    } else if (result is ResponseError<List<EncounterModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch last 10 encounters'));
    }
  }
  Future<void> getConditionCodeTypes({
    required BuildContext context,
  }) async {
    final codeTypesCubit = context.read<CodeTypesCubit>();
    await Future.wait([
      codeTypesCubit.getBodySiteCodes(context: context),
      codeTypesCubit.getConditionClinicalStatusTypeCodes(context: context),
      codeTypesCubit.getConditionVerificationStatusTypeCodes(context: context),
      codeTypesCubit.getConditionStageTypeCodes(context: context),
    ]);
  }
}