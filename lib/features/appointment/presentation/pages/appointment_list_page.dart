import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/appointment_filter_model.dart';
import '../../data/models/appointment_model.dart';
import '../cubit/appointment_cubit/appointment_cubit.dart';
import '../widgets/appointment_filter_dialog.dart';

const double _kCardMarginVertical = 8.0;
const double _kCardMarginHorizontal = 16.0;
const double _kCardElevation = 4.0;
const double _kCardBorderRadius = 16.0;
const double _kListTilePaddingVertical = 16.0;
const double _kListTilePaddingHorizontal = 20.0;

class AppointmentListPage extends StatefulWidget {
  final String? patientId;

  const AppointmentListPage({super.key, this.patientId});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final ScrollController _scrollController = ScrollController();
  AppointmentFilterModel _filter = AppointmentFilterModel();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialAppointments();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }


  Future<void> _loadInitialAppointments() async {
    _isLoadingMore = false;
    final cubit = context.read<AppointmentCubit>();
    if (widget.patientId != null) {
      await cubit.getPatientAppointments(
        patientId: widget.patientId!,
        filters: _filter.toJson(),
      );
    } else {
      await cubit.getMyAppointments(filters: _filter.toJson());
    }
  }

  void _loadMoreAppointments() {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    final cubit = context.read<AppointmentCubit>();

    Future<void> loadFuture;
    if (widget.patientId != null) {
      loadFuture = cubit.getPatientAppointments(
        patientId: widget.patientId!,
        filters: _filter.toJson(),
        loadMore: true,
      );
    } else {
      loadFuture = cubit.getMyAppointments(
        filters: _filter.toJson(),
        loadMore: true,
      );
    }
    loadFuture.then((_) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreAppointments();
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AppointmentFilterModel>(
      context: context,
      builder: (context) => AppointmentFilterDialog(currentFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialAppointments();
    }
  }


  Color _getStatusColor(BuildContext context, String? status) {

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (status?.toLowerCase()) {
      case 'confirmed':
        return isDarkMode ? Colors.green.shade400 : Colors.green.shade700;
      case 'pending':
      case 'قيد التنفيذ':
        return isDarkMode ? Colors.orange.shade400 : Colors.orange.shade700;
      case 'cancelled':
      case 'ملغاة':
        return isDarkMode ? Colors.red.shade400 : Colors.red.shade700;
      case 'completed':
      case 'منتهي':
        return isDarkMode ? Colors.blue.shade400 : Colors.blue.shade700;
      default:
        return isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(

        title: Text(
          widget.patientId != null ? 'Patient Appointments' : 'My Appointments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).appBarTheme.foregroundColor ??
                (isDarkMode
                    ? Colors.white
                    : AppColors
                        .secondaryColor),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color:
                  Theme.of(context).iconTheme.color,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Appointments',
          ),
        ],
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AppointmentLoading && !_isLoadingMore) {
            return const Center(child: LoadingPage());
          }

          final appointments =
              state is AppointmentListSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : <AppointmentModel>[];
          final hasMore =
              state is AppointmentListSuccess ? state.hasMore : false;

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color:
                        isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No appointments found matching your criteria.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      color:
                          isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Try adjusting your filters.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color:
                          isDarkMode
                              ? Colors.grey.shade500
                              : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filter = AppointmentFilterModel();
                      });
                      _loadInitialAppointments();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    label: Text(
                      "Clear Filters",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            Theme.of(context)
                                .colorScheme
                                .onSurface,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            Theme.of(context)
                                .colorScheme
                                .outline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadInitialAppointments,
            color:
                Theme.of(
                  context,
                ).primaryColor,
            backgroundColor:
                Theme.of(
                  context,
                ).scaffoldBackgroundColor,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: appointments.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < appointments.length) {
                  return _AppointmentCard(
                    appointment: appointments[index],
                    isPatientView: widget.patientId != null,
                    statusColor: _getStatusColor(
                      context,
                      appointments[index].status?.display,
                    ),
                    onTap: () {
                      context
                          .pushNamed(
                            AppRouter.appointmentDetails.name,
                            pathParameters: {
                              'appointmentId': appointments[index].id!,
                            },
                            extra: {
                              'appointmentId': int.parse(
                                appointments[index].id!,
                              ),
                            },
                          )
                          .then((_) => _loadInitialAppointments());
                    },
                  );
                } else if (hasMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: LoadingPage(),
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

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isPatientView;
  final Color
  statusColor;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.isPatientView,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color titleColor =
        isDarkMode
            ? Colors.white
            : Theme.of(
              context,
            ).primaryColorDark;
    final Color detailTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey[700]!;
    final Color patientNameColor =
        isDarkMode
            ? Colors.white
            : textTheme
                .bodyMedium!
                .color!;
    final Color arrowIconColor =
        isDarkMode ? Colors.blue.shade400 : Colors.blueAccent;

    String formattedDate = 'N/A';
    String formattedTime = '';
    try {
      if (appointment.startDate != null) {
        final dateTime = DateTime.parse(appointment.startDate!);
        formattedDate = DateFormat(
          'EEE, MMM d, y',
        ).format(dateTime);
        formattedTime = DateFormat(
          'hh:mm a',
        ).format(dateTime);
      }
    } catch (e) {
      formattedDate = appointment.startDate ?? 'N/A';
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: _kCardMarginHorizontal,
        vertical: _kCardMarginVertical,
      ),
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _kListTilePaddingHorizontal,
            vertical: _kListTilePaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      appointment.reason ?? 'No reason specified',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        fontSize: 22,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      appointment.status?.display ?? 'Unknown',
                      style: textTheme.labelSmall?.copyWith(
                        color:
                            Colors
                                .white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    backgroundColor:
                        statusColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: textTheme.bodyMedium?.copyWith(
                      color: detailTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color:
                        Theme.of(context)
                            .iconTheme
                            .color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: textTheme.bodyMedium?.copyWith(
                      color: detailTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (!isPatientView) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color:
                          Theme.of(context)
                              .iconTheme
                              .color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Patient: ${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: patientNameColor,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: arrowIconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
