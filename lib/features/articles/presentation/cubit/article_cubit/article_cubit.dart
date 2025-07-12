import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../base/data/models/pagination_model.dart';
import '../../../../../base/data/models/public_response_model.dart';
import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/services/network/network_info.dart';
import '../../../../../base/services/network/resource.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../data/data_sources/articles_remote_data_sources.dart';
import '../../../data/model/article_model.dart';

part 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticlesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ArticleCubit({required this.remoteDataSource, required this.networkInfo})
    : super(ArticleInitial());

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ArticleModel> _allArticles = [];

  Future<void> getAllArticles({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
    int perPage = 6,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allArticles = [];
      emit(ArticleLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ArticleError(error: 'No internet connection'));
    //   ShowToast.showToastError(
    //     message: 'No internet connection. Please check your network.',
    //   );
    //   return;
    // }

    final result = await remoteDataSource.getAllArticles(
      filters: _currentFilters,
      page: _currentPage,
      perPage: perPage,
    );

    if (result is Success<PaginatedResponse<ArticleModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allArticles.addAll(result.data.paginatedData!.items);
        _hasMore =
            result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(
          ArticleSuccess(
            hasMore: _hasMore,
            paginatedResponse: PaginatedResponse<ArticleModel>(
              paginatedData: PaginatedData<ArticleModel>(items: _allArticles),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(
          ArticleError(error: result.data.msg ?? 'Failed to fetch articles'),
        );
      }
    } else if (result is ResponseError<PaginatedResponse<ArticleModel>>) {
      emit(ArticleError(error: result.message ?? 'Failed to fetch articles'));
    }
  }

  int _currentMyArticlesPage = 1;
  bool _hasMoreMyArticles = true;
  Map<String, dynamic> _currentFiltersMyArticles = {};
  List<ArticleModel> _allMyArticles = [];

  Future<void> getMyArticles({
    Map<String, dynamic>? filters,
    bool loadMore = false,
    required BuildContext context,
    int perPage = 6,
  }) async {
    if (!loadMore) {
      _currentMyArticlesPage = 1;
      _hasMoreMyArticles = true;
      _allMyArticles = [];
      emit(ArticleLoading());
    } else if (!_hasMoreMyArticles) {
      return;
    }

    if (filters != null) {
      _currentFiltersMyArticles = filters;
    }

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ArticleError(error: 'No internet connection'));
    //   ShowToast.showToastError(
    //     message: 'No internet connection. Please check your network.',
    //   );
    //   return;
    // }

    final result = await remoteDataSource.getMyArticles(
      filters: _currentFiltersMyArticles,
      page: _currentMyArticlesPage,
      perPage: perPage,
    );

    if (result is Success<PaginatedResponse<ArticleModel>>) {
      if (result.data.msg == "Unauthorized. Please login first.") {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      try {
        _allMyArticles.addAll(result.data.paginatedData!.items);
        _hasMoreMyArticles =
            result.data.paginatedData!.items.isNotEmpty &&
            result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentMyArticlesPage++;

        emit(
          ArticleSuccess(
            hasMore: _hasMoreMyArticles,
            paginatedResponse: PaginatedResponse<ArticleModel>(
              paginatedData: PaginatedData<ArticleModel>(items: _allMyArticles),
              meta: result.data.meta,
              links: result.data.links,
            ),
          ),
        );
      } catch (e) {
        emit(
          ArticleError(error: result.data.msg ?? 'Failed to fetch articles'),
        );
      }
    } else if (result is ResponseError<PaginatedResponse<ArticleModel>>) {
      emit(ArticleError(error: result.message ?? 'Failed to fetch articles'));
    }
  }

  Future<void> getDetailsArticle({
    required String articleId,
    required BuildContext context,
  }) async {
    emit(ArticleLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ArticleError(error: 'No internet connection'));
    //   ShowToast.showToastError(
    //     message: 'No internet connection. Please check your network.',
    //   );
    //   return;
    // }

    final result = await remoteDataSource.getDetailsArticle(
      articleId: articleId,
    );
    if (result is Success<ArticleModel>) {
      if (result.data.toString().contains("Unauthorized")) {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ArticleDetailsSuccess(article: result.data));
    } else if (result is ResponseError<ArticleModel>) {
      emit(
        ArticleError(
          error: result.message ?? 'Failed to fetch article details',
        ),
      );
    }
  }

  Future<void> createArticle({
    required ArticleModel article,
    required BuildContext context,
  }) async {
    emit(ArticleLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ArticleError(error: 'No internet connection'));
    //   ShowToast.showToastError(
    //     message: 'No internet connection. Please check your network.',
    //   );
    //   return;
    // }

    final result = await remoteDataSource.createArticle(article: article);
    if (result is Success<PublicResponseModel>) {
      if (result.data.toString().contains("Unauthorized")) {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ArticleCreateSuccess());
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(
        ArticleError(
          error: result.message ?? 'Failed to fetch article details',
        ),
      );
    }
  }

  Future<void> updateArticle({
    required ArticleModel article,
    required String articleId,
    required BuildContext context,
  }) async {
    emit(ArticleLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ArticleError(error: 'No internet connection'));
    //   ShowToast.showToastError(
    //     message: 'No internet connection. Please check your network.',
    //   );
    //   return;
    // }

    final result = await remoteDataSource.updateArticle(
      article: article,
      articleId: articleId,
    );
    if (result is Success<PublicResponseModel>) {
      if (result.data.toString().contains("Unauthorized")) {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ArticleUpdateSuccess());
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(
        ArticleError(
          error: result.message ?? 'Failed to fetch article details',
        ),
      );
    }
  }

  Future<void> deleteArticle({
    required String articleId,
    required BuildContext context,
  }) async {
    emit(ArticleLoading());

    // final isConnected = await networkInfo.isConnected;
    // if (!isConnected) {
    //   context.pushNamed('noInternet');
    //   emit(ArticleError(error: 'No internet connection'));
    //   ShowToast.showToastError(
    //     message: 'No internet connection. Please check your network.',
    //   );
    //   return;
    // }

    final result = await remoteDataSource.deleteArticle(articleId: articleId);
    if (result is Success<PublicResponseModel>) {
      if (result.data.toString().contains("Unauthorized")) {
        context.pushReplacementNamed(AppRouter.login.name);
      }
      emit(ArticleDeleteSuccess());
    } else if (result is ResponseError<PublicResponseModel>) {
      emit(
        ArticleError(
          error: result.message ?? 'Failed to fetch article details',
        ),
      );
    }
  }
}
