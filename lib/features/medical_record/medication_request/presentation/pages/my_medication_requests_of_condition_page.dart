import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_request_filter.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';
import 'medication_request_details_page.dart';

class MyMedicationRequestsOfConditionPage extends StatefulWidget {
  final MedicationRequestFilterModel? filter;
  final String patientId;
  final String conditionId;
  const MyMedicationRequestsOfConditionPage({
    super.key,
     this.filter,
    required this.patientId,
    required this.conditionId,
  });

  @override
  _MyMedicationRequestsOfConditionPageState createState() =>
      _MyMedicationRequestsOfConditionPageState();
}

class _MyMedicationRequestsOfConditionPageState extends State<MyMedicationRequestsOfConditionPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialMedicationRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialMedicationRequests() {
    _isLoadingMore = false;
    context.read<MedicationRequestCubit>().getMedicationRequestForCondition(
      context: context,
      filters: widget.filter?.toJson(),
      patientId: widget.patientId,
      conditionId: widget.conditionId,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<MedicationRequestCubit>()
          .getMedicationRequestForCondition(
            filters: widget.filter?.toJson(),
            loadMore: true,
            context: context,
            patientId: widget.patientId,
            conditionId: widget.conditionId,
          )
          .then((_) => setState(() => _isLoadingMore = false));
    }
  }

  @override
  void didUpdateWidget(MyMedicationRequestsOfConditionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.filter != oldWidget.filter) {
      _loadInitialMedicationRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final medicationRequests =
              state is MedicationRequestSuccess
                  ? state.paginatedResponse.paginatedData!.items
                  : [];
          final hasMore =
              state is MedicationRequestSuccess ? state.hasMore : false;

          if (medicationRequests.isEmpty) {
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
                    'myMedicationRequests.noRequests'.tr(context),
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: medicationRequests.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < medicationRequests.length) {
                return _buildMedicationRequestCard(medicationRequests[index]);
              } else if (hasMore && state is! MedicationRequestError) {
                return  Center(child: LoadingButton());
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Widget _buildMedicationRequestCard(MedicationRequestModel request) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MedicationRequestDetailsPage(
                    appointmentId: null,
                    medicationRequestId: request.id.toString(),
                    patientId: widget.patientId,
                  ),
            ),
          ).then((_) => _loadInitialMedicationRequests()),
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
                    Icons.receipt_long,
                    color: AppColors.primaryColor,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.reason ??
                              'myMedicationRequests.defaultMedicationRequest'
                                  .tr(context),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.note ??
                              'myMedicationRequests.noAdditionalNotes'.tr(
                                context,
                              ),
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
                  if (request.status != null)
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
                        request.status!.display,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  const Spacer(),
                  if (request.statusChanged != null)
                    Text(
                      request.statusChanged!,
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
