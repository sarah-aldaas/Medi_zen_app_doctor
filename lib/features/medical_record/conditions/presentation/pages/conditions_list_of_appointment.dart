import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/conditions_filter_model.dart';
import '../../data/models/conditions_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';
import '../widgets/create_condition_page.dart';
import 'condition_details_page.dart';

class ConditionsListOfAppointmentPage extends StatefulWidget {
  final ConditionsFilterModel filter;
  final String appointmentId;
  final String patientId;

  const ConditionsListOfAppointmentPage({
    super.key,
    required this.filter,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  _ConditionsListOfAppointmentPageState createState() => _ConditionsListOfAppointmentPageState();
}

class _ConditionsListOfAppointmentPageState extends State<ConditionsListOfAppointmentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialConditions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConditionsListOfAppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter || widget.patientId != oldWidget.patientId) {
      _loadInitialConditions();
    }
  }

  void _loadInitialConditions() {
    _isLoadingMore = false;
      context.read<ConditionsCubit>().getConditionsForAppointment(
        appointmentId: widget.appointmentId!,
        patientId: widget.patientId,
        context: context,
        filters: widget.filter.toJson(),
      );

  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final future = context.read<ConditionsCubit>().getConditionsForAppointment(
        appointmentId: widget.appointmentId!,
        patientId: widget.patientId,
        loadMore: true,
        context: context,
        filters: widget.filter.toJson(),
      );

      future.then((_) => setState(() => _isLoadingMore = false));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateConditionPage(patientId: widget.patientId),
          ),
        ).then((_) => _loadInitialConditions()),
        child: const Icon(Icons.add),
        tooltip: 'Add Condition',
      ),
      body: BlocConsumer<ConditionsCubit, ConditionsState>(
        listener: (context, state) {
          if (state is ConditionsError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is ConditionCreatedSuccess || state is ConditionUpdatedSuccess || state is ConditionDeletedSuccess) {
            _loadInitialConditions();
          }
        },
        builder: (context, state) {
          if (state is ConditionsLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }

          final conditions = state is ConditionsSuccess ? state.paginatedResponse.paginatedData!.items : [];
          final hasMore = state is ConditionsSuccess ? state.hasMore : false;

          if (conditions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("No conditions found".tr(context), style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _loadInitialConditions(),
                    child: Text("Refresh".tr(context)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadInitialConditions(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: conditions.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < conditions.length) {
                  return _buildConditionItem(conditions[index]);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConditionItem(ConditionsModel condition) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(Icons.medical_services, color: Theme.of(context).primaryColor),
        title: Text(condition.healthIssue ?? 'Unknown condition'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (condition.onSetDate != null)
              Text('Onset: ${DateFormat('MMM d, y').format(DateTime.parse(condition.onSetDate!))}'),
            if (condition.clinicalStatus != null)
              Text('Status: ${condition.clinicalStatus!.display}'),
            if (condition.verificationStatus != null)
              Text('Verification: ${condition.verificationStatus!.display}'),
            if (condition.stage != null)
              Text('Stage: ${condition.stage!.display}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConditionDetailsPage(
              conditionId: condition.id!,
              patientId: widget.patientId,
              isAppointment: true,
            ),
          ),
        ).then((_) => _loadInitialConditions()),
      ),
    );
  }
}