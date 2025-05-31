
import '../../../../base/data/models/respons_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/network_client.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../end_point_auth.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {

  Future<Resource<AuthResponseModel>> forgetPassword({required String email});

  Future<Resource<AuthResponseModel>> verifyOtpPassword({required String email, required String otp});

  Future<Resource<AuthResponseModel>> resetPassword({required String email, required String newPassword});

  Future<Resource<AuthResponseModel>> login({required String email, required String password});

  Future<Resource<AuthResponseModel>> logout({required int allDevices});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient networkClient;

  AuthRemoteDataSourceImpl({required this.networkClient});


  @override
  Future<Resource<AuthResponseModel>> logout({required int allDevices}) async {
    final response = await networkClient.invoke(EndPointsAuth.logout, RequestType.post, body: {'all_devices': allDevices});
    return ResponseHandler<AuthResponseModel>(response).processResponse(fromJson: (json) => AuthResponseModel.fromJson(json));
  }

  @override
  Future<Resource<AuthResponseModel>> forgetPassword({required String email}) async {
    final response = await networkClient.invoke(EndPointsAuth.forgetPassword, RequestType.post, body: {'email': email});
    return ResponseHandler<AuthResponseModel>(response).processResponse(fromJson: (json) => AuthResponseModel.fromJson(json));
  }

  @override
  Future<Resource<AuthResponseModel>> verifyOtpPassword({required String email, required String otp}) async {
    final response = await networkClient.invoke(EndPointsAuth.verifyForgetPasswordOtp, RequestType.post, body: {'email': email, 'otp': otp});
    return ResponseHandler<AuthResponseModel>(response).processResponse(fromJson: (json) => AuthResponseModel.fromJson(json));
  }

  @override
  Future<Resource<AuthResponseModel>> resetPassword({required String email, required String newPassword}) async {
    final response = await networkClient.invoke(EndPointsAuth.resetPassword, RequestType.post, body: {'email': email, 'new_password': newPassword});
    return ResponseHandler<AuthResponseModel>(response).processResponse(fromJson: (json) => AuthResponseModel.fromJson(json));
  }

  @override
  Future<Resource<AuthResponseModel>> login({required String email, required String password}) async {
    final response = await networkClient.invoke(EndPointsAuth.login, RequestType.post, body: {'email': email, 'password': password});
    return ResponseHandler<AuthResponseModel>(response).processResponse(fromJson: (json) => AuthResponseModel.fromJson(json));
  }
}
