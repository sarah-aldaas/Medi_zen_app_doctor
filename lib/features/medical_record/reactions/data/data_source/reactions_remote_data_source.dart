import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';

import '../end_points/reactions_end_points.dart';
import '../models/reaction_model.dart';

abstract class ReactionRemoteDataSource {
  Future<Resource<PaginatedResponse<ReactionModel>>> listAllergyReactions({
    required int patientId,
    required int allergyId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<PaginatedResponse<ReactionModel>>> listAppointmentReactions({
    required int patientId,
    required int appointmentId,
    required int allergyId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  });

  Future<Resource<ReactionModel>> viewReaction({required String patientId, required String allergyId, required String reactionId});

  Future<Resource<PublicResponseModel>> createReaction({required String patientId, required String allergyId, required ReactionModel reaction});

  Future<Resource<PublicResponseModel>> updateReaction({required String patientId, required String allergyId, required String reactionId, required ReactionModel reaction});

  Future<Resource<PublicResponseModel>> deleteReaction({required String patientId, required String allergyId, required String reactionId});
}

class ReactionRemoteDataSourceImpl implements ReactionRemoteDataSource {
  final NetworkClient networkClient;

  ReactionRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ReactionModel>>> listAllergyReactions({
    required int patientId,
    required int allergyId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ReactionEndPoints.listAllergyReactions(patientId: patientId, allergyId: allergyId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ReactionModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ReactionModel>.fromJson(json, 'reactions', (dataJson) => ReactionModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PaginatedResponse<ReactionModel>>> listAppointmentReactions({
    required int patientId,
    required int appointmentId,
    required int allergyId,
    Map<String, dynamic>? filters,
    int page = 1,
    int perPage = 10,
  }) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(
      ReactionEndPoints.byAppointment(patientId: patientId, appointmentId: appointmentId, allergyId: allergyId),
      RequestType.get,
      queryParameters: params,
    );

    return ResponseHandler<PaginatedResponse<ReactionModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ReactionModel>.fromJson(json, 'reactions', (dataJson) => ReactionModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<ReactionModel>> viewReaction({required String patientId, required String allergyId, required String reactionId}) async {
    final response = await networkClient.invoke(ReactionEndPoints.view(patientId: patientId, allergyId: allergyId, reactionId: reactionId), RequestType.get);

    return ResponseHandler<ReactionModel>(response).processResponse(fromJson: (json) => ReactionModel.fromJson(json['reaction']));
  }

  @override
  Future<Resource<PublicResponseModel>> createReaction({required String patientId, required String allergyId, required ReactionModel reaction}) async {
    final response = await networkClient.invoke(
      ReactionEndPoints.create(patientId: patientId, allergyId: allergyId),
      RequestType.post,
      body: reaction.createJson(),
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> updateReaction({
    required String patientId,
    required String allergyId,
    required String reactionId,
    required ReactionModel reaction,
  }) async {
    final response = await networkClient.invoke(
      ReactionEndPoints.update(patientId: patientId, allergyId: allergyId, reactionId: reactionId),
      RequestType.post,
      body: reaction.createJson(),
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteReaction({required String patientId, required String allergyId, required String reactionId}) async {
    final response = await networkClient.invoke(
      ReactionEndPoints.delete(patientId: patientId, allergyId: allergyId, reactionId: reactionId),
      RequestType.delete,
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
