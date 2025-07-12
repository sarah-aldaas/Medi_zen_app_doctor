import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import '../../../conditions/data/models/conditions_model.dart';
import '../../../conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import '../../data/models/diagnostic_report_model.dart';
import '../cubit/diagnostic_report_cubit/diagnostic_report_cubit.dart';

class UpdateDiagnosticReportPage extends StatefulWidget {
  final DiagnosticReportModel diagnosticReport;
  final String patientId;
  final String diagnosticReportId;
  final String? appointmentId; // Optional for filtering conditions

  const UpdateDiagnosticReportPage({super.key, required this.diagnosticReport, required this.patientId, required this.diagnosticReportId, this.appointmentId});

  @override
  State<UpdateDiagnosticReportPage> createState() => _UpdateDiagnosticReportPageState();
}

class _UpdateDiagnosticReportPageState extends State<UpdateDiagnosticReportPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _conclusionController;
  late TextEditingController _noteController;
  ConditionsModel? _selectedCondition;
  List<ConditionsModel> _conditions = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.diagnosticReport.name);
    _conclusionController = TextEditingController(text: widget.diagnosticReport.conclusion);
    _noteController = TextEditingController(text: widget.diagnosticReport.note);
    _selectedCondition = widget.diagnosticReport.condition;
    _fetchConditions();
  }

  void _fetchConditions() {
    if (widget.appointmentId != null) {
      context.read<ConditionsCubit>().getConditionsForAppointment(appointmentId: widget.appointmentId!, patientId: widget.patientId, context: context);
    } else {
      context.read<ConditionsCubit>().getAllConditions(patientId: widget.patientId, context: context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conclusionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("diagnosticReportUpdate.updateDiagnosticReport".tr(context)),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _submitForm)],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DiagnosticReportCubit, DiagnosticReportState>(
            listener: (context, state) {
              if (state is DiagnosticReportError) {
                ShowToast.showToastError(message: state.error);
              } else if (state is DiagnosticReportOperationSuccess) {
                ShowToast.showToastSuccess(message: "diagnosticReportUpdate.diagnosticReportUpdatedSuccessfully".tr(context));
                Navigator.pop(context, true);
              }
            },
          ),
          BlocListener<ConditionsCubit, ConditionsState>(
            listener: (context, state) {
              if (state is ConditionsSuccess) {
                setState(() {
                  _conditions = state.paginatedResponse.paginatedData!.items;
                  // Keep the selected condition if it exists in the new list
                  if (_selectedCondition != null) {
                    final existingCondition = _conditions.firstWhere((c) => c.id == _selectedCondition!.id, orElse: () => ConditionsModel());
                    if (existingCondition.id == null) {
                      _selectedCondition = null;
                    }
                  }
                });
              } else if (state is ConditionsError) {
                ShowToast.showToastError(message: state.error);
              }
            },
          ),
        ],
        child: BlocBuilder<DiagnosticReportCubit, DiagnosticReportState>(
          builder: (context, state) {
            if (state is DiagnosticReportOperationLoading) {
              return const LoadingPage();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(
                      controller: _nameController,
                      label: "diagnosticReportUpdate.reportName".tr(context),
                      hint: "diagnosticReportUpdate.enterReportName".tr(context),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    if (_conditions.isNotEmpty) _buildConditionDropdown(),

                    if (_conditions.isEmpty) _buildConditionInfo(),

                    _buildFormField(
                      controller: _conclusionController,
                      label: "diagnosticReportUpdate.conclusion".tr(context),
                      hint: "diagnosticReportUpdate.enterConclusion".tr(context),
                      maxLines: 5,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      controller: _noteController,
                      label: "diagnosticReportUpdate.notes".tr(context),
                      hint: "diagnosticReportUpdate.enterNotes".tr(context),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormField({required TextEditingController controller, required String label, required String hint, bool isRequired = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(text: label, children: [if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          maxLines: maxLines,
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return "diagnosticReportUpdate.fieldRequired".tr(context);
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildConditionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("diagnosticReportUpdate.relatedCondition".tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<ConditionsModel>(
          value: _selectedCondition,
          items:
              _conditions.map((condition) {
                return DropdownMenuItem<ConditionsModel>(
                  value: condition,
                  child: Text(condition.healthIssue ?? "diagnosticReportUpdate.unknownCondition".tr(context), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCondition = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: "diagnosticReportUpdate.selectCondition".tr(context),
          ),
          validator: (value) {
            if (value == null) {
              return "diagnosticReportUpdate.conditionRequired".tr(context);
            }
            return null;
          },
          isExpanded: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConditionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("diagnosticReportUpdate.relatedCondition".tr(context), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: Text(
            widget.diagnosticReport.condition?.healthIssue ?? "diagnosticReportUpdate.unknownCondition".tr(context),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedReport = DiagnosticReportModel(
        name: _nameController.text,
        conclusion: _conclusionController.text,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        condition: _selectedCondition ?? widget.diagnosticReport.condition,
      );

      context.read<DiagnosticReportCubit>().updateDiagnosticReport(
        diagnosticReport: updatedReport,
        context: context,
        patientId: widget.patientId,
        diagnosticReportId: widget.diagnosticReportId,
      );
    }
  }
}
