import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/features/appointment/data/models/appointment_model.dart';
import 'package:meta/meta.dart';
import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../data/data_source/appointments_remote_data_source.dart';


part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRemoteDataSource remoteDataSource;
  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<AppointmentModel> _allAppointments = [];

  AppointmentCubit({required this.remoteDataSource}) : super(AppointmentInitial());

  Future<void> getPatientAppointments({
    required String patientId,
    Map<String, dynamic>? filters,
    bool loadMore = false,required BuildContext context
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAppointments = [];
      emit(AppointmentLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getAppointmentsByPatient(
      patientId: patientId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 8,
    );

    if (result is Success<PaginatedResponse<AppointmentModel>>) {
      if(result.data.msg=="Unauthorized. Please login first."){
        context.pushReplacementNamed(AppRouter.login.name);

      }
      try {
        _allAppointments.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(AppointmentListSuccess(
          paginatedResponse: PaginatedResponse<AppointmentModel>(
            paginatedData: PaginatedData<AppointmentModel>(items: _allAppointments),
            meta: result.data.meta,
            links: result.data.links,
          ),
          hasMore: _hasMore,
        ));
      } catch (e) {
        emit(AppointmentError(error: result.data.msg ?? 'Error loading appointments'));
      }
    } else if (result is ResponseError<PaginatedResponse<AppointmentModel>>) {
      emit(AppointmentError(error: result.message ?? 'Error loading appointments'));
    }
  }

  Future<void> getMyAppointments({
    Map<String, dynamic>? filters,
    bool loadMore = false,required BuildContext context
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAppointments = [];
      emit(AppointmentLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.getMyAppointments(
      filters: _currentFilters,
      page: _currentPage,
      perPage: 8,
    );

    if (result is Success<PaginatedResponse<AppointmentModel>>) {
      if(result.data.msg=="Unauthorized. Please login first."){
        context.pushReplacementNamed(AppRouter.login.name);

      }
      try {
        _allAppointments.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(AppointmentListSuccess(
          paginatedResponse: PaginatedResponse<AppointmentModel>(
            paginatedData: PaginatedData<AppointmentModel>(items: _allAppointments),
            meta: result.data.meta,
            links: result.data.links,),
          hasMore: _hasMore,
        ));
      } catch (e) {
        emit(AppointmentError(error: result.data.msg ?? 'Error loading appointments'));
      }
    } else if (result is ResponseError<PaginatedResponse<AppointmentModel>>) {
      emit(AppointmentError(error: result.message ?? 'Error loading appointments'));
    }
  }

  Future<void> getAppointmentDetails({required String appointmentId}) async {
    emit(AppointmentLoading());
    try {
      final result = await remoteDataSource.getAppointmentDetails(
        appointmentId: appointmentId,
      );
      if (result is Success<AppointmentModel>) {
        emit(AppointmentDetailsSuccess(appointment: result.data));
      } else if (result is ResponseError<AppointmentModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error fetching appointment details');
        emit(AppointmentError(error: result.message ?? 'Error fetching appointment details'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(AppointmentError(error: e.toString()));
    }
  }

  Future<void> finishAppointment({required int appointmentId,required BuildContext context}) async {
    emit(AppointmentLoading());
    try {
      final result = await remoteDataSource.finishAppointment(
        appointmentId: appointmentId,
      );
      if (result is Success<PublicResponseModel>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.login.name);

        }
        ShowToast.showToastSuccess(message: 'appointment finished successfully');
        emit(AppointmentActionSuccess());
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Error finishing appointment');
        emit(AppointmentError(error: result.message ?? 'Error finishing appointment'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(AppointmentError(error: e.toString()));
    }
  }

  void checkAndReload({required String? patientId,required BuildContext context}) {
    if (state is! AppointmentListSuccess) {
      if (patientId != null) {
        getPatientAppointments(patientId: patientId,context: context);
      } else {
        getMyAppointments(context: context);
      }
    }
  }
}
