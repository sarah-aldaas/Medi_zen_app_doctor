import 'package:dio/dio.dart';
import 'package:medi_zen_app_doctor/base/data/models/public_response_model.dart';

import '../../../../base/data/models/pagination_model.dart';
import '../../../../base/helpers/enums.dart';
import '../../../../base/services/network/network_client.dart';
import '../../../../base/services/network/resource.dart';
import '../../../../base/services/network/response_handler.dart';
import '../end_points/articles_end_points.dart';
import '../model/article_model.dart';

abstract class ArticlesRemoteDataSource {
  Future<Resource<PaginatedResponse<ArticleModel>>> getAllArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<PaginatedResponse<ArticleModel>>> getMyArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10});

  Future<Resource<ArticleModel>> getDetailsArticle({required String articleId});

  Future<Resource<PublicResponseModel>> createArticle({required ArticleModel article});

  Future<Resource<PublicResponseModel>> updateArticle({required ArticleModel article, required String articleId});

  Future<Resource<PublicResponseModel>> deleteArticle({required String articleId});
}

class ArticlesRemoteDataSourceImpl implements ArticlesRemoteDataSource {
  final NetworkClient networkClient;

  ArticlesRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<Resource<PaginatedResponse<ArticleModel>>> getAllArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ArticlesEndPoints.getAllArticles(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ArticleModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ArticleModel>.fromJson(json, 'articles', (dataJson) => ArticleModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<ArticleModel>> getDetailsArticle({required String articleId}) async {
    final response = await networkClient.invoke(ArticlesEndPoints.getDetailsArticle(articleId: articleId), RequestType.get);
    return ResponseHandler<ArticleModel>(response).processResponse(fromJson: (json) => ArticleModel.fromJson(json['article']));
  }

  @override
  Future<Resource<PublicResponseModel>> createArticle({required ArticleModel article}) async {
    final formData = FormData.fromMap(article.createJson());

    if (article.imageFile != null) {
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(article.imageFile!.path, filename: article.imageFile!.path.split('/').last)));
    }

    final response = await networkClient.invokeMultipart(ArticlesEndPoints.createArticles(), RequestType.post, formData: formData);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PublicResponseModel>> deleteArticle({required String articleId}) async {
    final response = await networkClient.invoke(ArticlesEndPoints.deleteArticle(articleId: articleId), RequestType.delete);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }

  @override
  Future<Resource<PaginatedResponse<ArticleModel>>> getMyArticles({Map<String, dynamic>? filters, int page = 1, int perPage = 10}) async {
    final params = {'page': page.toString(), 'pagination_count': perPage.toString(), if (filters != null) ...filters};

    final response = await networkClient.invoke(ArticlesEndPoints.getMyArticles(), RequestType.get, queryParameters: params);

    return ResponseHandler<PaginatedResponse<ArticleModel>>(
      response,
    ).processResponse(fromJson: (json) => PaginatedResponse<ArticleModel>.fromJson(json, 'articles', (dataJson) => ArticleModel.fromJson(dataJson)));
  }

  @override
  Future<Resource<PublicResponseModel>> updateArticle({required ArticleModel article, required String articleId}) async {
    final formData = FormData.fromMap(article.createJson());

    if (article.imageFile != null) {
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(article.imageFile!.path, filename: article.imageFile!.path.split('/').last)));
    }

    final response = await networkClient.invokeMultipart(ArticlesEndPoints.updateArticle(articleId: articleId), RequestType.post, formData: formData);
    return ResponseHandler<PublicResponseModel>(response).processResponse(fromJson: (json) => PublicResponseModel.fromJson(json));
  }
}
