import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
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
    context.read<AppointmentCubit>().getAppointmentDetails(appointmentId: widget.appointmentId);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('appointment Details', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,), onPressed: () => context.pop()),
        actions: [
          BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentDetailsSuccess && state.appointment.status?.display.toLowerCase() != 'finished') {
                return IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _showFinishConfirmationDialog(context, state.appointment),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is AppointmentActionSuccess) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is AppointmentDetailsSuccess) {
            return _buildAppointmentDetails(state.appointment, primaryColor);
          } else if (state is AppointmentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 70, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(state.error, textAlign: TextAlign.center, style: TextStyle(fontSize: 18,)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<AppointmentCubit>().getAppointmentDetails(appointmentId: widget.appointmentId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    child: const Text('Retry Loading'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: LoadingPage());
        },
      ),
    );
  }

  Widget _buildAppointmentDetails(AppointmentModel appointment, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
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
          const Gap(10),
          Row(
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 26),
              const Gap(10),
              Text('End: ${appointment.endDate ?? 'N/A'}', style: TextStyle(fontSize: 18,)),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              Icon(Icons.timer, color: primaryColor, size: 26),
              const Gap(10),
              Text('Duration: ${appointment.minutesDuration ?? 'N/A'} minutes', style: TextStyle(fontSize: 18,)),
            ],
          ),
          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text('Participants', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
          const Gap(10),
          ListTile(
            leading: AvatarImage(imageUrl: appointment.patient!.avatar, radius: 25),
            title:Text('${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}', style: TextStyle(fontSize: 18,)),
           subtitle: Text('Doctor: ${appointment.doctor?.fName ?? ''} ${appointment.doctor?.lName ?? ''}'),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PatientDetailsPage(patientId: appointment.patient!.id!)));
            },
          ),

          const Gap(30),
          Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
          const Gap(20),
          Text('Notes', style: TextStyle(fontSize: 22,)),
          const Gap(10),
          Text(appointment.note ?? 'No notes provided', style: TextStyle(fontSize: 18,)),
          if (appointment.cancellationDate != null) ...[
            const Gap(30),
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text('Cancellation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
            const Gap(10),
            Text('Date: ${appointment.cancellationDate}', style: TextStyle(fontSize: 18,)),
            Text('Reason: ${appointment.cancellationReason ?? 'N/A'}', style: TextStyle(fontSize: 18,)),
          ],
          if (appointment.createdByPractitioner != null) ...[
            const Gap(30),
            Divider(thickness: 2, color: primaryColor.withOpacity(0.3)),
            const Gap(20),
            Text('Created By', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,)),
            const Gap(10),
            Text(
              '${appointment.createdByPractitioner?.fName ?? ''} ${appointment.createdByPractitioner?.lName ?? ''}',
              style: TextStyle(fontSize: 18,),
            ),
          ],
        ],
      ),
    );
  }

  void _showFinishConfirmationDialog(BuildContext context, AppointmentModel appointment) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Finish appointment'),
            content: const Text('Are you sure you want to mark this appointment as finished? This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => {context.read<AppointmentCubit>().finishAppointment(appointmentId: int.parse(appointment.id!)), Navigator.pop(context)},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Finish'),
              ),
            ],
          ),
    );
  }
}
