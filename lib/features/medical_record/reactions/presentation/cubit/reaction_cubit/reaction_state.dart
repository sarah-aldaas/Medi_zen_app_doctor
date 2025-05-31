part of 'reaction_cubit.dart';

@immutable
sealed class ReactionState {}

final class ReactionInitial extends ReactionState {}

class ReactionLoading extends ReactionState {}

class ReactionListSuccess extends ReactionState {
  final PaginatedResponse<ReactionModel> paginatedResponse;
  final bool hasMore;

  ReactionListSuccess({required this.paginatedResponse, required this.hasMore});
}

class ReactionDetailsSuccess extends ReactionState {
  final ReactionModel reaction;

  ReactionDetailsSuccess({required this.reaction});
}

class ReactionActionSuccess extends ReactionState {}

class ReactionError extends ReactionState {
  final String error;

  ReactionError({required this.error});
}