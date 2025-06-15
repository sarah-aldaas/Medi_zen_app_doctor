import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/widgets/allergy_form_page.dart';

import '../../data/models/allergy_filter_model.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_filter_dialog.dart';
import 'allergy_details_page.dart';

class AllergyListPage extends StatefulWidget {
  final String patientId;
  final String? appointmentId;

  const AllergyListPage({super.key, required this.patientId, this.appointmentId});

  @override
  State<AllergyListPage> createState() => _AllergyListPageState();
}

class _AllergyListPageState extends State<AllergyListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (widget.appointmentId == null) {
      context.read<AllergyCubit>().getAllergies(patientId: widget.patientId);
    } else {
      context.read<AllergyCubit>().getAppointmentAllergies(patientId: widget.patientId, appointmentId: widget.appointmentId!);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      _isLoadingMore = true;
      if (widget.appointmentId == null) {
        context.read<AllergyCubit>().getAllergies(patientId: widget.patientId, loadMore: true).then((_) => _isLoadingMore = false);
      } else {
        context
            .read<AllergyCubit>()
            .getAppointmentAllergies(appointmentId: widget.appointmentId!, patientId: widget.patientId, loadMore: true)
            .then((_) => _isLoadingMore = false);
      }
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<AllergyCubit>();
    final result = await showDialog<AllergyFilterModel>(context: context, builder: (context) => AllergyFilterDialog(currentFilter: cubit.currentFilter));

    if (result != null) {
      if (widget.appointmentId == null) {
        cubit.getAllergies(patientId: widget.patientId, filter: result);
      } else {
        cubit.getAppointmentAllergies(patientId: widget.patientId, filter: result, appointmentId: widget.appointmentId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:widget.appointmentId!=null? AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AllergyFormPage(patientId: widget.patientId,appointmentId: widget.appointmentId,))).then((value) {
              if (widget.appointmentId == null) {
                context.read<AllergyCubit>().getAllergies(patientId: widget.patientId);
              } else {
                context.read<AllergyCubit>().getAppointmentAllergies(patientId: widget.patientId, appointmentId: widget.appointmentId!);
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text('Add allergy', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              Icon(Icons.add, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
        actions: [IconButton(onPressed: () => _showFilterDialog(), icon: Icon(Icons.filter_list))],
      ):null,
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading && state.isInitialLoad) {
            return const Center(child: LoadingPage());
          }

          if (state is AllergySuccess) {
            return _buildAllergyList(state);
          }

          if (state is AllergyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.appointmentId == null) {
                        context.read<AllergyCubit>().getAllergies(patientId: widget.patientId);
                      } else {
                        context.read<AllergyCubit>().getAppointmentAllergies(appointmentId: widget.appointmentId!, patientId: widget.patientId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAllergyList(AllergySuccess state) {
    if (state.allergies.isEmpty) {
      return Center(child: Text('No allergies for this appointment.'));
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: state.allergies.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.allergies.length) {
          return _buildAllergyItem(state.allergies[index]);
        } else {
          return Center(child: LoadingButton());
        }
      },
    );
  }

  Widget _buildAllergyItem(AllergyModel allergy) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(allergy.name ?? 'Unknown allergy'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allergy.type != null) Text('Type: ${allergy.type!.display}'),
            if (allergy.clinicalStatus != null) Text('Status: ${allergy.clinicalStatus!.display}'),
            if (allergy.lastOccurrence != null) Text('Last Occurrence: ${allergy.lastOccurrence}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllergyDetailsPage(patientId: widget.patientId, allergyId: allergy.id!)),
            ).then((value) {
              context.read<AllergyCubit>().getAllergies(patientId: widget.patientId);
            }),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
