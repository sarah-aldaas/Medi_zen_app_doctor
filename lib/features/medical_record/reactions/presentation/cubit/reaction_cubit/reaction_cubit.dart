import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../../base/data/models/pagination_model.dart';
import '../../../../../../base/data/models/public_response_model.dart';
import '../../../../../../base/services/network/resource.dart';
import '../../../../../../base/widgets/show_toast.dart';
import '../../../data/data_source/reactions_remote_data_source.dart';
import '../../../data/models/reaction_model.dart';
part 'reaction_state.dart';

class ReactionCubit extends Cubit<ReactionState> {
  final ReactionRemoteDataSource remoteDataSource;
  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _currentFilters = {};
  List<ReactionModel> _allReactions = [];

  ReactionCubit({required this.remoteDataSource}) : super(ReactionInitial());

  Future<void> listAllergyReactions({
    required int patientId,
    required int allergyId,
    Map<String, dynamic>? filters,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      _currentPage = 1;
      _hasMore = true;
      _allReactions = [];
      emit(ReactionLoading());
    } else if (!_hasMore) {
      return;
    }

    if (filters != null) {
      _currentFilters = filters;
    }

    final result = await remoteDataSource.listAllergyReactions(
      patientId: patientId,
      allergyId: allergyId,
      filters: _currentFilters,
      page: _currentPage,
      perPage: 5,
    );

    if (result is Success<PaginatedResponse<ReactionModel>>) {
      try {
        _allReactions.addAll(result.data.paginatedData!.items);
        _hasMore = result.data.paginatedData!.items.isNotEmpty && result.data.meta!.currentPage < result.data.meta!.lastPage;
        _currentPage++;

        emit(ReactionListSuccess(
          paginatedResponse: PaginatedResponse<ReactionModel>(
            paginatedData: PaginatedData<ReactionModel>(items: _allReactions),
            meta: result.data.meta,
            links: result.data.links,
          ),
          hasMore: _hasMore,
        ));
      } catch (e) {
        emit(ReactionError(error: result.data.msg ?? 'Failed to fetch reactions'));
      }
    } else if (result is ResponseError<PaginatedResponse<ReactionModel>>) {
      emit(ReactionError(error: result.message ?? 'Failed to fetch reactions'));
    }
  }

  Future<void> viewReaction({
    required String patientId,
    required String allergyId,
    required String reactionId,
  }) async {
    emit(ReactionLoading());
    try {
      final result = await remoteDataSource.viewReaction(
        patientId: patientId,
        allergyId: allergyId,
        reactionId: reactionId,
      );
      if (result is Success<ReactionModel>) {
        emit(ReactionDetailsSuccess(reaction: result.data));
      } else if (result is ResponseError<ReactionModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to fetch reaction details');
        emit(ReactionError(error: result.message ?? 'Failed to fetch reaction details'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ReactionError(error: e.toString()));
    }
  }

  Future<void> createReaction({
    required int patientId,
    required int allergyId,
    required ReactionModel reaction,
  }) async {
    emit(ReactionLoading());
    try {
      final result = await remoteDataSource.createReaction(
        patientId: patientId,
        allergyId: allergyId,
        reaction: reaction,
      );
      if (result is Success<ReactionModel>) {
        ShowToast.showToastSuccess(message: 'Reaction created successfully');
        emit(ReactionActionSuccess());
      } else if (result is ResponseError<ReactionModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to create reaction');
        emit(ReactionError(error: result.message ?? 'Failed to create reaction'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ReactionError(error: e.toString()));
    }
  }

  Future<void> updateReaction({
    required int patientId,
    required int allergyId,
    required int reactionId,
    required ReactionModel reaction,
  }) async {
    emit(ReactionLoading());
    try {
      final result = await remoteDataSource.updateReaction(
        patientId: patientId,
        allergyId: allergyId,
        reactionId: reactionId,
        reaction: reaction,
      );
      if (result is Success<ReactionModel>) {
        ShowToast.showToastSuccess(message: 'Reaction updated successfully');
        emit(ReactionActionSuccess());
      } else if (result is ResponseError<ReactionModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to update reaction');
        emit(ReactionError(error: result.message ?? 'Failed to update reaction'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ReactionError(error: e.toString()));
    }
  }

  Future<void> deleteReaction({
    required String patientId,
    required String allergyId,
    required String reactionId,
  }) async {
    emit(ReactionLoading());
    try {
      final result = await remoteDataSource.deleteReaction(
        patientId: patientId,
        allergyId: allergyId,
        reactionId: reactionId,
      );
      if (result is Success<PublicResponseModel>) {
        ShowToast.showToastSuccess(message: 'Reaction deleted successfully');
        emit(ReactionActionSuccess());
      } else if (result is ResponseError<PublicResponseModel>) {
        ShowToast.showToastError(message: result.message ?? 'Failed to delete reaction');
        emit(ReactionError(error: result.message ?? 'Failed to delete reaction'));
      }
    } catch (e) {
      ShowToast.showToastError(message: e.toString());
      emit(ReactionError(error: e.toString()));
    }
  }

  void checkAndReload({required int patientId, required int allergyId}) {
    if (state is! ReactionListSuccess) {
      listAllergyReactions(patientId: patientId, allergyId: allergyId);
    }
  }
}