import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/conditions_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';

class EditConditionPage extends StatefulWidget {
  final ConditionsModel condition;
  final String patientId;

  const EditConditionPage({super.key, required this.condition, required this.patientId});

  @override
  _EditConditionPageState createState() => _EditConditionPageState();
}

class _EditConditionPageState extends State<EditConditionPage> {
  final _formKey = GlobalKey<FormState>();
  final _healthIssueController = TextEditingController();
  final _summaryController = TextEditingController();
  final _noteController = TextEditingController();
  final _extraNoteController = TextEditingController();
  DateTime? _onSetDate;
  DateTime? _abatementDate;
  DateTime? _recordDate;
  bool? _isChronic;
  String? _selectedBodySiteId;
  String? _selectedClinicalStatusId;
  String? _selectedVerificationStatusId;
  String? _selectedStageId;

  @override
  void initState() {
    super.initState();
    _healthIssueController.text = widget.condition.healthIssue ?? '';
    _summaryController.text = widget.condition.summary ?? '';
    _noteController.text = widget.condition.note ?? '';
    _extraNoteController.text = widget.condition.extraNote ?? '';
    _isChronic = widget.condition.isChronic;
    _onSetDate = widget.condition.onSetDate != null ? DateTime.parse(widget.condition.onSetDate!) : null;
    _abatementDate = widget.condition.abatementDate != null ? DateTime.parse(widget.condition.abatementDate!) : null;
    _recordDate = widget.condition.recordDate != null ? DateTime.parse(widget.condition.recordDate!) : null;
    _selectedBodySiteId = widget.condition.bodySite?.id;
    _selectedClinicalStatusId = widget.condition.clinicalStatus?.id;
    _selectedVerificationStatusId = widget.condition.verificationStatus?.id;
    _selectedStageId = widget.condition.stage?.id;

    context.read<ConditionsCubit>().getConditionCodeTypes(context: context);
  }

  @override
  void dispose() {
    _healthIssueController.dispose();
    _summaryController.dispose();
    _noteController.dispose();
    _extraNoteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final condition = ConditionsModel(
        id: widget.condition.id,
        healthIssue: _healthIssueController.text,
        isChronic: _isChronic,
        onSetDate: _onSetDate?.toIso8601String(),
        abatementDate: _abatementDate?.toIso8601String(),
        recordDate: _recordDate?.toIso8601String(),
        bodySite: _selectedBodySiteId != null
            ? CodeModel(id: _selectedBodySiteId!, display: '', code: '', description: '', codeTypeId: '')
            : null,
        clinicalStatus: _selectedClinicalStatusId != null
            ? CodeModel(id: _selectedClinicalStatusId!, display: '', code: '', description: '', codeTypeId: '')
            : null,
        verificationStatus: _selectedVerificationStatusId != null
            ? CodeModel(id: _selectedVerificationStatusId!, display: '', code: '', description: '', codeTypeId: '')
            : null,
        stage: _selectedStageId != null
            ? CodeModel(id: _selectedStageId!, display: '', code: '', description: '', codeTypeId: '')
            : null,
        summary: _summaryController.text.isNotEmpty ? _summaryController.text : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        extraNote: _extraNoteController.text.isNotEmpty ? _extraNoteController.text : null,
      );

      context.read<ConditionsCubit>().updateCondition(
        condition: condition,
        conditionId: widget.condition.id!,
        patientId: widget.patientId,
        context: context,
      ).then((_) {
        if (context.read<ConditionsCubit>().state is ConditionUpdatedSuccess) {
          Navigator.pop(context);
        }
      });
    }
  }

  Widget _buildCodeDropdown({
    required String title,
    required String? value,
    required String codeTypeName,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, state) {
            if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
              return const CircularProgressIndicator();
            }

            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes = state.codes?.where((code) => code.codeTypeModel?.name == codeTypeName).toList() ?? [];
            }

            return DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Select'),
                ),
                ...codes.map((code) => DropdownMenuItem(
                  value: code.id,
                  child: Text(code.display),
                )),
              ],
              onChanged: onChanged,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Condition'.tr(context)),
      ),
      body: BlocConsumer<ConditionsCubit, ConditionsState>(
        listener: (context, state) {
          if (state is ConditionsError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is ConditionUpdatedSuccess) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ConditionsLoading) {
            return const Center(child: LoadingPage());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _healthIssueController,
                    decoration: InputDecoration(
                      labelText: 'Health Issue'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a health issue'.tr(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chronic Condition'.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Radio<bool?>(
                        value: null,
                        groupValue: _isChronic,
                        onChanged: (value) => setState(() => _isChronic = value),
                      ),
                      Text('Not specified'.tr(context)),
                      Radio<bool?>(
                        value: true,
                        groupValue: _isChronic,
                        onChanged: (value) => setState(() => _isChronic = value),
                      ),
                      Text('Chronic'.tr(context)),
                      Radio<bool?>(
                        value: false,
                        groupValue: _isChronic,
                        onChanged: (value) => setState(() => _isChronic = value),
                      ),
                      Text('Acute'.tr(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCodeDropdown(
                    title: 'Body Site',
                    value: _selectedBodySiteId,
                    codeTypeName: 'body_site',
                    onChanged: (value) => setState(() => _selectedBodySiteId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'Clinical Status',
                    value: _selectedClinicalStatusId,
                    codeTypeName: 'condition_clinical_status',
                    onChanged: (value) => setState(() => _selectedClinicalStatusId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'Verification Status',
                    value: _selectedVerificationStatusId,
                    codeTypeName: 'condition_verification_status',
                    onChanged: (value) => setState(() => _selectedVerificationStatusId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'Stage',
                    value: _selectedStageId,
                    codeTypeName: 'condition_stage',
                    onChanged: (value) => setState(() => _selectedStageId = value),
                  ),
                  Text(
                    'Onset Date'.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    title: Text(
                      _onSetDate != null
                          ? DateFormat('MMM d, y').format(_onSetDate!)
                          : 'Select Onset Date'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _onSetDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _onSetDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Abatement Date'.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    title: Text(
                      _abatementDate != null
                          ? DateFormat('MMM d, y').format(_abatementDate!)
                          : 'Select Abatement Date'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _onSetDate ?? DateTime.now(),
                        firstDate: _onSetDate ?? DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _abatementDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Record Date'.tr(context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    title: Text(
                      _recordDate != null
                          ? DateFormat('MMM d, y').format(_recordDate!)
                          : 'Select Record Date'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _recordDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _recordDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _summaryController,
                    decoration: InputDecoration(
                      labelText: 'Summary'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Notes'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _extraNoteController,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Update Condition'.tr(context)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}