import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meta/meta.dart';
import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../../base/go_router/go_router.dart';
import '../../../data/data_source/allergies_remote_data_source.dart';
import '../../../data/models/allergy_filter_model.dart';
import '../../../data/models/allergy_model.dart';


part 'allergy_state.dart';

class AllergyCubit extends Cubit<AllergyState> {
  final AllergyRemoteDataSource remoteDataSource;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  AllergyFilterModel currentFilter = AllergyFilterModel();
  List<AllergyModel> _allAllergies = [];

  AllergyCubit({required this.remoteDataSource}) : super(AllergyInitial());

  Future<void> getAllergies({
    required String patientId,
    AllergyFilterModel? filter,
    bool loadMore = false,
  required BuildContext context
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAllergies.clear();
      if (filter != null) currentFilter = filter;
      emit(AllergyLoading(isInitialLoad: true));
    } else {
      if (!_hasMore) {
        _isLoading = false;
        return;
      }
      _currentPage++;
    }

    try {
      final result = await remoteDataSource.getPatientAllergies(
        patientId: patientId,
        filters: currentFilter.toJson(),
        page: _currentPage,
        perPage: 10,
      );

      if (result is Success<PaginatedResponse<AllergyModel>>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.login.name);

        }
        final newAllergies = result.data.paginatedData?.items ?? [];
        _allAllergies.addAll(newAllergies);
        _hasMore = newAllergies.length >= 10;

        emit(AllergySuccess(
          allergies: _allAllergies,
          hasMore: _hasMore,
        ));
      } else if (result is ResponseError<PaginatedResponse<AllergyModel>>) {
        emit(AllergyError(error: result.message ?? 'Failed to fetch allergies'));
        if (loadMore) _currentPage--;
      }
    } finally {
      _isLoading = false;
    }
  }



  Future<void> getAppointmentAllergies({
    required String patientId,
    required String appointmentId,
    AllergyFilterModel? filter,
    bool loadMore = false,required BuildContext context
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allAllergies.clear();
      if (filter != null) currentFilter = filter;
      emit(AllergyLoading(isInitialLoad: true));
    } else {
      if (!_hasMore) {
        _isLoading = false;
        return;
      }
      _currentPage++;
    }

    try {
      final result = await remoteDataSource.getAppointmentAllergies(
        appointmentId: appointmentId,
        patientId: patientId,
        filters: currentFilter.toJson(),
        page: _currentPage,
        perPage: 10,
      );

      if (result is Success<PaginatedResponse<AllergyModel>>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.login.name);

        }
        final newAllergies = result.data.paginatedData?.items ?? [];
        _allAllergies.addAll(newAllergies);
        _hasMore = newAllergies.length >= 10;

        emit(AllergySuccess(
          allergies: _allAllergies,
          hasMore: _hasMore,
        ));
      } else if (result is ResponseError<PaginatedResponse<AllergyModel>>) {
        emit(AllergyError(error: result.message ?? 'Failed to fetch allergies'));
        if (loadMore) _currentPage--;
      }
    } finally {
      _isLoading = false;
    }
  }


  Future<void> getAllergyDetails({
    required String patientId,
    required String allergyId,
  }) async {
    emit(AllergyLoading());
    final result = await remoteDataSource.getAllergyDetails(
      patientId: patientId,
      allergyId: allergyId,
    );

    if (result is Success<AllergyModel>) {
      emit(AllergyDetailsLoaded(allergy: result.data));
    } else if (result is ResponseError<AllergyModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to load allergy');
      emit(AllergyError(error: result.message ?? 'Failed to load allergy'));
    }
  }

  Future<void> createAllergy({
    required String patientId,
    required String appointmentId,
    required AllergyModel allergy,required BuildContext context
  }) async {
    try{
      emit(AllergyLoading());
      final result = await remoteDataSource.createAllergy(
        patientId: patientId,
        appointmentId: appointmentId,
        allergy: allergy,
      );

      if (result is Success<PublicResponseModel>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.login.name);

        }
        if (result.data.status) {
          ShowToast.showToastSuccess(message: result.data.msg);
          emit(AllergyCreated());
        } else {
          ShowToast.showToastError(message: result.data.msg ?? 'Failed to create allergy');
          emit(AllergyError(error: result.data.msg ?? 'Failed to create allergy'));
        }
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to create allergy');
        emit(AllergyError(error: result.message ?? 'Failed to create allergy'));
      }
    }catch(e){
      ShowToast.showToastError(message:'Failed to create allergy');
      emit(AllergyError(error:'Failed to create allergy'));

    }
  }

  Future<void> updateAllergy({
    required String patientId,
    required String appointmentId,
    required String allergyId,
    required AllergyModel allergy,required BuildContext context
  }) async {
    try{
      emit(AllergyLoading());
      final result = await remoteDataSource.updateAllergy(
        patientId: patientId,
        appointmentId: appointmentId,
        allergyId: allergyId,
        allergy: allergy,
      );

      if (result is Success<PublicResponseModel>) {
        if(result.data.msg=="Unauthorized. Please login first."){
          context.pushReplacementNamed(AppRouter.login.name);

        }
        ShowToast.showToastSuccess(message: 'Allergy updated successfully');
        emit(AllergyUpdated());
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.data!.msg ?? 'Failed to update allergy');
        emit(AllergyError(error: result.message ?? 'Failed to update allergy'));
      }
    }catch(e){
      ShowToast.showToastError(message: 'Failed to update allergy');
      emit(AllergyError(error:'Failed to update allergy'));

    }
  }

  Future<void> deleteAllergy({
    required String patientId,
    required String allergyId,required BuildContext context
  }) async {
    emit(AllergyLoading());
    final result = await remoteDataSource.deleteAllergy(
      patientId: patientId,
      allergyId: allergyId,
    );

    if (result is Success<PublicResponseModel>) {
      if(result.data.msg=="Unauthorized. Please login first."){
        context.pushReplacementNamed(AppRouter.login.name);

      }
      ShowToast.showToastSuccess(message: 'Allergy deleted successfully');
      emit(AllergyDeleted(allergyId: allergyId));
    } else if (result is ResponseError<PublicResponseModel>) {
      ShowToast.showToastError(message: result.message ?? 'Failed to delete allergy');
      emit(AllergyError(error: result.message ?? 'Failed to delete allergy'));
    }
  }
}