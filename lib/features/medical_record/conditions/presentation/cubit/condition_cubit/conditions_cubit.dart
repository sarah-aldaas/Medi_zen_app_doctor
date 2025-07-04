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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

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
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.createConditions(
      condition: condition,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ConditionCreatedSuccess(message: result.data.msg));
      ShowToast.showToastSuccess(message: result.data.msg);
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ConditionsError(error: result.message ?? 'Failed to create condition'));
      ShowToast.showToastError(message: result.message ?? 'Failed to create condition');
    }
  }

  Future<void> updateCondition({
    required ConditionsModel condition,
    required String conditionId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.updateConditions(
      condition: condition,
      conditionId: conditionId,
      patientId: patientId,
    );

    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ConditionUpdatedSuccess(message: result.data.msg));
      ShowToast.showToastSuccess(message: result.data.msg);
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(ConditionsError(error: result.message ?? 'Failed to update condition'));
      ShowToast.showToastError(message: result.message ?? 'Failed to update condition');
    }
  }

  Future<void> deleteCondition({
    required String conditionId,
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

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

  Future<void> getObservationServiceRequests({
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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getAllObservationServiceRequest(
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ObservationServiceRequestsLoaded(
        serviceRequests: result.data.paginatedData!.items,
        hasMore: result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage,
      ));
      _currentPage++;
    } else if (result is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch observation service requests'));
    }
  }

  Future<void> getImagingStudyServiceRequests({
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

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

    final result = await remoteDataSource.getAllImagingStudyServiceRequest(
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
    );

    if (result is Success<PaginatedResponse<ServiceRequestModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ImagingStudyServiceRequestsLoaded(
        serviceRequests: result.data.paginatedData!.items,
        hasMore: result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage,
      ));
      _currentPage++;
    } else if (result is ResponseError<PaginatedResponse<ServiceRequestModel>>) {
      emit(ConditionsError(error: result.message ?? 'Failed to fetch imaging study service requests'));
    }
  }

  Future<void> getLast10Encounters({
    required String patientId,
    required BuildContext context,
  }) async {
    emit(ConditionsLoading());

    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed('noInternet');
      emit(ConditionsError(error: 'No internet connection'));
      ShowToast.showToastError(message: 'No internet connection. Please check your network.');
      return;
    }

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