
import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/network_client.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../model/health_care_services_model.dart';
import '../services_end_points.dart';

abstract class ServicesRemoteDataSource {
  Future<Resource<PaginatedResponse<HealthCareServiceModel>>> getAllHealthCareServices({int page = 1, int perPage = 10, Map<String, dynamic>? filters,});

  Future<Resource<HealthCareServiceModel>> getSpecificHealthCareServices({required String id});

  // Future<Resource<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>> getAllHealthCareServiceEligibilityCodes({int page = 1, int perPage = 10});

  // Future<Resource<HealthCareServiceEligibilityCodesModel>> getSpecificHealthCareServiceEligibilityCodes({required String id});
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final NetworkClient networkClient;

  ServicesRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<HealthCareServiceModel>> getSpecificHealthCareServices({required String id}) async {
    final response = await networkClient.invoke(ServicesEndPoints.getSpecificHealthCareServices(id: id), RequestType.get);
    return ResponseHandler<HealthCareServiceModel>(response).processResponse(fromJson: (json) => HealthCareServiceModel.fromJson(json['healthCareService']));
  }

  @override
  Future<Resource<PaginatedResponse<HealthCareServiceModel>>> getAllHealthCareServices({
    int page = 1,
    int perPage = 10,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = {
      'page': page,
      'pagination_count': perPage,
      if (filters != null) ...filters,
    };

    final response = await networkClient.invoke(
      ServicesEndPoints.getAllHealthCareServices,
      RequestType.get,
      queryParameters: queryParams,
    );

    return ResponseHandler<PaginatedResponse<HealthCareServiceModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<HealthCareServiceModel>.fromJson(
        json,
        'healthCareServices',
            (dataJson) => HealthCareServiceModel.fromJson(dataJson),
      ),
    );
  }
  // @override
  // Future<Resource<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>> getAllHealthCareServiceEligibilityCodes({int page = 1, int perPage = 10}) async {
  //   final queryParams = {'page': page, 'pagination_count': perPage};
  //
  //   final response = await networkClient.invoke(ServicesEndPoints.getAllHealthCareServiceEligibilityCodes, RequestType.get, queryParameters: queryParams);
  //
  //   return ResponseHandler<PaginatedResponse<HealthCareServiceEligibilityCodesModel>>(response).processResponse(
  //     fromJson:
  //         (json) => PaginatedResponse<HealthCareServiceEligibilityCodesModel>.fromJson(
  //           json,
  //           'healthCareServiceEligibilityCodes',
  //           (dataJson) => HealthCareServiceEligibilityCodesModel.fromJson(dataJson),
  //         ),
  //   );
  // }

  // @override
  // Future<Resource<HealthCareServiceEligibilityCodesModel>> getSpecificHealthCareServiceEligibilityCodes({required String id}) async {
  //   final response = await networkClient.invoke(ServicesEndPoints.getSpecificHealthCareServiceEligibilityCodes(id: id), RequestType.get);
  //   return ResponseHandler<HealthCareServiceEligibilityCodesModel>(
  //     response,
  //   ).processResponse(fromJson: (json) => HealthCareServiceEligibilityCodesModel.fromJson(json));
  // }
}
