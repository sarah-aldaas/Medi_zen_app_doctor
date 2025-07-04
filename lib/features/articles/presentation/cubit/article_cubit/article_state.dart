part of 'article_cubit.dart';

@immutable
sealed class ArticleState {
  const ArticleState();
}

final class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {
  final bool isLoadMore;

  const ArticleLoading({this.isLoadMore = false});
}

class FavoriteOperationLoading extends ArticleState {}

class ArticleGenerateLoading extends ArticleState {}

class ArticleSuccess extends ArticleState {
  final bool hasMore;
  final PaginatedResponse<ArticleModel> paginatedResponse;

  const ArticleSuccess({
    required this.paginatedResponse,
    required this.hasMore,
  });
}

class ArticleDetailsSuccess extends ArticleState {
  final ArticleModel article;

  const ArticleDetailsSuccess({
    required this.article,
  });
}

class ArticleConditionSuccess extends ArticleState {
  final ArticleModel? article;

  const ArticleConditionSuccess({
    required this.article,
  });
}

class FavoriteOperationSuccess extends ArticleState {
  final bool isFavorite;

  const FavoriteOperationSuccess({
    required this.isFavorite,
  });
}

class ArticleGenerateSuccess extends ArticleState {
  final PublicResponseModel response;

  const ArticleGenerateSuccess({
    required this.response,
  });
}

class ArticleGenerateProgress extends ArticleState {
  final double progress;
  final String? message;

  const ArticleGenerateProgress({this.progress = 0, this.message});
}
class ArticleError extends ArticleState {
  final String error;

  const ArticleError({required this.error});
}

class ArticleCreateSuccess extends ArticleState {}
class ArticleUpdateSuccess extends ArticleState {}
class ArticleDeleteSuccess extends ArticleState {}