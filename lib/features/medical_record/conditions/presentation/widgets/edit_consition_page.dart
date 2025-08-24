import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/conditions/presentation/widgets/service_request_selection_page.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../encounters/data/models/encounter_model.dart';
import '../../../service_request/data/models/service_request_model.dart';
import '../../data/models/conditions_model.dart';
import '../cubit/condition_cubit/conditions_cubit.dart';
import 'encounter_selection_page.dart';

class EditConditionPage extends StatefulWidget {
  final ConditionsModel condition;
  final String patientId;

  const EditConditionPage({
    super.key,
    required this.condition,
    required this.patientId,
  });

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
  List<String> _selectedEncounterIds = [];
  List<String> _selectedObservationServiceRequestIds = [];
  List<String> _selectedImagingStudyServiceRequestIds = [];

  @override
  void initState() {
    super.initState();
    _healthIssueController.text = widget.condition.healthIssue ?? '';
    _summaryController.text = widget.condition.summary ?? '';
    _noteController.text = widget.condition.note ?? '';
    _extraNoteController.text = widget.condition.extraNote ?? '';
    _isChronic = widget.condition.isChronic;
    _onSetDate =
        widget.condition.onSetDate != null
            ? DateTime.parse(widget.condition.onSetDate!)
            : null;
    _abatementDate =
        widget.condition.abatementDate != null
            ? DateTime.parse(widget.condition.abatementDate!)
            : null;
    _recordDate =
        widget.condition.recordDate != null
            ? DateTime.parse(widget.condition.recordDate!)
            : null;
    _selectedBodySiteId = widget.condition.bodySite?.id;
    _selectedClinicalStatusId = widget.condition.clinicalStatus?.id;
    _selectedVerificationStatusId = widget.condition.verificationStatus?.id;
    _selectedStageId = widget.condition.stage?.id;

    _selectedEncounterIds = widget.condition.encounters?.map((e) => e.id!).toList() ?? [];
    _selectedObservationServiceRequestIds = widget.condition.serviceRequests
        ?.where((sr) => sr.observation != null)
        .map((sr) => sr.id!)
        .toList() ?? [];
    _selectedImagingStudyServiceRequestIds = widget.condition.serviceRequests
        ?.where((sr) => sr.imagingStudy != null)
        .map((sr) => sr.id!)
        .toList() ?? [];

    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);
    context.read<CodeTypesCubit>().getConditionClinicalStatusTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getConditionVerificationStatusTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getConditionStageTypeCodes(context: context);
    context.read<ConditionsCubit>().getLast10Encounters(
      patientId: widget.patientId,
      context: context,
    );
    context.read<ConditionsCubit>().getCombinedServiceRequests(
      patientId: widget.patientId,
      context: context,
    );
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
        bodySite:
            _selectedBodySiteId != null
                ? CodeModel(
                  id: _selectedBodySiteId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        clinicalStatus:
            _selectedClinicalStatusId != null
                ? CodeModel(
                  id: _selectedClinicalStatusId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        verificationStatus:
            _selectedVerificationStatusId != null
                ? CodeModel(
                  id: _selectedVerificationStatusId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        stage:
            _selectedStageId != null
                ? CodeModel(
                  id: _selectedStageId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        summary:
            _summaryController.text.isNotEmpty ? _summaryController.text : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        extraNote:
            _extraNoteController.text.isNotEmpty
                ? _extraNoteController.text
                : null,
        encounters: _selectedEncounterIds.map((id) => EncounterModel(id: id)).toList(),
        serviceRequests: [
          ..._selectedObservationServiceRequestIds.map((id) => ServiceRequestModel(id: id)),
          ..._selectedImagingStudyServiceRequestIds.map((id) => ServiceRequestModel(id: id)),
        ],
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
            // Show loading indicator while data is loading
            if (state is CodeTypesLoading || state is CodesLoading) {
              return  Center(child: LoadingButton());
            }

            // Show error message if loading failed
            if (state is CodeTypesError) {
              return Text('Error loading codes: ${state.error}');
            }

            // Get codes when loaded
            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes = state.codes
                  ?.where((code) => code.codeTypeModel?.name == codeTypeName)
                  .toList() ?? [];
            }

            // Don't show dropdown if list is empty
            if (codes.isEmpty) {
              return Text('No options available for ${title.tr(context)}');
            }

            // Verify the initial value exists in the list
            final validValue = codes.any((code) => code.id == value) ? value : null;

            // If we have an initial value but it's not in the list, reset it
            if (value != null && validValue == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onChanged(null);
              });
            }

            return DropdownButtonFormField<String>(
              value: validValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('${'editConditionPage.select'.tr(context)}...'),
                ),
                ...codes.map(
                      (code) => DropdownMenuItem(
                    value: code.id,
                    child: Text(code.display),
                  ),
                ),
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'editConditionPage.editCondition'.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
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
                      labelText: 'editConditionPage.healthIssue'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'editConditionPage.pleaseEnterHealthIssue'.tr(
                          context,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'editConditionPage.chronicCondition'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<bool?>(
                        value: null,
                        groupValue: _isChronic,
                        onChanged:
                            (value) => setState(() => _isChronic = value),
                      ),
                      Text('editConditionPage.notSpecified'.tr(context)),
                      Radio<bool?>(
                        value: true,
                        groupValue: _isChronic,
                        onChanged:
                            (value) => setState(() => _isChronic = value),
                      ),
                      Text('editConditionPage.chronic'.tr(context)),
                      Radio<bool?>(
                        value: false,
                        groupValue: _isChronic,
                        onChanged:
                            (value) => setState(() => _isChronic = value),
                      ),
                      Text('editConditionPage.acute'.tr(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCodeDropdown(
                    title: 'editConditionPage.bodySite',
                    value: _selectedBodySiteId,
                    codeTypeName: 'body_site',
                    onChanged:
                        (value) => setState(() => _selectedBodySiteId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'editConditionPage.clinicalStatus',
                    value: _selectedClinicalStatusId,
                    codeTypeName: 'condition_clinical_status',
                    onChanged:
                        (value) =>
                            setState(() => _selectedClinicalStatusId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'editConditionPage.verificationStatus',
                    value: _selectedVerificationStatusId,
                    codeTypeName: 'condition_verification_status',
                    onChanged:
                        (value) => setState(
                          () => _selectedVerificationStatusId = value,
                        ),
                  ),
                  _buildCodeDropdown(
                    title: 'editConditionPage.stage',
                    value: _selectedStageId,
                    codeTypeName: 'condition_stage',
                    onChanged:
                        (value) => setState(() => _selectedStageId = value),
                  ),
                  Text(
                    'editConditionPage.onsetDate'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _onSetDate != null
                          ? DateFormat('MMM d, y').format(_onSetDate!)
                          : 'editConditionPage.selectOnsetDate'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _onSetDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _onSetDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'editConditionPage.abatementDate'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _abatementDate != null
                          ? DateFormat('MMM d, y').format(_abatementDate!)
                          : 'editConditionPage.selectAbatementDate'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _onSetDate ?? DateTime.now(),
                        firstDate:  DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _abatementDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'editConditionPage.recordDate'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _recordDate != null
                          ? DateFormat('MMM d, y').format(_recordDate!)
                          : 'editConditionPage.selectRecordDate'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _recordDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
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
                      labelText: 'editConditionPage.summary'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'editConditionPage.notes'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _extraNoteController,
                    decoration: InputDecoration(
                      labelText: 'editConditionPage.additionalNotes'.tr(
                        context,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: Text('Select Encounters'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EncounterSelectionPage(
                            patientId: widget.patientId,
                            initiallySelected: _selectedEncounterIds,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() => _selectedEncounterIds = result);
                      }
                    },
                  ),
                  Text(
                    _selectedEncounterIds.isEmpty
                        ? 'No encounters selected'
                        : 'Selected ${_selectedEncounterIds.length} encounters',
                  ),

                  ListTile(
                    title: Text('Select Service Requests'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await Navigator.push<Map<String, List<String>>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceRequestSelectionPage(
                            patientId: widget.patientId,
                            initiallySelectedObservations: _selectedObservationServiceRequestIds,
                            initiallySelectedImaging: _selectedImagingStudyServiceRequestIds,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedObservationServiceRequestIds = result['observations'] ?? [];
                          _selectedImagingStudyServiceRequestIds = result['imaging'] ?? [];
                        });
                      }
                    },
                  ),
                  Text(
                    _selectedObservationServiceRequestIds.isEmpty &&
                        _selectedImagingStudyServiceRequestIds.isEmpty
                        ? 'No service requests selected'
                        : 'Selected ${_selectedObservationServiceRequestIds.length} observations '
                        'and ${_selectedImagingStudyServiceRequestIds.length} imaging studies',
                  ),


                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'editConditionPage.updateConditionButton'.tr(context),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
