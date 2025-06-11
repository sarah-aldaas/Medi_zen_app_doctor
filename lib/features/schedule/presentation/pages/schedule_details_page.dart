import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/vacations/presentation/pages/vacation_list_page.dart';

import '../../data/model/schedule_model.dart';
import '../cubit/schedule_cubit/schedule_cubit.dart';
import '../widgets/schedule_form_page.dart';

class ScheduleDetailsPage extends StatefulWidget {
  final String scheduleId;

  const ScheduleDetailsPage({required this.scheduleId, super.key});

  @override
  State<ScheduleDetailsPage> createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleCubit>().getScheduleDetails(widget.scheduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      appBar: AppBar(

        elevation: 2,
        centerTitle: false,
        title: Text(
          'Schedule Details',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is ScheduleDetailsLoaded) {
            return _buildScheduleDetails(context, state.schedule);
          } else if (state is ScheduleLoading || state is ScheduleInitial) {
            return const Center(child: LoadingPage());
          } else if (state is ScheduleError) {

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 80,
                      color:
                          isDarkMode
                              ? Colors.red.shade400
                              : Colors
                                  .red
                                  .shade300,
                    ),
                    const Gap(20),
                    Text(
                      'Failed to Load Schedule',
                      style: textTheme.headlineSmall?.copyWith(
                        color:
                            isDarkMode
                                ? Colors.red.shade400
                                : Colors
                                    .red
                                    .shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    Text(
                      'An error occurred: ${state.error}. Please try again.',
                      style: textTheme.bodyLarge?.copyWith(
                        color:
                            isDarkMode
                                ? Colors.grey.shade400
                                : Colors
                                    .grey
                                    .shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(30),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ScheduleCubit>().getScheduleDetails(
                          widget.scheduleId,
                        );
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color:
                            Colors
                                .white,
                      ),
                      label: const Text(
                        'Retry Loading',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(

              child: Text(
                'No data available',
                style: textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildScheduleDetails(BuildContext context, ScheduleModel schedule) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    final bool isActive = schedule.active;

    final Color activeStatusColor =
        isDarkMode ? Colors.green.shade400 : Colors.green.shade700;
    final Color inactiveStatusColor =
        isDarkMode ? Colors.red.shade400 : Colors.red.shade700;
    final Color statusTextColor =
        isActive ? activeStatusColor : inactiveStatusColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          schedule.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch.adaptive(
                        value: isActive,
                        onChanged: (value) {
                          context.read<ScheduleCubit>().toggleScheduleStatus(
                            schedule.id,
                            context,
                          );

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<ScheduleCubit>().getScheduleDetails(
                              widget.scheduleId,
                            );
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor:
                            isDarkMode
                                ? Colors.red.shade600
                                : Colors.red.shade300,
                        inactiveTrackColor:
                            isDarkMode
                                ? Colors.red.shade800
                                : Colors.red.shade100,
                      ),
                    ],
                  ),
                  const Gap(8),
                  Text(
                    isActive ? 'Status: Active' : 'Status: Inactive',
                    style: textTheme.titleMedium?.copyWith(
                      color: statusTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),

          Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule Information',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                  const Gap(18),
                  _buildDetailItem(
                    context,
                    'Planning Period',
                    '${DateFormat('MMM d, y').format(schedule.planningHorizonStart)} - '
                        '${DateFormat('MMM d, y').format(schedule.planningHorizonEnd)}',
                    Icons.calendar_month_rounded,
                  ),
                  const Gap(16),
                  _buildDetailItem(
                    context,
                    'Repeat Pattern',
                    '${schedule.repeat.daysOfWeek.map((day) => day.substring(0, 3)).join(', ')}\n'
                        'Time: ${schedule.repeat.timeOfDay}\n'
                        'Duration: ${schedule.repeat.duration} hours',
                    Icons.repeat_on_rounded,
                  ),
                  if (schedule.comment != null &&
                      schedule.comment!.isNotEmpty) ...[
                    const Gap(16),
                    _buildDetailItem(
                      context,
                      'Comment',
                      schedule.comment!,
                      Icons.comment_outlined,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Gap(35),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create:
                              (context) => ScheduleCubit(
                                remoteDataSource: serviceLocator(),
                              ),
                          child: ScheduleFormPage(initialSchedule: schedule),
                        ),
                  ),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<ScheduleCubit>().getScheduleDetails(
                      widget.scheduleId,
                    );
                  });
                });
              },
              icon: const Icon(
                Icons.edit_note_rounded,
                color:
                    Colors
                        .white,
                size: 16,
              ),
              label: Text(
                'Edit Schedule',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ),

          const Gap(32),
          Divider(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const Gap(24),

          Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VacationListPage(schedule: schedule),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.beach_access_rounded,
                      size: 30,
                      color: primaryColor,
                    ),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        "View Vacations",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color:
                          Theme.of(
                            context,
                          ).iconTheme.color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: primaryColor,
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                ),
              ),
              const Gap(4),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      isDarkMode
                          ? Colors.white
                          : Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
