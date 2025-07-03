import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/observation_end_points.dart';
import '../models/observation_model.dart';

abstract class ObservationRemoteDataSource {
  Future<Resource<ObservationModel>> getDetailsObservation({required String serviceId, required String observationId, required String patientId});
}

class ObservationRemoteDataSourceImpl implements ObservationRemoteDataSource {
  final NetworkClient networkClient;

  ObservationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<ObservationModel>> getDetailsObservation({required String serviceId, required String observationId, required String patientId}) async {
    final response = await networkClient.invoke(
      ObservationEndPoints.getDetailsObservation(serviceRequestId: serviceId, observationId: observationId, patientId: patientId),
      RequestType.get,
    );
    return ResponseHandler<ObservationModel>(response).processResponse(fromJson: (json) => ObservationModel.fromJson(json['observation']));
  }
}
