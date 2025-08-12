import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../medical_record/medical_record_for_appointment.dart';
import '../../data/models/appointment_filter_model.dart';
import '../../data/models/appointment_model.dart';
import '../cubit/appointment_cubit/appointment_cubit.dart';
import '../widgets/appointment_filter_dialog.dart';

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
  bool _isRTL(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialAppointments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAppointments() {
    _isLoadingMore = false;
    final cubit = context.read<AppointmentCubit>();
    if (widget.patientId != null) {
      cubit.getPatientAppointments(
        patientId: widget.patientId!,
        filters: _filter.toJson(),
      );
    } else {
      cubit.getMyAppointments(filters: _filter.toJson());
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future =
          widget.patientId != null
              ? context.read<AppointmentCubit>().getPatientAppointments(
                patientId: widget.patientId!,
                filters: _filter.toJson(),
                loadMore: true,
              )
              : context.read<AppointmentCubit>().getMyAppointments(
                filters: _filter.toJson(),
                loadMore: true,
              );

      future.then((_) => setState(() => _isLoadingMore = false));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final onSurfaceColor = theme.colorScheme.onSurface;
    final primaryColor = theme.primaryColor;
    final appBarBackgroundColor = theme.appBarTheme.backgroundColor;
    final bodyMediumColor = theme.textTheme.bodyMedium?.color;
    final headlineSmallColor = theme.textTheme.headlineSmall?.color;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.patientId != null
              ? 'appointmentPage.patient_appointments_title'.tr(context)
              : 'appointmentPage.my_appointments_title'.tr(context),
          style: theme.textTheme.titleLarge?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        iconTheme: theme.appBarTheme.iconTheme,
        flexibleSpace: Container(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppColors.primaryColor,
              size: 28,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'appointmentPage.filter_appointments_tooltip'.tr(context),
          ),
          const SizedBox(width: 8),
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
                        headlineSmallColor?.withOpacity(0.3) ??
                        Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "appointmentPage.no_appointments_found_title".tr(context),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color:
                          headlineSmallColor?.withOpacity(0.8) ??
                          Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "appointmentPage.no_appointments_found_tip".tr(context),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          bodyMediumColor?.withOpacity(0.6) ?? Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: appointments.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < appointments.length) {
                return _buildAppointmentItem(
                  appointments[index],
                  theme,
                  primaryColor,
                  onSurfaceColor,
                );
              } else if (hasMore && state is! AppointmentError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: LoadingButton()),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentItem(
    AppointmentModel appointment,
    ThemeData theme,
    Color itemPrimaryColor,
    Color onSurfaceColor,
  ) {
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey[700];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MedicalRecordForAppointment(
                    patientId: appointment.patient!.id!,
                    appointmentId: appointment.id!,
                  ),
              // AppointmentDetailsPage(appointmentId: appointment.id!),
            ),
          ).then((_) => _loadInitialAppointments());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.reason ??
                    'appointmentPage.no_reason_specified'.tr(context),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onSurfaceColor,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (appointment.status!.code == "canceled_appointment")
                    const Icon(Icons.block, color: Colors.red),
                  if (appointment.status!.code == "finished_appointment")
                    const Icon(Icons.check, color: Colors.green),
                  if (appointment.status!.code == "booked_appointment")
                    const Icon(Icons.timelapse, color: Colors.orange),

                  const SizedBox(width: 8),
                  Text(
                    '${'appointmentPage.status_label'.tr(context)}: ${appointment.status?.display ?? 'appointmentPage.not_specified'.tr(context)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: itemPrimaryColor.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${'appointmentPage.start_date_label'.tr(context)}: ${appointment.startDate ?? 'appointmentPage.not_available'.tr(context)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.patientId == null && appointment.patient != null)
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: itemPrimaryColor.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${'appointmentPage.patient_label'.tr(context)}: ${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Align(
                alignment:
                    _isRTL(context)
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                child: Icon(
                  _isRTL(context)
                      ? Icons.arrow_forward_ios
                      : Icons.arrow_back_ios,
                  size: 20,
                  color: itemPrimaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
