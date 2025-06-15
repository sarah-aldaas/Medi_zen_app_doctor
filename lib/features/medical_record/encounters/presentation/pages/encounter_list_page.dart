import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/create_edit_encounter_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_details_page.dart';

import '../../data/models/encounter_filter_model.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';
import '../widgets/encounter_filter_dialog.dart';

class EncounterListPage extends StatefulWidget {
  final String patientId;
  final String? appointmentId;

  const EncounterListPage({super.key, required this.patientId, this.appointmentId});

  @override
  State<EncounterListPage> createState() => _EncounterListPageState();
}

class _EncounterListPageState extends State<EncounterListPage> {
  final ScrollController _scrollController = ScrollController();
  EncounterFilterModel _filter = EncounterFilterModel();
  bool _isLoadingMore = false;
  List<EncounterModel> list = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialEncounters();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialEncounters() {
    _isLoadingMore = false;
    if (widget.appointmentId != null) {
      context.read<EncounterCubit>().getAppointmentEncounters(patientId: widget.patientId, appointmentId: widget.appointmentId!);
    } else {
      context.read<EncounterCubit>().getPatientEncounters(patientId: widget.patientId, filters: _filter.toJson());
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future =
          widget.appointmentId != null
              ? context.read<EncounterCubit>().getAppointmentEncounters(patientId: widget.patientId, appointmentId: widget.appointmentId!)
              : context.read<EncounterCubit>().getPatientEncounters(patientId: widget.patientId, filters: _filter.toJson(), loadMore: true);
      future.then((_) => setState(() => _isLoadingMore = false));
    }
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<EncounterFilterModel>(context: context, builder: (context) => EncounterFilterDialog(currentFilter: _filter));

    if (result != null) {
      setState(() => _filter = result);
      _loadInitialEncounters();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is EncounterLoading) {
            return const Center(child: LoadingPage());
          }
          if (state is EncounterListSuccess) {
              list = state.paginatedResponse.paginatedData!.items;
          }

          if (state is EncounterDetailsSuccess) {
              list =state.encounter!=null? [state.encounter!]:[];
          }

          final encounters = state is EncounterDetailsSuccess
              ? [state.encounter]
              : state is EncounterListSuccess
              ? state.paginatedResponse.paginatedData!.items
              : <EncounterModel>[];
          final hasMore = state is EncounterListSuccess ? state.hasMore : false;

          if (encounters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No encounters found.", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  TextButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateEditEncounterPage(patientId: widget.patientId, appointmentId: widget.appointmentId)),
                    ).then((_) => _loadInitialEncounters());
                  }, child: Text("Add encounter"))
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: encounters.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < encounters.length) {
                return _buildEncounterItem(encounters[index]!);
              } else if (hasMore && state is! EncounterError) {
                return Center(child: LoadingButton());
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildEncounterItem(EncounterModel encounter) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(encounter.reason ?? 'No reason specified', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Status: ${encounter.status?.display ?? 'Unknown'}'),
            Text('Start: ${encounter.actualStartDate ?? 'N/A'}'),
            if (widget.appointmentId == null) Text('Appointment: ${encounter.appointment?.reason ?? 'N/A'}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EncounterDetailsPage(patientId: widget.patientId, encounterId: encounter.id!)),
          ).then((_) => _loadInitialEncounters());
        },
        // onTap: () => context.pushNamed(
        //   AppRouter.encounterDetails.name,
        //   pathParameters: {
        //     'patientId': widget.patientId.toString(),
        //     'encounterId': encounter.id!,
        //   },
        //   extra: {
        //     'patientId': widget.patientId.toString(),
        //     'encounterId': encounter.id!,
        //   },
        // ).then((_) => _loadInitialEncounters()),
      ),
    );
  }
}
