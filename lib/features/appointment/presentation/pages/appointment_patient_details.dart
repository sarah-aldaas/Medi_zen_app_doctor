import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/notifications/presentation/cubit/notification_cubit/notification_cubit.dart';

import '../../../../base/constant/app_images.dart';
import '../../../../base/widgets/flexible_image.dart';
import '../../../../base/widgets/loading_page.dart';
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
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ShowToast.showToastError(message: state.error);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(10),
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
          if (appointment.status?.code == 'booked_appointment')
            _buildActionButtons(context, appointment),
          const Gap(20),
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

  Widget _buildDoctorInfo(AppointmentModel appointment) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 40,
          child: ClipOval(
            child: FlexibleImage(assetPath: AppAssetImages.photoDoctor1,imageUrl: appointment.doctor!.avatar,),
          ),
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


  Widget _buildActionButtons(
      BuildContext context,
      AppointmentModel appointment,
      ) {

 
    return Center(
      child: ListTile(

        onTap: () {
          context.read<NotificationCubit>().sendNotification(appointmentId: appointment.id!, context: context);
        },
        title: BlocBuilder<NotificationCubit, NotificationState>(

        builder: (context, state) {
      if(state is NotificationError)
        {
          return Text(state.error);
        }

      if(state is NotificationOperationLoading)
        {
          return Center(child: LoadingButton(),);
        }
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text("Reminder notification",style: TextStyle(color:AppColors.primaryColor),),
            Icon(Icons.notifications,color: Colors.yellow,)
          ],
        );
        },
      ),
      ),
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
          "${"appointmentDetails.labels.age".tr(context)}: ${appointment.patient!.dateOfBirth!=null?_calculateAge(appointment.patient!.dateOfBirth!):"not found"}",
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
