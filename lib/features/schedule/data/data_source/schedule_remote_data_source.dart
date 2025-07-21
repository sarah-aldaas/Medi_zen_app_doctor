import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/data/models/public_response_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/network_client.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../end_points/schedule_end_points.dart';
import '../model/schedule_model.dart';
import '../model/toggle_schedule_response.dart';

abstract class ScheduleRemoteDataSource {
  Future<Resource<PaginatedResponse<ScheduleModel>>> getMySchedules({
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<ScheduleModel>> getScheduleDetails(String id);
  Future<Resource<ToggleScheduleResponse>> toggleScheduleStatus(String id);
  Future<Resource<PublicResponseModel>> createSchedule(ScheduleModel schedule);
  Future<Resource<ToggleScheduleResponse>> updateSchedule(ScheduleModel schedule);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final NetworkClient networkClient;

  ScheduleRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ScheduleModel>>> getMySchedules({
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
      ScheduleEndPoints.showMySchedules(),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ScheduleModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<ScheduleModel>.fromJson(
        json,
        'schedules',
            (dataJson) => ScheduleModel.fromJson(dataJson),
      ),
    );
  }

  @override
  Future<Resource<ScheduleModel>> getScheduleDetails(String id) async {
    final response = await networkClient.invoke(
      ScheduleEndPoints.showSchedule(id: id),
      RequestType.get,
    );
    return ResponseHandler<ScheduleModel>(response).processResponse(
      fromJson: (json) => ScheduleModel.fromJson(json['schedule']),
    );
  }

  @override
  Future<Resource<ToggleScheduleResponse>> toggleScheduleStatus(String id) async {
    final response = await networkClient.invoke(
      ScheduleEndPoints.toggleScheduleStatus(id: id),
      RequestType.post,
    );
    return ResponseHandler<ToggleScheduleResponse>(response).processResponse(
      fromJson: (json) => ToggleScheduleResponse.fromJson(json),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> createSchedule(ScheduleModel schedule) async {
    final response = await networkClient.invoke(
      ScheduleEndPoints.createSchedule,
      RequestType.post,
      body: schedule.toCreateJson(),
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<ToggleScheduleResponse>> updateSchedule(ScheduleModel schedule) async {
    final response = await networkClient.invoke(
      ScheduleEndPoints.updateSchedule(id: schedule.id),
      RequestType.post,
      body: schedule.toUpdateJson(),
    );
    return ResponseHandler<ToggleScheduleResponse>(response).processResponse(
      fromJson: (json) => ToggleScheduleResponse.fromJson(json),
    );
  }
}