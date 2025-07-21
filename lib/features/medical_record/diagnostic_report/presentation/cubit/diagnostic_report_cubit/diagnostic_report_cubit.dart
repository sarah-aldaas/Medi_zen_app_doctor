import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../data/data_source/diagnostic_report_remote_datasource.dart';
import '../../../data/models/diagnostic_report_model.dart';

part 'diagnostic_report_state.dart';

class DiagnosticReportCubit extends Cubit<DiagnosticReportState> {
  final DiagnosticReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DiagnosticReportCubit({required this.remoteDataSource, required this.networkInfo})
      : super(DiagnosticReportInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<DiagnosticReportModel> _allDiagnosticReports = [];

  Future<void> getAllDiagnosticReports({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
    required String patientId
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allDiagnosticReports = [];
      emit(DiagnosticReportLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }
    final result = await remoteDataSource.getAllDiagnosticReport(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId
    );

    if (result is Success<PaginatedResponse<DiagnosticReportModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allDiagnosticReports.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(DiagnosticReportSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<DiagnosticReportModel>(
            paginatedData: PaginatedData<DiagnosticReportModel>(items: _allDiagnosticReports),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(DiagnosticReportError(error: result.data.msg ?? 'Failed to fetch diagnostic reports'));
      }
    } else if (result is ResponseError<PaginatedResponse<DiagnosticReportModel>>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic reports'));
    }
  }

  Future<void> getDiagnosticReportsForAppointment({
    required String appointmentId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
    required String patientId,
    required String conditionId,

  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allDiagnosticReports = [];
      emit(DiagnosticReportLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAllDiagnosticReportOfAppointment(
      appointmentId: appointmentId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 10,
      patientId: patientId, conditionId: conditionId
    );

    if (result is Success<PaginatedResponse<DiagnosticReportModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allDiagnosticReports.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(DiagnosticReportSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<DiagnosticReportModel>(
            paginatedData: PaginatedData<DiagnosticReportModel>(items: _allDiagnosticReports),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(DiagnosticReportError(error: result.data.msg ?? 'Failed to fetch diagnostic reports'));
      }
    } else if (result is ResponseError<PaginatedResponse<DiagnosticReportModel>>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic reports'));
    }
  }

  Future<void> getDiagnosticReportDetails({
    required String diagnosticReportId,
    required BuildContext context,
    required String patientId,
  }) async {
    emit(DiagnosticReportLoading());

    final result = await remoteDataSource.getDetailsDiagnosticReport(diagnosticReportId: diagnosticReportId,patientId: patientId);
    if (result is Success<DiagnosticReportModel>) {
      if (result.data.name == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(DiagnosticReportDetailsSuccess(diagnosticReport: result.data));
    } else if (result is ResponseError<DiagnosticReportModel>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic report details'));
    }
  }

  Future<void> getDiagnosticReportForCondition({
    required String conditionId,
    required BuildContext context,
    required String patientId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allDiagnosticReports = [];
      emit(DiagnosticReportLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }
    final result = await remoteDataSource.getDiagnosticReportOfCondition(
        filters: _currentFilters,
        page: _currentPage,
        perPage: 10,
        patientId: patientId,
        conditionId: conditionId
    );

    if (result is Success<PaginatedResponse<DiagnosticReportModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allDiagnosticReports.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(DiagnosticReportSuccess(
          hasMore: _hasMore,
          paginatedResponse: PaginatedResponse<DiagnosticReportModel>(
            paginatedData: PaginatedData<DiagnosticReportModel>(items: _allDiagnosticReports),
            meta: result.data.meta,
            links: result.data.links,
          ),
        ));
      } catch (e) {
        emit(DiagnosticReportError(error: result.data.msg ?? 'Failed to fetch diagnostic reports'));
      }
    } else if (result is ResponseError<PaginatedResponse<DiagnosticReportModel>>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic reports'));
    }
  }



  Future<void> makeAsFinalDiagnosticReport({
    required String diagnosticReportId,
    required BuildContext context,
    required String patientId,
    required String conditionId,
  }) async {
    emit(DiagnosticReportLoading());
    final result = await remoteDataSource.makeAsFinalDiagnosticReport(patientId: patientId,diagnosticReportId: diagnosticReportId,conditionId: conditionId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if(result.data.status) {
        emit(DiagnosticReportOperationSuccess());
      }else{
        emit(DiagnosticReportError(error: result.data.msg));

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic report for condition'));
    }
  }
  Future<void> deleteDiagnosticReport({
    required String diagnosticReportId,
    required BuildContext context,
    required String patientId,
    required String conditionId,
  }) async {
    emit(DiagnosticReportLoading());
    final result = await remoteDataSource.deleteDiagnosticReport(patientId: patientId,diagnosticReportId: diagnosticReportId,conditionId: conditionId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if(result.data.status) {
        emit(DiagnosticReportOperationSuccess());
      }else{
        emit(DiagnosticReportError(error: result.data.msg));

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic report for condition'));
    }
  }

  Future<void> createDiagnosticReport({
    required DiagnosticReportModel diagnosticReport,
    required BuildContext context,
    required String patientId,
    required String conditionId,
    required String appointmentId,
  }) async {
    emit(DiagnosticReportLoading());
    final result = await remoteDataSource.createDiagnosticReport(patientId: patientId,diagnostic: diagnosticReport,conditionId: conditionId,appointmentId: appointmentId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if(result.data.status) {
        emit(DiagnosticReportOperationSuccess());
      }else{
        emit(DiagnosticReportError(error: result.data.msg));

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic report for condition'));
    }
  }

  Future<void> updateDiagnosticReport({
    required DiagnosticReportModel diagnosticReport,
    required BuildContext context,
    required String patientId,
    required String conditionId,
    required String diagnosticReportId,
  }) async {
    emit(DiagnosticReportLoading());
    final result = await remoteDataSource.updateDiagnosticReport(patientId: patientId,diagnostic: diagnosticReport,diagnosticReportId: diagnosticReportId,conditionId: conditionId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      if(result.data.status) {
        emit(DiagnosticReportOperationSuccess());
      }else{
        emit(DiagnosticReportError(error: result.data.msg));

      }
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(DiagnosticReportError(error: result.message ?? 'Failed to fetch diagnostic report for condition'));
    }
  }
}