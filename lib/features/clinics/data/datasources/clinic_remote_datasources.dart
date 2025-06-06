import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/features/clinics/data/clinic_end_points.dart';
import 'package:medi_zen_app_doctor/features/clinics/data/models/clinic_model.dart';

import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';

abstract class ClinicRemoteDataSource {
  Future<Resource<PaginatedResponse<ClinicModel>>> getAllClinics({
    String? searchQuery,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<ClinicModel>> getMyClinic();
  Future<Resource<PublicResponseModel>> setMyClinic(String clinicId); // Add this

}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final NetworkClient networkClient;

  ClinicRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ClinicModel>>> getAllClinics({
    String? searchQuery,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = {
      'page': page,
      'pagination_count': perPage,
      if (searchQuery != null && searchQuery.isNotEmpty)
        'search_query': searchQuery,
    };

    final response = await networkClient.invoke(
      ClinicEndPoints.getAllClinics,
      RequestType.get,
      queryParameters: queryParams,
    );

    return ResponseHandler<PaginatedResponse<ClinicModel>>(
      response,
    ).processResponse(
      fromJson:
          (json) => PaginatedResponse<ClinicModel>.fromJson(json, 'clinics', (
            dataJson,
          ) {
            return ClinicModel.fromJson(dataJson);
          }),
    );
  }

  @override
  Future<Resource<ClinicModel>> getMyClinic() async {
    final response = await networkClient.invoke(
      ClinicEndPoints.getMyClinic,
      RequestType.get,
    );
    return ResponseHandler<ClinicModel>(
      response,
    ).processResponse(fromJson: (json) => ClinicModel.fromJson(json['clinic']));
  }

  @override
  Future<Resource<PublicResponseModel>> setMyClinic(String clinicId) async {
    final response = await networkClient.invoke(
      ClinicEndPoints.setMyClinic,
      RequestType.post,
      body: {'clinic_id': clinicId},
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
