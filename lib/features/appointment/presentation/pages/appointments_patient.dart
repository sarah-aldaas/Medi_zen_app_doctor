import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../data/models/appointment_filter_model.dart';
import '../../data/models/appointment_model.dart';
import '../cubit/appointment_cubit/appointment_cubit.dart';
import '../widgets/appointment_filter_dialog.dart';
import 'appointment_patient_details.dart';

class AppointmentsPatient extends StatefulWidget {
  final String patientId;

  const AppointmentsPatient({super.key, required this.patientId});

  @override
  State<AppointmentsPatient> createState() => _AppointmentsPatientState();
}

class _AppointmentsPatientState extends State<AppointmentsPatient> {
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
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialAppointments() {
    _isLoadingMore = false;
    context.read<AppointmentCubit>().getPatientAppointments(context: context, patientId: widget.patientId, filters: _filter.toJson());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<AppointmentCubit>().getPatientAppointments(context: context, patientId: widget.patientId, filters: _filter.toJson(), loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AppointmentFilterModel>(context: context, builder: (context) => AppointmentFilterDialog(currentFilter: _filter));

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text("myAppointments.title".tr(context), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
        actions: [IconButton(icon: Icon(Icons.filter_list, color: AppColors.primaryColor), onPressed: _showFilterDialog)],
      ),
      body: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is AppointmentLoading && !state.isLoadMore) {
            return Center(child: LoadingPage());
          }

          final appointments = state is AppointmentListSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is AppointmentListSuccess ? state.hasMore : false;
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text("There are not any appointments.", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: appointments.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < appointments.length) {
                return _buildAppointmentItem(appointments[index]);
              } else if (hasMore && state is! AppointmentError) {
                return Center(child: LoadingButton());
              }
              return SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap:
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentPatientDetails(appointmentId: appointment.id!))).then((value) {
              _loadInitialAppointments();
            }),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                  child: Row(
                    spacing: 5,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset("assets/images/person.jpg", height: 100, width: 100, fit: BoxFit.fill),
                        ),
                      ),
                      Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${appointment.doctor!.prefix!}  ${appointment.doctor!.fName!} ${appointment.doctor!.lName}", style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.date_range_outlined, color: Theme.of(context).primaryColor, size: 20),
                              Text(DateFormat('yyyy-M-d').format(DateTime.parse(appointment.startDate!))),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.timer, color: Theme.of(context).primaryColor, size: 20),
                              Text(DateFormat('hh:mma').format(DateTime.parse(appointment.startDate!))),
                            ],
                          ),
                          Row(
                            spacing: 20,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10.0)),
                                child: Text(appointment.status!.display, style: TextStyle(color: Theme.of(context).primaryColor)),
                              ),
                              if (appointment.status!.code == "canceled_appointment") Icon(Icons.block, color: Colors.red),
                              if (appointment.status!.code == "finished_appointment") Icon(Icons.check, color: Colors.green),
                              if (appointment.status!.code == "booked_appointment") Icon(Icons.timelapse, color: Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
