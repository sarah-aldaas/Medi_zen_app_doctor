import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/features/doctor/data/end_points/doctor_end_points.dart';

import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../../../authentication/data/models/doctor_model.dart';

abstract class DoctorRemoteDataSource {
  Future<Resource<PaginatedResponse<DoctorModel>>> getDoctorsOfClinic({required String clinicId, required int perPage, required int page});
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final NetworkClient networkClient;

  DoctorRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<DoctorModel>>> getDoctorsOfClinic({required String clinicId, required int perPage, required int page}) async {
    final queryParams = {'pagination_count': perPage,'page':page};

    final response = await networkClient.invoke(DoctorEndPoints.getDoctorsOfClinic(clinicId: clinicId), RequestType.get, queryParameters: queryParams);

    return ResponseHandler<PaginatedResponse<DoctorModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<DoctorModel>.fromJson(json, 'doctors', (dataJson) => DoctorModel.fromJson(dataJson)));
  }
}
