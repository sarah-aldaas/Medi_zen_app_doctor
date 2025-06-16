import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
    final textColor = Colors.grey.shade800;
    final subTextColor = Colors.grey.shade600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          'Appointment Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
          tooltip: 'Back',
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
                  tooltip: 'Finished Appointment',
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
              message: 'Appointment status updated successfully.',
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
                      'An error occurred while loading the details ${state.error}',
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
                        'Retry',
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
          Text(appointment.reason ?? 'No reason specified', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,)),
          const Gap(10),
          Text('Status: ${appointment.status?.display ?? 'N/A'}', style: TextStyle(fontSize: 18,)),
          Text('Type: ${appointment.type?.display ?? 'N/A'}', style: TextStyle(fontSize: 18, )),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text('Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
          const Gap(10),
          Row(
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 26),
              const Gap(10),
              Text('Start: ${appointment.startDate ?? 'N/A'}', style: TextStyle(fontSize: 18,)),
            ],
          ),
          const Gap(15),
          Row(
            children: [
// <<<<<<< HEAD
//               Icon(Icons.calendar_today, color: primaryColor, size: 26),
//               const Gap(10),
//               Text('End: ${appointment.endDate ?? 'N/A'}', style: TextStyle(fontSize: 18,)),
//             ],
//           ),
//           const Gap(10),
//           Row(
//             children: [
//               Icon(Icons.timer, color: primaryColor, size: 26),
//               const Gap(10),
//               Text('Duration: ${appointment.minutesDuration ?? 'N/A'} minutes', style: TextStyle(fontSize: 18,)),
//             ],
//           ),
//           const Gap(30),
//           Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//           const Gap(20),
//           Text('Participants', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
//           const Gap(10),
//           ListTile(
//             leading: AvatarImage(imageUrl: appointment.patient!.avatar, radius: 25),
//             title:Text('${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}', style: TextStyle(fontSize: 18,)),
//            subtitle: Text('Doctor: ${appointment.doctor?.fName ?? ''} ${appointment.doctor?.lName ?? ''}'),
//             onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsPage(patientId: appointment.patient!.id!)));
//             },
              _buildStatusChip(
                appointment.status?.display ?? 'Unknown',
                primaryColor,
              ),
              const Gap(10),
              Text(
                'Type: ${appointment.type?.display ?? 'Not available'}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: subTextColor),
              ),
            ],
          ),
          const Gap(30),

          _buildSectionHeader('Details', context, textColor),
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
              children: [
                _buildDetailRow(
                  Icons.event,
                  'Start Date',
                  appointment.startDate ?? 'Not available',
                ),
                _buildDetailRow(
                  Icons.event_note,
                  'End Date',
                  appointment.endDate ?? 'Not available',
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Duration',
                  '${appointment.minutesDuration ?? 'Not available'} Minute',
                ),
              ],
            ),
          ),

          const Gap(30),
// <<<<<<< HEAD
//           Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//           const Gap(20),
//           Text('Notes', style: TextStyle(fontSize: 22,)),
//           const Gap(10),
//           Text(appointment.note ?? 'No notes provided', style: TextStyle(fontSize: 18,)),
//           if (appointment.cancellationDate != null) ...[
//             const Gap(30),
//             Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//             const Gap(20),
//             Text('Cancellation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
//             const Gap(10),
//             Text('Date: ${appointment.cancellationDate}', style: TextStyle(fontSize: 18,)),
//             Text('Reason: ${appointment.cancellationReason ?? 'N/A'}', style: TextStyle(fontSize: 18,)),
//           ],
//           if (appointment.createdByPractitioner != null) ...[
//             const Gap(30),
//             Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
//             const Gap(20),
//             Text('Created By', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
//             const Gap(10),
//             Text(
//               '${appointment.createdByPractitioner?.fName ?? ''} ${appointment.createdByPractitioner?.lName ?? ''}',
//               style: TextStyle(fontSize: 18,),
// =======

          _buildSectionHeader('Participants', context, textColor),
          const Gap(15),
          Container(
            padding: const EdgeInsets.all(15),
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
              children: [
                // Patient Info
                ListTile(
                  leading: AvatarImage(
                    imageUrl: appointment.patient!.avatar,
                    radius: 28,
                  ),
                  title: Text(
                    appointment.patient != null
                        ? '${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}'
                        : 'The patient is not available.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Patient',
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
                        message: 'Patient identifier is unavailable .',
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
                        : 'The doctor is not available.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Doctor',
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

          _buildSectionHeader('Notes', context, textColor),
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
            child: Text(
              appointment.note ??
                  'No notes have been provided for this appointment.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: textColor),
            ),
          ),
          if (appointment.cancellationDate != null) ...[
            const Gap(30),
            _buildSectionHeader('Cancel', context, textColor),
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
                    'Cancellation date',
                    appointment.cancellationDate!,
                  ),
                  _buildDetailRow(
                    Icons.info_outline,
                    'Reason for cancellation',
                    appointment.cancellationReason ?? 'Not available',
                  ),
                ],
              ),
            ),
          ],
          if (appointment.createdByPractitioner != null) ...[
            const Gap(30),

            _buildSectionHeader('Created by', context, textColor),
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
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
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
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case 'confirmed':
        chipColor = primaryColor.withOpacity(0.1);
        textColor = primaryColor;
        break;
      case 'finished':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case 'cancelled':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      default:
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }
    return Chip(
      label: Text(
        status,
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
// <<<<<<< HEAD
//             title: const Text('Finish appointment'),
//             content: const Text('Are you sure you want to mark this appointment as finished? This action cannot be undone.'),
//             actions: [
//               TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//               ElevatedButton(
//                 onPressed: () => {context.read<AppointmentCubit>().finishAppointment(appointmentId: int.parse(appointment.id!)), Navigator.pop(context)},
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 child: const Text('Finish'),
// =======
            title: const Text(
              'Complete Appointment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to mark this appointment as completed? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: primaryColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<AppointmentCubit>().finishAppointment(
                    context: context,
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
                child: const Text('Complete'),
// >>>>>>> 8204fd864dcb0701c801cc21f07ddc5349757ff9
              ),
            ],
          ),
    );
  }
}
