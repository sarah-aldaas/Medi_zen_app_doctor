
import '../../helpers/enums.dart';
import '../../services/network/network_client.dart';
import '../../services/network/resource.dart';
import '../../services/network/response_handler.dart';
import '../end_points/end_points_public.dart';
import '../models/respons_model.dart';

abstract class RemoteDataSourcePublic {
  Future<Resource<CodeTypesResponseModel>> getCodeTypes();
  Future<Resource<CodesResponseModel>> getCodes({int? codeTypeId});
}

class RemoteDataSourcePublicImpl implements RemoteDataSourcePublic {
  final NetworkClient networkClient;

  RemoteDataSourcePublicImpl({required this.networkClient});

  @override
  Future<Resource<CodeTypesResponseModel>> getCodeTypes() async {
    final response = await networkClient.invoke(EndPointPublic.codeTypes, RequestType.get);
    return ResponseHandler<CodeTypesResponseModel>(response).processResponse(fromJson: (json) => CodeTypesResponseModel.fromJson(json));
  }

  @override
  Future<Resource<CodesResponseModel>> getCodes({int? codeTypeId}) async {
    String url = EndPointPublic.codes;
    if (codeTypeId != null) {
      url += '?code_type_id=$codeTypeId';
    }
    final response = await networkClient.invoke(url, RequestType.get);
    return ResponseHandler<CodesResponseModel>(response).processResponse(fromJson: (json) => CodesResponseModel.fromJson(json));
  }
}
