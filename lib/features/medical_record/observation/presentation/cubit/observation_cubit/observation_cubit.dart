import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import '../../../../../../base/go_router/go_router.dart';
import '../../../../../../base/services/network/network_info.dart';
import '../../../data/data_source/observation_remote_data_source.dart';
import '../../../data/models/observation_model.dart';
part 'observation_state.dart';

class ObservationCubit extends Cubit<ObservationState> {
  final ObservationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ObservationCubit({required this.remoteDataSource,required this.networkInfo}) : super(ObservationInitial());

  Future<void> getObservationDetails({
    required String serviceId,
    required String observationId,
    required String patientId,
    required BuildContext context
  }) async {
    emit(ObservationLoading());
    // Check internet connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      context.pushNamed(AppRouter.noInternet.name);
      emit(ObservationError('No internet connection'));
      return;
    }
    final result = await remoteDataSource.getDetailsObservation(
      patientId: patientId,
      serviceId: serviceId,
      observationId: observationId,
    );

    if (result is Success<ObservationModel>) {
      emit(ObservationLoaded(result.data));
    } else {
      emit(ObservationError('Failed to load observation details'));
    }
  }
}