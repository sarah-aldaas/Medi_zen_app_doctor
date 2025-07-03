import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/helpers/enums.dart';
import '../../../../../base/services/network/network_client.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/services/network/response_handler.dart';
import '../end_points/series_end_points.dart';
import '../models/series_model.dart';

abstract class SeriesRemoteDataSource {
  Future<Resource<SeriesModel>> getDetailsSeries({required String serviceRequestId,required String patientId, required String seriesId, required String imagingStudyId});

  Future<Resource<PaginatedResponse<SeriesModel>>> getAllSeries({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String serviceRequestId,
    required String imagingStudyId,
    required String patientId,
  });
}

class SeriesRemoteDataSourceImpl implements SeriesRemoteDataSource {
  final NetworkClient networkClient;

  SeriesRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<SeriesModel>> getDetailsSeries({required String serviceRequestId,required String patientId, required String seriesId, required String imagingStudyId}) async {
    final response = await networkClient.invoke(
      SeriesEndPoints.getDetailsSeries(serviceRequestId: serviceRequestId, imagingStudyId: imagingStudyId, seriesId: seriesId,patientId: patientId),
      RequestType.get,
    );
    return ResponseHandler<SeriesModel>(response).processResponse(fromJson: (json) => SeriesModel.fromJson(json['series']));
  }

  @override
  Future<Resource<PaginatedResponse<SeriesModel>>> getAllSeries({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
    required String serviceRequestId,
    required String patientId,
    required String imagingStudyId,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      SeriesEndPoints.getAllSeries(serviceRequestId: serviceRequestId, imagingStudyId: imagingStudyId,patientId: patientId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<SeriesModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<SeriesModel>.fromJson(json, 'series', (dataJson) => SeriesModel.fromJson(dataJson)));
  }
}
