import 'package:dio/dio.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';
import 'package:medi_zen_app_doctor/features/authentication/data/models/doctor_model.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/update_profile_request_Model.dart';

import '../end_points/profile_end_points.dart';

abstract class ProfileRemoteDataSource {
  Future<Resource<DoctorModel>> getMyProfile();
  Future<Resource<PublicResponseModel>> updateMyProfile({
    required UpdateProfileRequestModel updateProfileRequestModel,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final NetworkClient networkClient;

  ProfileRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<DoctorModel>> getMyProfile() async {
    final response = await networkClient.invoke(
      ProfileEndPoints.showMyProfile,
      RequestType.get,
    );
    return ResponseHandler<DoctorModel>(response).processResponse(
      fromJson: (json) => DoctorModel.fromJson(json["profile"]),
    );
  }

  // @override
  // Future<Resource<PublicResponseModel>> updateMyProfile({
  //   required UpdateProfileRequestModel updateProfileRequestModel,
  // }) async {
  //   final response = await networkClient.invoke(
  //     ProfileEndPoints.editMyProfile,
  //     RequestType.post,
  //     body: updateProfileRequestModel.toJson(),
  //   );
  //   return ResponseHandler<PublicResponseModel>(
  //     response,
  //   ).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  // }

  @override
  Future<Resource<PublicResponseModel>> updateMyProfile({
    required UpdateProfileRequestModel updateProfileRequestModel,
  }) async {
    final formData = FormData.fromMap(updateProfileRequestModel.toJson());

    // Add avatar file if present
    if (updateProfileRequestModel.avatar != null) {
      formData.files.add(MapEntry(
        'avatar', // Adjust field name if API expects different (e.g., 'profile_picture')
        await MultipartFile.fromFile(
          updateProfileRequestModel.avatar!.path,
          filename: updateProfileRequestModel.avatar!.path.split('/').last,
        ),
      ));
    }

    final response = await networkClient.invokeMultipart(
      ProfileEndPoints.editMyProfile,
      RequestType.post,
      formData: formData,
    );
    return ResponseHandler<PublicResponseModel>(
      response,
    ).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
