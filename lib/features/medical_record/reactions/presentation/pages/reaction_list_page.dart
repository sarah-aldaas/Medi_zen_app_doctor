import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';

import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/reaction_filter_model.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/reaction_cubit/reaction_cubit.dart';
import '../widgets/reaction_filter_dialog.dart';

class ReactionListPage extends StatefulWidget {
  final int patientId;
  final int allergyId;

  const ReactionListPage({
    super.key,
    required this.patientId,
    required this.allergyId,
  });

  @override
  State<ReactionListPage> createState() => _ReactionListPageState();
}

class _ReactionListPageState extends State<ReactionListPage> {
  final ScrollController _scrollController = ScrollController();
  ReactionFilterModel _filter = ReactionFilterModel();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialReactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialReactions() {
    _isLoadingMore = false;
    context.read<ReactionCubit>().listAllergyReactions(
      patientId: widget.patientId,
      allergyId: widget.allergyId,
      filters: _filter.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<ReactionCubit>()
          .listAllergyReactions(
            patientId: widget.patientId,
            allergyId: widget.allergyId,
            filters: _filter.toJson(),
            loadMore: true,
          )
          .then((_) {
            setState(() => _isLoadingMore = false);
          });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<ReactionFilterModel>(
      context: context,
      builder: (context) => ReactionFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialReactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'reactionList.allergyReactions'.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryColor),
            onPressed:
                () => context
                    .pushNamed(
                      AppRouter.createEditReaction.name,
                      extra: {
                        'patientId': widget.patientId,
                        'allergyId': widget.allergyId,
                      },
                    )
                    .then((_) => _loadInitialReactions()),
          ),
        ],
      ),
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading && !_isLoadingMore) {
            return Center(child: LoadingPage());
          }

          final reactions =
              state is ReactionListSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : [];
          final hasMore = state is ReactionListSuccess ? state.hasMore : false;

          if (reactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "reactionList.noReactionsFound".tr(context),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: reactions.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < reactions.length) {
                return _buildReactionItem(reactions[index]);
              } else if (hasMore && state is! ReactionError) {
                return Center(child: LoadingPage());
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildReactionItem(ReactionModel reaction) {
    return Card(
      color: Theme.of(context).appBarTheme.backgroundColor,
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          reaction.substance ?? 'reactionList.unknownSubstance'.tr(context),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reaction.manifestation ??
                  'reactionList.noManifestation'.tr(context),
            ),
            Text(
              'reactionList.severity'.tr(context) +
                  ': ${reaction.severity?.display ?? 'reactionList.notApplicable'.tr(context)}',
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primaryColor,
        ),
        onTap:
            () => context
                .pushNamed(
                  AppRouter.reactionDetails.name,
                  extra: {
                    'patientId': widget.patientId,
                    'allergyId': widget.allergyId,
                    'reactionId': reaction.id,
                  },
                )
                .then((_) => _loadInitialReactions()),
      ),
    );
  }
}
