import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/appointment/data/models/appointment_model.dart';
import 'package:medi_zen_app_doctor/features/profile/presentaiton/widgets/avatar_image_widget.dart';

import '../../../patients/presentation/pages/patient_details_page.dart';
import '../cubit/appointment_cubit/appointment_cubit.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsPage({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  @override
  void initState() {
    super.initState();

    context.read<AppointmentCubit>().getAppointmentDetails(
      appointmentId: widget.appointmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade800;

    final subTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'appointmentPage.appointment_details_title'.tr(context),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
          tooltip: 'appointmentPage.back_tooltip'.tr(context),
        ),
        actions: [
          BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentDetailsSuccess &&
                  state.appointment.status?.display.toLowerCase() !=
                      'finished') {
                return IconButton(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                  onPressed:
                      () => _showFinishConfirmationDialog(
                        context,
                        state.appointment,
                        AppColors.primaryColor,
                      ),
                  tooltip: 'appointmentPage.finished_appointment_tooltip'.tr(
                    context,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Gap(10),
        ],
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is AppointmentActionSuccess) {
            ShowToast.showToastSuccess(
              message: 'appointmentPage.status_updated_success'.tr(
                context,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is AppointmentDetailsSuccess) {
            return _buildAppointmentDetails(
              context,
              state.appointment,
              AppColors.primaryColor,
              textColor,
              subTextColor,
            );
          } else if (state is AppointmentError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied_outlined,
                      size: 80,
                      color: Colors.redAccent.withOpacity(0.7),
                    ),
                    const Gap(24),
                    Text(
                      '${'appointmentPage.error_loading_details'.tr(context)} :${state.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: textColor),
                    ),
                    const Gap(30),
                    ElevatedButton.icon(
                      onPressed:
                          () => context
                              .read<AppointmentCubit>()
                              .getAppointmentDetails(
                                appointmentId: widget.appointmentId,
                              ),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        'appointmentPage.retry_button'.tr(context),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildAppointmentDetails(
    BuildContext context,
    AppointmentModel appointment,
    Color primaryColor,
    Color textColor,
    Color subTextColor,
  ) {
    Widget _buildDetailRow(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 24),
            const Gap(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: subTextColor),
                  ),
                  const Gap(4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment.reason ??
                'appointmentPage.no_reason_specified'.tr(context),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          Text(
            '${'appointmentPage.status_label'.tr(context)}: ${appointment.status?.display ?? 'N/A'.tr(context)}',
            style: TextStyle(fontSize: 18),
          ),
          Text(
            '${'appointmentPage.type_label'.tr(context)} :${appointment.type?.display ?? 'N/A'.tr(context)}',
            style: TextStyle(fontSize: 18),
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          _buildSectionHeader(
            'appointmentPage.details_section_title'.tr(context),
            context,
            textColor,
          ),
          const Gap(10),
          Row(
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 26),
              const Gap(10),
              Text(
                '${'appointmentPage.start_date_label'.tr(context)}:${appointment.startDate ?? 'N/A'.tr(context)}',

                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const Gap(15),
          Row(
            children: [
              _buildStatusChip(
                appointment.status?.display ??
                    'appointmentPage.unknown_status'.tr(context),
                primaryColor,
              ),
              const Gap(10),
              Text(
                '${'appointmentPage.type_label'.tr(context)}:${appointment.type?.display ?? 'appointmentPage.not_available_type'.tr(context)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: subTextColor),
              ),
            ],
          ),
          const Gap(30),
          _buildSectionHeader(
            'appointmentPage.details_section_title'.tr(context),
            context,
            textColor,
          ),
          const Gap(15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.event,
                  'appointmentPage.start_date_full_label'.tr(context),
                  appointment.startDate ??
                      'appointmentPage.not_available'.tr(context),
                ),
                _buildDetailRow(
                  Icons.event_note,
                  'appointmentPage.end_date_label'.tr(context),
                  appointment.endDate ??
                      'appointmentPage.not_available'.tr(context),
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'appointmentPage.duration_label'.tr(context),
                  '${'appointmentPage.minutes_duration'.tr(context)}:${appointment.minutesDuration ?? 'appointmentPage.not_available'.tr(context)}',
                ),
              ],
            ),
          ),
          const Gap(30),
          _buildSectionHeader(
            'appointmentPage.participants_section_title'.tr(context),
            context,
            textColor,
          ),
          const Gap(15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: AvatarImage(
                    imageUrl: appointment.patient!.avatar,
                    radius: 28,
                  ),
                  title: Text(
                    appointment.patient != null
                        ? '${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}'
                        : 'appointmentPage.patient_not_available'.tr(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'appointmentPage.patient_role'.tr(context),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: subTextColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: subTextColor.withOpacity(0.6),
                  ),
                  onTap: () {
                    if (appointment.patient?.id != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => PatientDetailsPage(
                                patientId: appointment.patient!.id!,
                              ),
                        ),
                      );
                    } else {
                      ShowToast.showToastError(
                        message:
                            'appointmentPage.patient_identifier_unavailable'.tr(
                              context,
                            ), // Localized
                      );
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 20, thickness: 0.5, indent: 70),
                ListTile(
                  leading: AvatarImage(
                    imageUrl: appointment.doctor!.avatar,
                    radius: 28,
                  ),
                  title: Text(
                    appointment.doctor != null
                        ? '${appointment.doctor?.fName ?? ''} ${appointment.doctor?.lName ?? ''}'
                        : 'appointmentPage.doctor_not_available'.tr(
                          context,
                        ), // Localized
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'appointmentPage.doctor_role'.tr(context),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: subTextColor),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Gap(30),
          _buildSectionHeader(
            'appointmentPage.notes_section_title'.tr(context),
            context,
            textColor,
          ),
          const Gap(15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              appointment.note ??
                  'appointmentPage.no_notes_provided'.tr(context),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: textColor),
            ),
          ),
          if (appointment.cancellationDate != null) ...[
            const Gap(30),
            _buildSectionHeader(
              'appointmentPage.cancel_section_title'.tr(context),
              context,
              textColor,
            ),
            const Gap(15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.cancel_outlined,
                    'appointmentPage.cancellation_date_label'.tr(
                      context,
                    ),
                    appointment.cancellationDate!,
                  ),
                  _buildDetailRow(
                    Icons.info_outline,
                    'appointmentPage.reason_for_cancellation_label'.tr(
                      context,
                    ),
                    appointment.cancellationReason ??
                        'appointmentPage.not_available'.tr(
                          context,
                        ),
                  ),
                ],
              ),
            ),
          ],
          if (appointment.createdByPractitioner != null) ...[
            const Gap(30),
            _buildSectionHeader(
              'appointmentPage.created_by_section_title'.tr(context),
              context,
              textColor,
            ),
            const Gap(15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarImage(
                        imageUrl: appointment.createdByPractitioner!.avatar,
                        radius: 28,
                      ),
                      const Gap(15),
                      Expanded(
                        child: Text(
                          '${appointment.createdByPractitioner?.fName ?? ''} ${appointment.createdByPractitioner?.lName ?? ''}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const Gap(40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    BuildContext context,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor.withOpacity(0.9),
          ),
        ),
        const Gap(10),
        Divider(thickness: 1, color: AppColors.primaryColor.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildStatusChip(String status, Color primaryColor) {
    Color chipColor;
    Color textColor;

    String localizedStatus;
    switch (status.toLowerCase()) {
      case 'pending':
        localizedStatus = 'appointmentPage.status_pending'.tr(context);
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case 'confirmed':
        localizedStatus = 'appointmentPage.status_confirmed'.tr(context);
        chipColor = primaryColor.withOpacity(0.1);
        textColor = primaryColor;
        break;
      case 'finished':
        localizedStatus = 'appointmentPage.status_finished'.tr(context);
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case 'cancelled':
        localizedStatus = 'appointmentPage.status_cancelled'.tr(context);
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      default:
        localizedStatus = 'appointmentPage.unknown_status'.tr(context);
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Chip(
      label: Text(
        localizedStatus,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  void _showFinishConfirmationDialog(
    BuildContext context,
    AppointmentModel appointment,
    Color primaryColor,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'appointmentPage.complete_appointment_dialog_title'.tr(
                context,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'appointmentPage.complete_appointment_dialog_content'.tr(
                context,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'appointmentPage.cancel_button'.tr(context),
                  style: TextStyle(color: primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AppointmentCubit>().finishAppointment(
                    appointmentId: int.parse(appointment.id!),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'appointmentPage.complete_button'.tr(context),
                ),
              ),
            ],
          ),
    );
  }
}
