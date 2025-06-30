import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/go_router/go_router.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/reaction_model.dart';
import '../cubit/reaction_cubit/reaction_cubit.dart';

class ReactionDetailsPage extends StatefulWidget {
  final String patientId;
  final String allergyId;
  final String reactionId;

  const ReactionDetailsPage({
    super.key,
    required this.patientId,
    required this.allergyId,
    required this.reactionId,
  });

  @override
  State<ReactionDetailsPage> createState() => _ReactionDetailsPageState();
}

class _ReactionDetailsPageState extends State<ReactionDetailsPage> {
  @override
  void initState() {
    super.initState();

    context.read<ReactionCubit>().viewReaction(
      patientId: widget.patientId,
      allergyId: widget.allergyId,
      reactionId: widget.reactionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'reactionDetailsPage.title'.tr(context),
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<ReactionCubit, ReactionState>(
            builder: (context, state) {
              if (state is ReactionDetailsSuccess) {
                return PopupMenuButton<String>(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  iconColor: AppColors.primaryColor,
                  onSelected: (value) {
                    if (value == 'edit') {
                      context
                          .pushNamed(
                            AppRouter.createEditReaction.name,
                            extra: {
                              'patientId': widget.patientId,
                              'allergyId': widget.allergyId,
                              'reaction': state.reaction,
                            },
                          )
                          .then(
                            (_) => context.read<ReactionCubit>().viewReaction(
                              patientId: widget.patientId,
                              allergyId: widget.allergyId,
                              reactionId: widget.reactionId,
                            ),
                          );
                    } else if (value == 'delete') {
                      _showDeleteConfirmationDialog(state.reaction);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            'reactionDetailsPage.editButton'.tr(context),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'reactionDetailsPage.deleteButton'.tr(context),
                          ),
                        ),
                      ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ReactionCubit, ReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is ReactionActionSuccess) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is ReactionDetailsSuccess) {
            return _buildReactionDetails(
              state.reaction,
              primaryColor,
              textColor!,
              subTextColor,
            );
          } else if (state is ReactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'reactionDetailsPage.errorLoadingReactions'.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReactionCubit>().viewReaction(
                        patientId: widget.patientId,
                        allergyId: widget.allergyId,
                        reactionId: widget.reactionId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      'reactionDetailsPage.retryLoadingButton'.tr(context),
                    ), // Localized
                  ),
                ],
              ),
            );
          }
          return Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildReactionDetails(
    ReactionModel reaction,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reaction.substance ??
                'reactionDetailsPage.unknownSubstance'.tr(context),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            reaction.manifestation ??
                'reactionDetailsPage.noManifestation'.tr(context),
            style: TextStyle(fontSize: 17, color: subTextColor),
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text(
            'reactionDetailsPage.detailsSectionTitle'.tr(context),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            reaction.description ??
                'reactionDetailsPage.noAdditionalDetails'.tr(context),
            style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),

          Row(
            children: [
              Icon(Icons.warning_outlined, color: primaryColor, size: 26),
              const Gap(10),
              Text(
                '${'reactionDetailsPage.severityLabel'.tr(context)} ${reaction.severity?.display ?? 'reactionDetailsPage.notApplicable'.tr(context)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const Gap(20),

          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                color: primaryColor,
                size: 26,
              ),
              const Gap(10),
              Text(
                '${'reactionDetailsPage.exposureRouteLabel'.tr(context)} ${reaction.exposureRoute?.display ?? 'reactionDetailsPage.notApplicable'.tr(context)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),

          Text(
            'reactionDetailsPage.onsetSectionTitle'.tr(context),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Gap(10),
          Text(
            reaction.onSet ?? 'reactionDetailsPage.unknownOnset'.tr(context),
            style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
          ),
          const Gap(30),
          if (reaction.note != null) ...[
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text(
              'reactionDetailsPage.notesSectionTitle'.tr(context),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Gap(10),
            Text(
              reaction.note!,
              style: TextStyle(fontSize: 17, color: textColor, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(ReactionModel reaction) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'reactionDetailsPage.deleteConfirmationTitle'.tr(context),
            ),
            content: Text(
              'reactionDetailsPage.deleteConfirmationContent'.tr(context),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('reactionDetailsPage.cancelButton'.tr(context)),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ReactionCubit>().deleteReaction(
                    patientId: widget.patientId,
                    allergyId: widget.allergyId,
                    reactionId: reaction.id!,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'reactionDetailsPage.confirmDeleteButton'.tr(context),
                ),
              ),
            ],
          ),
    );
  }
}
