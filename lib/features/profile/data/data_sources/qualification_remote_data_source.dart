import 'package:dio/dio.dart';
import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';
import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';
import 'dart:io';
import '../../../../base/data/models/public_response_model.dart';
import '../end_points/qualification_end_points.dart';

abstract class QualificationRemoteDataSource {
  Future<Resource<PaginatedResponse<QualificationModel>>> getListAllQualifications({required String paginationCount});
  Future<Resource<PublicResponseModel>> updateQualification({required String id, required QualificationModel qualificationModel, File? pdfFile});
  Future<Resource<QualificationModel>> showQualification({required String id});
  Future<Resource<PublicResponseModel>> deleteQualification({required String id});
  Future<Resource<PublicResponseModel>> createQualification({required QualificationModel qualificationModel, required File pdfFile});
}

class QualificationRemoteDataSourceImpl implements QualificationRemoteDataSource {
  final NetworkClient networkClient;

  QualificationRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PublicResponseModel>> createQualification({required QualificationModel qualificationModel, required File pdfFile}) async {
    final formData = FormData.fromMap({
      ...qualificationModel.toJson(),
      'pdf': await MultipartFile.fromFile(
        pdfFile.path,
        filename: qualificationModel.pdfFileName,
      ),
    });

    final response = await networkClient.invokeMultipart(
      QualificationEndPoints.createQualification,
      RequestType.post,
      formData: formData,
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> deleteQualification({required String id}) async {
    final response = await networkClient.invoke(
      QualificationEndPoints.deleteQualification(id: id),
      RequestType.delete,
    );
    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }

  @override
  Future<Resource<PaginatedResponse<QualificationModel>>> getListAllQualifications({
    required String paginationCount,
  }) async {
    final response = await networkClient.invoke(
      QualificationEndPoints.listAllQualifications(paginationCount: paginationCount),
      RequestType.get,
    );

    return ResponseHandler<PaginatedResponse<QualificationModel>>(response).processResponse(
      fromJson: (json) => PaginatedResponse<QualificationModel>.fromJson(
        json,
        'qualifications',
            (dataJson) => QualificationModel.fromJson(dataJson),
      ),
    );
  }

  @override
  Future<Resource<QualificationModel>> showQualification({required String id}) async {
    final response = await networkClient.invoke(
      QualificationEndPoints.showQualification(id: id),
      RequestType.get,
    );
    return ResponseHandler<QualificationModel>(response).processResponse(
      fromJson: (json) => QualificationModel.fromJson(json['qualification']),
    );
  }

  @override
  Future<Resource<PublicResponseModel>> updateQualification({
    required String id,
    required QualificationModel qualificationModel,
    File? pdfFile,
  }) async {
    final formData = FormData.fromMap({
      ...qualificationModel.toJson(),
      if (pdfFile != null)
        'pdf': await MultipartFile.fromFile(
          pdfFile.path,
          filename: qualificationModel.pdfFileName,
        ),
    });

    final response = await networkClient.invokeMultipart(
      QualificationEndPoints.updateQualification(id: id),
      RequestType.post,
      formData: formData,
    );

    return ResponseHandler<PublicResponseModel>(response).processResponse(
      fromJson: (json) => PublicResponseModel.fromJson(json),
    );
  }
}


// import 'package:medi_zen_app_doctor/base/data/models/pagination_model.dart';
// import 'package:medi_zen_app_doctor/base/helpers/enums.dart';
// import 'package:medi_zen_app_doctor/base/services/network/network_client.dart';
// import 'package:medi_zen_app_doctor/base/services/network/resource.dart';
// import 'package:medi_zen_app_doctor/base/services/network/response_handler.dart';
// import 'package:medi_zen_app_doctor/features/profile/data/models/qualification_model.dart';
// import '../../../../base/data/models/public_response_model.dart';
// import '../end_points/qualification_end_points.dart';
//
// abstract class QualificationRemoteDataSource {
//   Future<Resource<PaginatedResponse<QualificationModel>>> getListAllQualifications({required String paginationCount});
//   Future<Resource<PublicResponseModel>> updateQualification({required String id, required QualificationModel qualificationModel});
//   Future<Resource<QualificationModel>> showQualification({required String id});
//   Future<Resource<PublicResponseModel>> deleteQualification({required String id});
//   Future<Resource<PublicResponseModel>> createQualification({required QualificationModel qualificationModel});
// }
//
// class QualificationRemoteDataSourceImpl implements QualificationRemoteDataSource {
//   final NetworkClient networkClient;
//
//   QualificationRemoteDataSourceImpl({required this.networkClient});
//
//   @override
//   Future<Resource<PublicResponseModel>> createQualification({required QualificationModel qualificationModel}) async {
//     final response = await networkClient.invoke(
//         QualificationEndPoints.createQualification,
//         RequestType.post,
//         body: qualificationModel.toJson()
//     );
//     return ResponseHandler<PublicResponseModel>(response).processResponse(
//         fromJson: (json) => PublicResponseModel.fromJson(json)
//     );
//   }
//
//   @override
//   Future<Resource<PublicResponseModel>> deleteQualification({required String id}) async {
//     final response = await networkClient.invoke(
//         QualificationEndPoints.deleteQualification(id: id),
//         RequestType.delete
//     );
//     return ResponseHandler<PublicResponseModel>(response).processResponse(
//         fromJson: (json) => PublicResponseModel.fromJson(json)
//     );
//   }
//
//   @override
//   Future<Resource<PaginatedResponse<QualificationModel>>> getListAllQualifications({
//     required String paginationCount,
//   }) async {
//     final response = await networkClient.invoke(
//       QualificationEndPoints.listAllQualifications(paginationCount: paginationCount),
//       RequestType.get,
//     );
//
//     return ResponseHandler<PaginatedResponse<QualificationModel>>(response).processResponse(
//         fromJson: (json) => PaginatedResponse<QualificationModel>.fromJson(
//       json,
//       'qualifications',
//           (dataJson) => QualificationModel.fromJson(dataJson),
//     ));
//   }
//
//   @override
//   Future<Resource<QualificationModel>> showQualification({required String id}) async {
//     final response = await networkClient.invoke(
//         QualificationEndPoints.showQualification(id: id),
//         RequestType.get
//     );
//     return ResponseHandler<QualificationModel>(response).processResponse(
//         fromJson: (json) => QualificationModel.fromJson(json['qualification'])
//     );
//   }
//
//   @override
//   Future<Resource<PublicResponseModel>> updateQualification({
//     required String id,
//     required QualificationModel qualificationModel
//   }) async {
//     final response = await networkClient.invoke(
//         QualificationEndPoints.updateQualification(id: id),
//         RequestType.post,
//         body: qualificationModel.toJson()
//     );
//     return ResponseHandler<PublicResponseModel>(response).processResponse(
//         fromJson: (json) => PublicResponseModel.fromJson(json)
//     );
//   }
// }