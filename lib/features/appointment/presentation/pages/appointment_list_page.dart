import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/pages/appointment_details_page.dart';

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
    if (widget.patientId != null) {
      context.read<AppointmentCubit>().getPatientAppointments(
        patientId: widget.patientId!,
        filters: _filter.toJson(),
      );
    } else {
      context.read<AppointmentCubit>().getMyAppointments(
        filters: _filter.toJson(),
      );
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future = widget.patientId != null
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.patientId != null ? 'Patient Appointments' : 'My Appointments',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: _showFilterDialog,
          ),
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

          final appointments = state is AppointmentListSuccess
              ? state.paginatedResponse.paginatedData!.items
              : <AppointmentModel>[];
          final hasMore = state is AppointmentListSuccess ? state.hasMore : false;

          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No appointments found.",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                return  Center(child: LoadingButton());
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          appointment.reason ?? 'No reason specified',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: ${appointment.status?.display ?? 'Unknown'}'),
            Text('Start: ${appointment.startDate ?? 'N/A'}'),
            if (widget.patientId == null)
              Text('Patient: ${appointment.patient?.fName ?? ''} ${appointment.patient?.lName ?? ''}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>AppointmentDetailsPage(appointmentId: appointment.id!)))
        .then((_) => _loadInitialAppointments());}),
    );
  }
}