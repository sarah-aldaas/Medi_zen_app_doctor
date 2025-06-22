import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/create_edit_encounter_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_details_page.dart';
import '../../../../../base/theme/app_color.dart';
import '../../data/models/encounter_filter_model.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/encounter_filter_dialog.dart';

const double _kCardMarginVertical = 8.0;
const double _kCardMarginHorizontal = 16.0;
const double _kCardElevation = 4.0;
const double _kCardBorderRadius = 16.0;
const double _kCardPaddingVertical = 16.0;
const double _kCardPaddingHorizontal = 20.0;

class EncounterListPage extends StatefulWidget {
  final String patientId;
  final String? appointmentId;

  const EncounterListPage({
    super.key,
    required this.patientId,
    this.appointmentId,
  });

  @override
  State<EncounterListPage> createState() => _EncounterListPageState();
}

class _EncounterListPageState extends State<EncounterListPage> {
  final ScrollController _scrollController = ScrollController();
  EncounterFilterModel _filter = EncounterFilterModel();
  bool _isLoadingMore = false;
  List<EncounterModel> list = [];
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialEncounters();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialEncounters() async {
    setState(() {
      _errorMessage = null;
      _isLoadingMore = false;
    });

    final cubit = context.read<EncounterCubit>();
    try {
      if (widget.appointmentId != null) {
        await cubit.getAppointmentEncounters(
          patientId: widget.patientId,
          appointmentId: widget.appointmentId!,
        );
      } else {
        await cubit.getPatientEncounters(
          patientId: widget.patientId,
          filters: _filter.toJson(),
        );
      }
    } catch (e) {
      print("Error loading initial encounters: $e");
    }
  }

  void _loadMoreEncounters() {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    final cubit = context.read<EncounterCubit>();

    Future<void> loadFuture;
    if (widget.appointmentId != null) {
      context.read<EncounterCubit>().getAppointmentEncounters(
        patientId: widget.patientId,
        appointmentId: widget.appointmentId!,
      );
    } else {
      loadFuture = cubit.getPatientEncounters(
        patientId: widget.patientId,
        filters: _filter.toJson(),
        loadMore: true,
      );
    }

  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future =
      widget.appointmentId != null
          ? context.read<EncounterCubit>().getAppointmentEncounters(
        patientId: widget.patientId,
        appointmentId: widget.appointmentId!,
      )
          : context.read<EncounterCubit>().getPatientEncounters(
        patientId: widget.patientId,
        filters: _filter.toJson(),
        loadMore: true,
      );
      future.then((_) => setState(() => _isLoadingMore = false));
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<EncounterFilterModel>(
      context: context,
      builder: (context) => EncounterFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialEncounters();
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green.shade700;
      case 'in_progress':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      case 'planned':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateEditEncounterPage(
                  patientId: widget.patientId,
                  appointmentId: widget.appointmentId,
                ),
              ),
            ).then((_) => _loadInitialEncounters());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'encounterPage.add_encounter'.tr(context),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Gap(10),
              Icon(Icons.add, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),

      body: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            _errorMessage = state.error;
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
          }
          if (state is EncounterListSuccess) {
            list = state.paginatedResponse.paginatedData!.items;
          }

          if (state is EncounterDetailsSuccess) {
            list = state.encounter != null ? [state.encounter!] : [];
          }

          final encounters =
          state is EncounterDetailsSuccess
              ? [state.encounter]
              : state is EncounterListSuccess
              ? state.paginatedResponse.paginatedData!.items
              : <EncounterModel>[];
          final hasMore = state is EncounterListSuccess ? state.hasMore : false;

          if (_errorMessage != null && encounters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
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
                      onPressed: _loadInitialEncounters,
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
                            ?.resolve({MaterialState.pressed}) !=
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

          if (encounters.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 80,
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                    const Gap(24),
                    Text(
                      "encounterPage.no_encounters_found_title".tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      "encounterPage.no_encounters_found_tip".tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryColor.withOpacity(0.7),
                      ),
                    ),
                    const Gap(24),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _filter = EncounterFilterModel();
                        });
                        _loadInitialEncounters();
                      },
                      icon: Icon(
                        Icons.filter_alt_off,
                        color: Theme.of(context)
                            .outlinedButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({MaterialState.pressed}),
                      ),
                      label: Text(
                        "encounterPage.clear_filters".tr(context),
                        style:
                        Theme.of(context)
                            .outlinedButtonTheme
                            .style
                            ?.foregroundColor
                            ?.resolve({MaterialState.pressed}) !=
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
                    const Gap(16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CreateEditEncounterPage(
                              patientId: widget.patientId,
                              appointmentId: widget.appointmentId,
                            ),
                          ),
                        ).then((_) => _loadInitialEncounters());
                      },
                      icon: Icon(
                        Icons.add_box_outlined,
                        color: AppColors.primaryColor,
                      ),
                      label: Text(
                        "encounterPage.add_new_encounter".tr(context),
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                      style: Theme.of(context).elevatedButtonTheme.style,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadInitialEncounters,
            color: AppColors.primaryColor,
            backgroundColor: AppColors.whiteColor,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: encounters.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < encounters.length) {
                  return _EncounterCard(
                    encounter: encounters[index]!,
                    showAppointmentReason: widget.appointmentId == null,
                    statusColor: _getStatusColor(
                      encounters[index]!.status?.display,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EncounterDetailsPage(
                            patientId: widget.patientId,
                            encounterId: encounters[index]!.id!,
                          ),
                        ),
                      ).then((_) => _loadInitialEncounters());
                    },
                  );
                } else if (hasMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

class _EncounterCard extends StatelessWidget {
  final EncounterModel encounter;
  final bool showAppointmentReason;
  final Color statusColor;
  final VoidCallback onTap;

  const _EncounterCard({
    required this.encounter,
    required this.showAppointmentReason,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    String formattedDate = 'N/A';
    String formattedTime = '';
    try {
      if (encounter.actualStartDate != null) {
        final dateTime = DateTime.parse(encounter.actualStartDate!);
        formattedDate = DateFormat('EEE, MMM d, y').format(dateTime);
        formattedTime = DateFormat('hh:mm a').format(dateTime);
      }
    } catch (e) {
      formattedDate = encounter.actualStartDate ?? 'encounterPage.not_available_short'.tr(context);
    }

    return Card(
      color: Theme.of(context).appBarTheme.backgroundColor,
      margin: const EdgeInsets.symmetric(
        horizontal: _kCardMarginHorizontal,
        vertical: _kCardMarginVertical,
      ),
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        side: BorderSide(color: Theme.of(context).cardColor, width: 2.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kCardPaddingHorizontal,
            vertical: _kCardPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      encounter.reason ?? 'encounterPage.no_reason_specified'.tr(context),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(15),
                  Chip(
                    label: Text(
                      encounter.status?.display ?? 'encounterPage.unknown_status'.tr(context),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const Gap(8),
                  Text(
                    formattedDate,
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Gap(16),
                  Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const Gap(8),
                  Text(
                    formattedTime,
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              if (showAppointmentReason) ...[
                const Gap(15),
                Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        '${'encounterPage.appointment_label'.tr(context)}: ${encounter.appointment?.reason ?? 'encounterPage.not_available_short'.tr(context)}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}