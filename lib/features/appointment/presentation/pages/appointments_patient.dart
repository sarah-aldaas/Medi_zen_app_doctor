import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/flexible_image.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../base/theme/app_color.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../../medical_record/medical_record_for_appointment.dart';
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
  AppointmentFilterModel? _filter = AppointmentFilterModel();
  bool _isLoadingMore = false;
  int? _selectedStatus;

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
    context.read<AppointmentCubit>().getPatientAppointments(
      patientId: widget.patientId,
      filters: _filter?.toJson(),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<AppointmentCubit>()
          .getPatientAppointments(
        patientId: widget.patientId,
        filters: _filter?.toJson(),
        loadMore: true,
      )
          .then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<AppointmentFilterModel>(
      context: context,
      builder: (context) => AppointmentFilterDialog(currentFilter: _filter??AppointmentFilterModel()),
    );

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialAppointments();
    }
  }

  void _filterByStatus(int? status) {
    setState(() {
      _selectedStatus = status;
      if(_selectedStatus!=null) {
        _filter = _filter!.copyWith(statusId: status);
      }else{
        _filter=AppointmentFilterModel();
      }
      _loadInitialAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'appointmentPage.my_appointments_title'.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
            tooltip: 'appointmentPage.filter_appointments_tooltip'.tr(context),
          ),
        ],
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusFilterButton(
                  context,
                  label: 'Finished',
                  status: 83,
                  icon: Icons.check,
                  color: Colors.green,
                ),
                _buildStatusFilterButton(
                  context,
                  label: 'Canceled',
                  status: 82,
                  icon: Icons.block,
                  color: Colors.red,
                ),
                _buildStatusFilterButton(
                  context,
                  label: 'Booked',
                  status: 81,
                  icon: Icons.timelapse,
                  color: Colors.orange,
                ),
                _buildStatusFilterButton(
                  context,
                  label: 'All',
                  status: null,
                  icon: Icons.all_inclusive,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          // Appointment List
          Expanded(
            child: BlocConsumer<AppointmentCubit, AppointmentState>(
              listener: (context, state) {
                if (state is AppointmentError) {
              ShowToast.showToastError(message: state.error);
                }
              },
              builder: (context, state) {
                if (state is AppointmentLoading && !state.isLoadMore) {
                  return const Center(child: LoadingPage());
                }

                final appointments =
                state is AppointmentListSuccess
                    ? state.paginatedResponse.paginatedData!.items
                    : [];
                final hasMore =
                state is AppointmentListSuccess ? state.hasMore : false;
                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 64, color: Theme.of(context).primaryColor),
                        const Gap(16),
                        Text(
                          'appointmentPage.no_appointments_found_title'.tr(context),
                          style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                        ),
                        Text(
                          'appointmentPage.no_appointments_found_tip'.tr(context),
                          style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
                        ),
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
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusFilterButton(
      BuildContext context, {
        required String label,
        required int? status,
        required IconData icon,
        required Color color,
      }) {
    final isSelected = _selectedStatus == status;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      onPressed: () => _filterByStatus(status),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalRecordForAppointment(
              patientId: appointment.patient!.id!,
              appointmentId: appointment.id!,
            ),
          ),
        ).then((value) {
          _loadInitialAppointments();
        }),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 20,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: FlexibleImage(
                              imageUrl: appointment.doctor!.avatar,
                              assetPath: "assets/images/person.jpg",
                            ),
                          ),
                        ),
                        const Gap(5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${appointment.doctor!.prefix!}  ${appointment.doctor!.fName!} ${appointment.doctor!.lName}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Gap(10),
                            Row(
                              children: [
                                Icon(
                                  Icons.date_range_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const Gap(10),
                                Text(
                                  DateFormat('yyyy-M-d').format(
                                    DateTime.parse(appointment.startDate!),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const Gap(10),
                                Text(
                                  DateFormat('hh:mma').format(
                                    DateTime.parse(appointment.startDate!),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    appointment.status!.display,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                const Gap(20),
                                if (appointment.status!.code == "canceled_appointment")
                                  const Icon(Icons.block, color: Colors.red),
                                if (appointment.status!.code == "finished_appointment")
                                  const Icon(Icons.check, color: Colors.green),
                                if (appointment.status!.code == "booked_appointment")
                                  const Icon(Icons.timelapse, color: Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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