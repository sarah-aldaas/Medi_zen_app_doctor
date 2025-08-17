import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../../../encounters/presentation/cubit/encounter_cubit/encounter_cubit.dart';
import '../../data/models/conditions_filter_model.dart';
import '../../data/models/conditions_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';
import '../widgets/create_condition_page.dart';
import 'condition_details_page.dart';

class ConditionsListOfAppointmentPage extends StatefulWidget {
  final ConditionsFilterModel filter;
  final String appointmentId;
  final String patientId;

  const ConditionsListOfAppointmentPage({
    super.key,
    required this.filter,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  _ConditionsListOfAppointmentPageState createState() =>
      _ConditionsListOfAppointmentPageState();
}

class _ConditionsListOfAppointmentPageState
    extends State<ConditionsListOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  bool _hasEncounters(EncounterState state) {
    if (state is EncounterError) {
      return false;
    }

    final encounters =
        state is EncounterDetailsSuccess
            ? [state.encounter]
            : state is EncounterListSuccess
            ? state.paginatedResponse.paginatedData!.items
            : <EncounterModel>[];
    return encounters.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialConditions();
  }

  String? _errorMessage;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConditionsListOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter ||
        widget.patientId != oldWidget.patientId) {
      _loadInitialConditions();
    }
  }

  void _loadInitialConditions() {
    _errorMessage = null;
    setState(() => _isLoadingMore = false);

    context.read<ConditionsCubit>().getConditionsForAppointment(
      appointmentId: widget.appointmentId,
      patientId: widget.patientId,
      context: context,
      filters: widget.filter.toJson(),
    );
    context.read<EncounterCubit>().getAppointmentEncounters(
      patientId: widget.patientId,
      appointmentId: widget.appointmentId,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future = context
          .read<ConditionsCubit>()
          .getConditionsForAppointment(
            appointmentId: widget.appointmentId,
            patientId: widget.patientId,
            loadMore: true,
            context: context,
            filters: widget.filter.toJson(),
          );

      future.then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocBuilder<EncounterCubit, EncounterState>(
      builder: (context, _state) {
        final hasEncounters = _hasEncounters(_state);

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (hasEncounters) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateConditionPage(
                          patientId: widget.patientId,
                          appointmentId: widget.appointmentId,
                        ),
                  ),
                ).then((_) => _loadInitialConditions());
              } else {
                ShowToast.showToastInfo(
                  message: 'conditionsOfAppointment.should_add_encounter'.tr(
                    context,
                  ),
                );
              }
            },
            backgroundColor: AppColors.primaryColor,
            tooltip: 'conditionsOfAppointment.addCondition'.tr(context),
            child:
                _state is EncounterLoading
                    ? LoadingButton(isWhite: true)
                    : Icon(Icons.add, color: AppColors.whiteColor),
          ),
          body: BlocConsumer<ConditionsCubit, ConditionsState>(
            listener: (context, state) {
              if (state is ConditionsError) {
                // ShowToast.showToastError(message: state.error);
              } else if (state is ConditionCreatedSuccess ||
                  state is ConditionUpdatedSuccess ||
                  state is ConditionDeletedSuccess) {
                // _loadInitialConditions();
              }
            },
            builder: (context, state) {
              if (state is ConditionsLoading && !state.isLoadMore) {
                return const Center(child: LoadingPage());
              }

              final conditions =
                  state is ConditionsSuccess
                      ? state.paginatedResponse.paginatedData?.items ?? []
                      : [];
              final hasMore =
                  state is ConditionsSuccess ? state.hasMore : false;
              if (_errorMessage != null && conditions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 70,
                          color: AppColors.primaryColor,
                        ),
                        const Gap(16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(16),
                        OutlinedButton.icon(
                          onPressed: _loadInitialConditions,
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context)
                                .outlinedButtonTheme
                                .style
                                ?.foregroundColor
                                ?.resolve({MaterialState.pressed}),
                          ),
                          label: Text(
                            "encounterPage.try_again".tr(context),
                            style:
                                Theme.of(context)
                                            .outlinedButtonTheme
                                            .style
                                            ?.foregroundColor
                                            ?.resolve({
                                              MaterialState.pressed,
                                            }) !=
                                        null
                                    ? TextStyle(
                                      color: Theme.of(context)
                                          .outlinedButtonTheme
                                          .style!
                                          .foregroundColor!
                                          .resolve({MaterialState.pressed}),
                                    )
                                    : null,
                          ),
                          style: Theme.of(context).outlinedButtonTheme.style,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (conditions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 70,
                          color: AppColors.primaryColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "conditionsOfAppointment.noConditionsFound".tr(
                            context,
                          ),
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _loadInitialConditions,
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context)
                                .outlinedButtonTheme
                                .style
                                ?.foregroundColor
                                ?.resolve({MaterialState.pressed}),
                          ),
                          label: Text(
                            "encounterPage.try_again".tr(context),
                            style:
                                Theme.of(context)
                                            .outlinedButtonTheme
                                            .style
                                            ?.foregroundColor
                                            ?.resolve({
                                              MaterialState.pressed,
                                            }) !=
                                        null
                                    ? TextStyle(
                                      color: Theme.of(context)
                                          .outlinedButtonTheme
                                          .style!
                                          .foregroundColor!
                                          .resolve({MaterialState.pressed}),
                                    )
                                    : null,
                          ),
                          style: Theme.of(context).outlinedButtonTheme.style,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadInitialConditions(),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: conditions.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < conditions.length) {
                      return _buildConditionItem(conditions[index]);
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: LoadingButton()),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildConditionItem(ConditionsModel condition) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ConditionDetailsPage(
                      conditionId: condition.id!,
                      patientId: widget.patientId,
                      appointmentId: widget.appointmentId,
                    ),
              ),
            ).then((value) {
              _loadInitialConditions();
            }),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon(Icons.medical_information, color: AppColors.primaryColor, size: 28),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      condition.healthIssue ??
                          'conditionsList.unknownCondition'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.green),
                ],
              ),
              Divider(height: 20, thickness: 1, color: Colors.grey[200]),
              const Gap(10),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'conditionsList.onsetDate'.tr(context),
                value:
                    condition.onSetDate != null
                        ? DateFormat(
                          'MMM d, y',
                        ).format(DateTime.parse(condition.onSetDate!))
                        : 'conditionsList.notAvailable'.tr(context),
                color: Theme.of(context).primaryColor,
              ),
              if (condition.clinicalStatus != null)
                _buildInfoRow(
                  icon: Icons.monitor_heart,
                  label: 'conditionsList.clinicalStatus'.tr(context),
                  value: condition.clinicalStatus!.display,
                  color: Theme.of(context).primaryColor,
                ),
              if (condition.verificationStatus != null)
                _buildInfoRow(
                  icon: Icons.verified,
                  label: 'conditionsList.verificationStatus'.tr(context),
                  value: condition.verificationStatus!.display,
                  color: Theme.of(context).primaryColor,
                ),
              if (condition.stage != null)
                _buildInfoRow(
                  icon: Icons.insights,
                  label: 'conditionsList.stage'.tr(context),
                  value: condition.stage!.display,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    int maxLines = 2,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '$label:',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.label,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    // style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
