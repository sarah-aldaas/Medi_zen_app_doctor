import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';

import '../../../../base/constant/app_images.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../../medical_record/medical_record_for_appointment.dart';
import '../../data/models/appointment_model.dart';
import '../cubit/appointment_cubit/appointment_cubit.dart';

class AppointmentPatientDetails extends StatefulWidget {
  final String appointmentId;

  const AppointmentPatientDetails({super.key, required this.appointmentId});

  @override
  State<AppointmentPatientDetails> createState() =>
      _AppointmentPatientDetailsState();
}

class _AppointmentPatientDetailsState extends State<AppointmentPatientDetails> {
  @override
  void initState() {
    super.initState();

    context.read<AppointmentCubit>().getAppointmentDetails(
      appointmentId: widget.appointmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "appointmentDetails.title".tr(context),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is AppointmentDetailsSuccess) {
            return _buildAppointmentDetails(state.appointment);
          } else if (state is AppointmentLoading) {
            return const Center(child: LoadingPage());
          } else {
            return Center(
              child: Text('appointmentDetails.labels.failedLoad'.tr(context)),
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentDetails(AppointmentModel appointment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorInfo(appointment),
          const Gap(25),
          _buildAppointmentInfo(appointment),
          const Gap(30),
          _buildPatientInfo(appointment),
          const Gap(30),
          _buildAppointmentInformation(appointment),
          const Gap(30),
          _buildPackageInfo(appointment),
          const Gap(20),
          const Divider(),
          const Gap(20),
          _buildNavigationItem(
            'appointmentDetails.labels.medicalRecord'.tr(context),
            Icons.health_and_safety,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MedicalRecordForAppointment(
                        patientModel: appointment.patient!,
                        appointmentId: appointment.id!,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.scheduledAppointment".tr(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Gap(8),
        Text(
          DateFormat(
            'EEEE, MMMM d, y',
          ).format(DateTime.parse(appointment.startDate!)),
        ),
        const Gap(5),
        Text(
          '${DateFormat('HH:mm').format(DateTime.parse(appointment.startDate!))} - '
          '${DateFormat('HH:mm').format(DateTime.parse(appointment.endDate!))} '
          '(${appointment.minutesDuration} ${'appointmentPage.minute_label'.tr(context)})',
        ),
      ],
    );
  }

  Widget _buildNavigationItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(AppointmentModel appointment) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 40,
          backgroundImage: AssetImage(AppAssetImages.photoDoctor1 ?? ''),
        ),
        const Gap(16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appointment.doctor!.prefix} ${appointment.doctor!.fName} ${appointment.doctor!.lName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: context.width / 1.5,
              child: Text(
                appointment.doctor!.text ??
                    'appointmentDetails.general_practitioner'.tr(context),
              ),
            ),
            Text(appointment.doctor!.address!),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.patientInformation".tr(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Gap(8),
        Text(
          "${"appointmentDetails.labels.fullName".tr(context)}: ${appointment.patient!.fName} ${appointment.patient!.lName}",
          style: const TextStyle(fontSize: 16),
        ),
        const Gap(5),
        Text(
          "${"appointmentDetails.labels.age".tr(context)}: ${_calculateAge(appointment.patient!.dateOfBirth!)}",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAppointmentInformation(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.labels.appointment_information".tr(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Gap(8),
        Text(
          "${"appointmentDetails.labels.reason".tr(context)}: ${appointment.reason ?? 'appointmentPage.no_reason_specified'.tr(context)}",
          style: const TextStyle(fontSize: 16),
        ),
        const Gap(5),
        Text(
          "${"appointmentDetails.labels.description".tr(context)}: ${appointment.description ?? 'appointmentPage.not_specified'.tr(context)}",
          style: const TextStyle(fontSize: 16),
        ),
        const Gap(5),
        Text(
          "${"appointmentDetails.labels.notes".tr(context)}: ${appointment.note ?? "appointmentPage.no_notes_provided_for_appointment".tr(context)}",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPackageInfo(AppointmentModel appointment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "appointmentDetails.type".tr(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Gap(8),
        ListTile(
          leading: const Icon(Icons.density_medium_rounded),
          title: Text(appointment.type!.display),
          subtitle: Text(appointment.description!),
        ),
      ],
    );
  }

  int _calculateAge(String birthDate) {
    final birthday = DateTime.parse(birthDate);
    final today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }
}
