import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../base/theme/app_color.dart';
import 'cubit/previous_appointment_cubit.dart';
import 'cubit/previous_appointment_state.dart';

class MyPreviousAppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PreviousAppointmentCubit(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Previous Bookings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontSize: 20,
            ),
          ),
          toolbarHeight: 80,
        ),
        body: BlocBuilder<PreviousAppointmentCubit, PreviousAppointmentState>(
          builder: (context, state) {
            String selectedTab =
                (state is AppointmentTabChanged)
                    ? state.tabName
                    : 'previous reservations';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildTabItem(
                          context,
                          'previous reservations',
                          selectedTab,
                        ),
                        _buildSpacer(),
                        _buildTabItem(
                          context,
                          'inactive appointments',
                          selectedTab,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _buildAppointmentList(context, selectedTab),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    String tabName,
    String selectedTab,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<PreviousAppointmentCubit>().changeTab(tabName);
      },
      child: Column(
        children: [
          Text(
            tabName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color:
                  selectedTab == tabName
                      ? AppColors.primaryColor
                      : Colors.grey[600],
            ),
          ),
          if (selectedTab == tabName)
            Container(
              height: 2,
              width: 50,
              color: AppColors.primaryColor,
              margin: EdgeInsets.only(top: 4),
            ),
        ],
      ),
    );
  }

  Widget _buildSpacer() {
    return SizedBox(width: 50);
  }

  Widget _buildAppointmentList(BuildContext context, String selectedTab) {
    List<Appointment> appointments = [];
    if (selectedTab == 'inactive appointments') {
      appointments =
          context.read<PreviousAppointmentCubit>().getInactiveAppointments();
    } else {
      appointments =
          context.read<PreviousAppointmentCubit>().getPreviousAppointments();
    }

    return ListView(
      key: ValueKey(selectedTab),
      children:
          appointments.map((appointment) {
            return _buildAppointmentTile(appointment);
          }).toList(),
    );
  }

  Widget _buildAppointmentTile(Appointment appointment) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, size: 40, color: Colors.blue[900]),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Date: ${appointment.appointmentDate}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    Text(
                      'Time: ${appointment.appointmentTime}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    Text(
                      'Status: ${appointment.status}',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            appointment.status == 'Cancelled'
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                    if (appointment.status == 'Cancelled')
                      Text(
                        'Reason: ${appointment.cancellationReason}',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
