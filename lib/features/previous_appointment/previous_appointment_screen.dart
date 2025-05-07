import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../base/theme/app_color.dart';
import 'cubit/previous_appointment_cubit.dart';
import 'cubit/previous_appointment_state.dart';
import 'model/previous_appointment_model.dart';

class MyPreviousAppointmentPage extends StatefulWidget {
  const MyPreviousAppointmentPage({super.key});

  @override
  _MyPreviousAppointmentPageState createState() =>
      _MyPreviousAppointmentPageState();
}

class _MyPreviousAppointmentPageState extends State<MyPreviousAppointmentPage> {
  bool isUpcomingActive = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => PreviousAppointmentCubit()..loadUpcomingAppointments(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "previousappointments.title".tr(context),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                // Handle search
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                // Handle more options
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton(context, "Upcoming", true),
                _buildTabButton(context, "Completed", false),
              ],
            ),
          ),
        ),
        body: BlocBuilder<PreviousAppointmentCubit, PreviousAppointmentState>(
          builder: (context, state) {
            if (state is PreviousAppointmentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PreviousAppointmentLoaded) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildAppointmentList(state.previous_appointments),
              );
            }
            return const Center(child: Text('Error loading appointments'));
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String label, bool isUpcoming) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isUpcomingActive = isUpcoming;
        });
        final cubit = BlocProvider.of<PreviousAppointmentCubit>(context);
        if (isUpcoming) {
          cubit.loadUpcomingAppointments();
        } else {
          cubit.loadCompletedAppointments();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  isUpcomingActive == isUpcoming
                      ? AppColors.primaryColor
                      : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildAppointmentList(List<PreviousAppointment> appointments) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          appointments.isNotEmpty
              ? ListView.builder(
                key: ValueKey<int>(appointments.length), // لتفعيل Animation
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentItem(appointments[index]);
                },
              )
              : const Center(child: Text('No appointments available')),
    );
  }

  Widget _buildAppointmentItem(PreviousAppointment appointment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  appointment.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const Gap(15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientFullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      appointment.appointmentType,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Gap(5),
                    Text(
                      '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year} | ${appointment.appointmentTime}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Gap(5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            appointment.status == "مكتملة"
                                ? Colors.green
                                : AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        appointment.status!,
                        style: TextStyle(
                          color:
                              appointment.status == "مكتملة"
                                  ? Colors.white
                                  : AppColors.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
