import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../data/data_source/series_remote_data_source.dart';
import '../../../data/models/series_model.dart';

part 'series_state.dart';

class SeriesCubit extends Cubit<SeriesState> {
  final SeriesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SeriesCubit({required this.remoteDataSource, required this.networkInfo}) : super(SeriesInitial());

  Future<void> getSeriesDetails({required String serviceRequestId,required String patientId, required String imagingStudyId, required String seriesId, required BuildContext context}) async {
    emit(SeriesLoading());
    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed(AppRouter.noInternet.name);
    //   emit(SeriesError('No internet connection'));
    //   return;
    // }
    final result = await remoteDataSource.getDetailsSeries(serviceRequestId: serviceRequestId,patientId: patientId, imagingStudyId: imagingStudyId, seriesId: seriesId);

    if (result is Success<SeriesModel>) {
      emit(SeriesLoaded(result.data));
    } else {
      emit(SeriesError('Failed to load series details'));
    }
  }
}
