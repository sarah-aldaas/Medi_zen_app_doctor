import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/imaging_study_end_points.dart';
import '../models/imaging_study_model.dart';

abstract class ImagingStudyRemoteDataSource {
  Future<Resource<ImagingStudyModel>> getDetailsImagingStudy({
    required String serviceId,
    required String patientId,
    required String imagingStudyId,
  });
}

class ImagingStudyRemoteDataSourceImpl implements ImagingStudyRemoteDataSource {
  final NetworkClient networkClient;

  ImagingStudyRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<ImagingStudyModel>> getDetailsImagingStudy({
    required String serviceId,
    required String patientId,
    required String imagingStudyId,
  }) async {
    final response = await networkClient.invoke(
      ImagingStudyEndPoints.getDetailsImagingStudy(
        serviceRequestId: serviceId,
        imagingStudyId: imagingStudyId,
        patientId: patientId,
      ),
      RequestType.get,
    );
    return ResponseHandler<ImagingStudyModel>(response).processResponse(
      fromJson: (json) => ImagingStudyModel.fromJson(json['imaging_study']),
    );
  }
}
