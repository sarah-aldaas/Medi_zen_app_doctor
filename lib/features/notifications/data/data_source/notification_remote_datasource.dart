import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/network_client.dart';

import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../end_points/notification_end_points.dart';
import '../models/notification_model.dart';
import '../models/store_FCM_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Resource<PublicResponseModel>> storeFCMToken({required StoreFCMModel storeFCMModel});

  Future<Resource<PublicResponseModel>> deleteFCMToken({required StoreFCMModel storeFCMModel});

  Future<Resource<PaginatedResponse<NotificationModel>>> getMyNotification({int page = 1, int perPage = 10, required bool isRead});

  Future<Resource<PublicResponseModel>> makeNotificationAsRead({required String notificationId});

  Future<Resource<PublicResponseModel>> deleteNotification({required String notificationId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final NetworkClient networkClient;

  NotificationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PublicResponseModel>> deleteFCMToken({required StoreFCMModel storeFCMModel}) async {
    final response = await networkClient.invoke(NotificationEndPoints.deleteFCMToken(), RequestType.post, body: storeFCMModel.deleteJson());

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteNotification({required String notificationId}) async {
    final response = await networkClient.invoke(NotificationEndPoints.deleteNotification(notificationId: notificationId), RequestType.delete);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<NotificationModel>>> getMyNotification({int page = 1, int perPage = 10, required bool isRead}) async {
    final queryParams = {'page': page.toString(), 'pagination_count': perPage.toString(), 'is_read': isRead ? 1 : 0};

    final response = await networkClient.invoke(NotificationEndPoints.getMyNotification(), RequestType.get, queryParameters: queryParams);

    return ResponseHandler<PaginatedResponse<NotificationModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<NotificationModel>.fromJson(json, 'notifications', (dataJson) => NotificationModel.fromJson(dataJson)),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> makeNotificationAsRead({required String notificationId}) async {
    final response = await networkClient.invoke(NotificationEndPoints.makeNotificationAsRead(notificationId: notificationId), RequestType.post);

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> storeFCMToken({required StoreFCMModel storeFCMModel}) async {
    final response = await networkClient.invoke(NotificationEndPoints.storeFCMToken(), RequestType.post, body: storeFCMModel.toJson());

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
