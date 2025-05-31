import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/telecom_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../end_points/telecome_end_points.dart';

abstract class TelecomRemoteDataSource {
  Future<Resource<PaginatedResponse<TelecomModel>>> getListAllTelecom({ required String paginationCount});

  Future<Resource<PublicResponseModel>> updateTelecom({required String id, required TelecomModel telecomModel});

  Future<Resource<TelecomModel>> showTelecom({required String id});

  Future<Resource<PublicResponseModel>> deleteTelecom({required String id});

  Future<Resource<PublicResponseModel>> createTelecom({required TelecomModel telecomModel});
}

class TelecomRemoteDataSourceImpl implements TelecomRemoteDataSource {
  final NetworkClient networkClient;

  TelecomRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PublicResponseModel>> createTelecom({required TelecomModel telecomModel}) async {
    final response = await networkClient.invoke(TelecomEndPoints.createTelecom, RequestType.post, body: telecomModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteTelecom({required String id}) async {
    final response = await networkClient.invoke(TelecomEndPoints.deleteTelecom(id: id), RequestType.delete);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<TelecomModel>>> getListAllTelecom({
    required String paginationCount,
  }) async {
    final response = await networkClient.invoke(
      TelecomEndPoints.listAllTelecom( paginationCount: paginationCount),
      RequestType.get,
    );

    return ResponseHandler<PaginatedResponse<TelecomModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<TelecomModel>.fromJson(
        json,
        'telecoms',
            (dataJson) {
              return TelecomModel.fromJson(dataJson);
            },
      ),
    );
  }


  @override
  Future<Resource<TelecomModel>> showTelecom({required String id}) async {
    final response = await networkClient.invoke(TelecomEndPoints.showTelecom(id: id), RequestType.get);
    return ResponseHandler<TelecomModel>(response).processResponse(fromJson: (json) => TelecomModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateTelecom({required String id, required TelecomModel telecomModel}) async {
    final response = await networkClient.invoke(TelecomEndPoints.updateTelecom(id: id), RequestType.post, body: telecomModel.toJson());
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
