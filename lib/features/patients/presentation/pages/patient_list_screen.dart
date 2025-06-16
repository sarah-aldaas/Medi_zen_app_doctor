import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/features/patients/presentation/pages/patient_details_page.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/patient_filter_model.dart';
import '../cubit/patient_cubit/patient_cubit.dart';
import '../widgets/patient_filter_dialog.dart';
import '../widgets/patient_item.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    context.read<PatientCubit>().listPatients();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<PatientCubit>().listPatients(loadMore: true).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final cubit = context.read<PatientCubit>();
    final result = await showDialog<PatientFilterModel>(
      context: context,

      builder:
          (context) => PatientFilterDialog(currentFilter: cubit.currentFilter),
    );

    if (result != null) {
      cubit.listPatients(filter: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),

        ),
        title: Text(
          'Patients',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<PatientCubit, PatientState>(
        listener: (context, state) {
          if (state is PatientError) {

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is PatientLoading && state is! PatientSuccess) {
            return const Center(child: LoadingPage());
          }

          if (state is PatientSuccess) {
            if (state.patients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline, size: 64),
                    const SizedBox(height: 16),
                    const Text('No patients found'),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: state.patients.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.patients.length) {
                  return Center(child: LoadingButton());
                }
                return PatientItem(
                  patient: state.patients[index],
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PatientDetailsPage(
                              patientId: state.patients[index].id!,
                            ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
