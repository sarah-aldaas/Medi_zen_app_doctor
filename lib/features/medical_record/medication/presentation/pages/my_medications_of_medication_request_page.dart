import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_filter_model.dart';
import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';
import 'medication_details_page.dart';

class MyMedicationsOfMedicationRequestPage extends StatefulWidget {
  final String patientId;
  final String conditionId;
  final String medicationRequestId;
  final MedicationFilterModel? filter;

  const MyMedicationsOfMedicationRequestPage({
    super.key,
    required this.patientId,
    required this.medicationRequestId,
    required this.conditionId,
     this.filter,
  });

  @override
  _MyMedicationsOfMedicationRequestPageState createState() => _MyMedicationsOfMedicationRequestPageState();
}

class _MyMedicationsOfMedicationRequestPageState extends State<MyMedicationsOfMedicationRequestPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialMedications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMedications() {
    _isLoadingMore = false;
    context.read<MedicationCubit>().getAllMedicationForMedicationRequest(
      context: context,
      filters: widget.filter?.toJson(),
      patientId: widget.patientId,
      conditionId: widget.conditionId,
      medicationRequestId: widget.medicationRequestId,

    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationCubit>()
          .getAllMedicationForMedicationRequest(
            filters: widget.filter?.toJson(),
            loadMore: true,
            context: context,
            patientId: widget.patientId,
            conditionId: widget.conditionId,
            medicationRequestId: widget.medicationRequestId,

          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  void didUpdateWidget(MyMedicationsOfMedicationRequestPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _loadInitialMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medications =
              state is MedicationSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : [];
          final hasMore = state is MedicationSuccess ? state.hasMore : false;

          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "myMedications.noMedications".tr(context),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: medications.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < medications.length) {
                return _buildMedicationCard(medications[index]);
              } else if (hasMore && state is! MedicationError) {
                return  Center(child: LoadingButton());
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(MedicationModel medication) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MedicationDetailsPage(
                    medicationId: medication.id.toString(),
                    patientId: widget.patientId,
                    conditionId: widget.conditionId,
                    medicationRequestId:medication.medicationRequest!.id! ,
                    appointmentId: null,
                  ),
            ),
          ).then((_) => _loadInitialMedications()),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medication,
                    color: AppColors.primaryColor,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name ??
                              'myMedications.unknownMedication'.tr(context),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.dosageInstructions ??
                              'myMedications.noInstructions'.tr(context),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (medication.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        medication.status!.display,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  const Spacer(),
                  if (medication.effectiveMedicationStartDate != null)
                    Text(
                      DateFormat(
                        'MMM d, y',
                      ).format(medication.effectiveMedicationStartDate!),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
