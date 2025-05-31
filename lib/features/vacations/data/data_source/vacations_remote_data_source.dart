import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/network_client.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../end_points/vacations_end_points.dart';
import '../model/vacation_model.dart';

abstract class VacationRemoteDataSource {
  Future<Resource<PaginatedResponse<VacationModel>>> getVacations({
    required String scheduleId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<VacationModel>> getVacationDetails(String id);
  Future<Resource<PublicResponseModel>> deleteVacation(int id);
  Future<Resource<PublicResponseModel>> createVacation(VacationModel vacation);
  Future<Resource<PublicResponseModel>> updateVacation(VacationModel vacation);
}

class VacationRemoteDataSourceImpl implements VacationRemoteDataSource {
  final NetworkClient networkClient;

  VacationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<VacationModel>>> getVacations({
    required String scheduleId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {
      'page': page.toString(),
      'pagination_count': perPage.toString(),
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      VacationEndPoints.getVacations(scheduleId: scheduleId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<VacationModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<VacationModel>.fromJson(
        json,
        'vacations',
            (dataJson) => VacationModel.fromJson(dataJson),
      ),
    );
  }

  @override
  Future<Resource<VacationModel>> getVacationDetails(String id) async {
    final response = await networkClient.invoke(
      VacationEndPoints.viewVacation(id: id),
      RequestType.get,
    );
    return ResponseHandler<VacationModel>(response).processResponse(
      fromJson: (json) => VacationModel.fromJson(json['vacation']),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> deleteVacation(int id) async {
    final response = await networkClient.invoke(
      VacationEndPoints.deleteVacation(id: id),
      RequestType.delete,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> createVacation(VacationModel vacation) async {
    final response = await networkClient.invoke(
      VacationEndPoints.createVacation,
      RequestType.post,
      body: vacation.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> updateVacation(VacationModel vacation) async {
    final response = await networkClient.invoke(
      VacationEndPoints.updateVacation(id: int.parse(vacation.id!)),
      RequestType.post,
      body: vacation.createJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }
}