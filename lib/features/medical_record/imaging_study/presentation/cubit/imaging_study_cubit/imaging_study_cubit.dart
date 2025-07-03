import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../series/data/data_source/series_remote_data_source.dart';
import '../../../../series/data/models/series_model.dart';
import '../../../data/data_source/imaging_study_remote_data_source.dart';
import '../../../data/models/imaging_study_model.dart';

part 'imaging_study_state.dart';

class ImagingStudyCubit extends Cubit<ImagingStudyState> {
  final ImagingStudyRemoteDataSource imagingStudyDataSource;
  final SeriesRemoteDataSource seriesDataSource;  final NetworkInfo networkInfo;


  int _currentSeriesPage = 1;
  bool _hasMoreSeries = true;
  List<SeriesModel> _allSeries = [];

  ImagingStudyCubit({required this.imagingStudyDataSource, required this.seriesDataSource,required this.networkInfo}) : super(ImagingStudyInitial());

  Future<void> loadImagingStudy({required String serviceId,required String patientId, required String imagingStudyId, required BuildContext context}) async {
    emit(ImagingStudyLoading());
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ImagingStudyError('No internet connection'));
      return;
    }
    // Load imaging study details
    final studyResult = await imagingStudyDataSource.getDetailsImagingStudy(serviceId: serviceId,patientId: patientId, imagingStudyId: imagingStudyId);
if(studyResult is Success<ImagingStudyModel>){
  emit(ImagingStudyLoaded(imagingStudy: studyResult.data));
}
    if (studyResult is! Success<ImagingStudyModel>) {
      emit(ImagingStudyError('Failed to load imaging study'));
      return;
    }

    // Load first page of series
    // final seriesResult = await seriesDataSource.getAllSeries(serviceId: serviceId, imagingStudyId: imagingStudyId, page: 1, perPage: 10);
    // if (seriesResult is Success<PaginatedResponse<SeriesModel>>) {
    //   if (seriesResult.data.msg == "Unauthorized. Please login first.") {
    //     context.pushReplacementNamed(AppRouter.login.name);
    //
    //     _allSeries = seriesResult.data.paginatedData!.items;
    //     _hasMoreSeries = seriesResult.data.paginatedData!.items.isNotEmpty && seriesResult.data.meta!.currentPage < seriesResult.data.meta!.lastPage;
    //     _currentSeriesPage = 2;
    //
    //     emit(ImagingStudyLoaded(imagingStudy: studyResult.data, series: _allSeries, hasMoreSeries: _hasMoreSeries));
    //   } else {
    //     emit(ImagingStudyError('Failed to load series'));
    //   }
    // }
  }

    // Future<void> loadMoreSeries({required String serviceId, required String imagingStudyId}) async {
    //   if (!_hasMoreSeries) return;
    //
    //   final result = await seriesDataSource.getAllSeries(serviceId: serviceId, imagingStudyId: imagingStudyId, page: _currentSeriesPage, perPage: 10);
    //
    //   if (result is Success<PaginatedResponse<SeriesModel>>) {
    //     _allSeries.addAll(result.data.paginatedData!.items);
    //     _hasMoreSeries = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
    //     _currentSeriesPage++;
    //
    //     emit(ImagingStudyLoaded(imagingStudy: (state as ImagingStudyLoaded).imagingStudy, series: _allSeries, hasMoreSeries: _hasMoreSeries));
    //   }
    // }
  }
