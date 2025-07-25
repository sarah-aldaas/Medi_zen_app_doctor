import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/schedule/data/model/schedule_model.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/widgets/vacation_form_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/model/vacation_model.dart';
import '../cubit/vacation_cubit/vacation_cubit.dart';

class VacationDetailsPage extends StatefulWidget {
  final ScheduleModel schedule;
  final String vacationId;

  const VacationDetailsPage({
    required this.schedule,
    required this.vacationId,
    super.key,
  });

  @override
  State<VacationDetailsPage> createState() => _VacationDetailsPageState();
}

class _VacationDetailsPageState extends State<VacationDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<VacationCubit>().getVacationDetails(widget.vacationId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'vacationDetailsPage.title'.tr(context),
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body: BlocConsumer<VacationCubit, VacationState>(
        listener: (context, state) {
          if (state is VacationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Cannot update vacation that has already started.",
                ),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is VacationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('vacationDetailsPage.updateSuccess'.tr(context)),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VacationLoading) {
            return const Center(child: LoadingPage());
          } else if (state is VacationDetailsLoaded) {
            return _buildVacationDetailsContent(context, state.vacation);
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied_outlined,
                      size: 70,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'vacationDetailsPage.errorTitle'.tr(context),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'vacationDetailsPage.errorMessage'.tr(context),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildVacationDetailsContent(
    BuildContext context,
    VacationModel vacation,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      color:
          theme.brightness == Brightness.light
              ? Colors.grey[50]
              : Colors.grey[900],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flight_takeoff,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            vacation.reason ??
                                'vacationDetailsPage.plannedVacationDefault'.tr(
                                  context,
                                ),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      context,
                      'vacationDetailsPage.vacationDatesLabel'.tr(context),
                      '${DateFormat('MMMM d, y').format(vacation.startDate!)} - '
                      '${DateFormat('MMMM d, y').format(vacation.endDate!)}',
                      Icons.calendar_today,
                      isMain: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'vacationDetailsPage.additionalDetailsTitle'.tr(context),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (vacation.schedule != null) ...[
                      _buildDetailItem(
                        context,
                        'vacationDetailsPage.associatedScheduleLabel'.tr(
                          context,
                        ),
                        vacation.schedule!.name,
                        Icons.schedule,
                      ),
                      const Divider(height: 28, thickness: 0.8),
                    ],
                    if (vacation.reason != null && vacation.reason!.isNotEmpty)
                      _buildDetailItem(
                        context,
                        'vacationDetailsPage.detailedReasonLabel'.tr(context),
                        vacation.reason!,
                        Icons.description,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VacationFormPage(
                            schedule: widget.schedule,
                            initialVacation: vacation,
                          ),
                    ),
                  ).then((_) {
                    if (mounted) {
                      context.read<VacationCubit>().getVacationDetails(
                        widget.vacationId,
                      );
                    }
                  });
                },
                icon: const Icon(Icons.edit_calendar, size: 28),
                label: Text(
                  'vacationDetailsPage.editVacationButton'.tr(context),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isMain = false,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isMain ? 32 : 28,
          color: isMain ? Colors.white.withOpacity(0.9) : primaryColor,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isMain ? Colors.white.withOpacity(0.8) : primaryColor,
                  letterSpacing: isMain ? 0.2 : 0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style:
                    isMain
                        ? theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )
                        : theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.85),
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
