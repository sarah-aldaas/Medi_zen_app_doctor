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

class CreateConditionPage extends StatefulWidget {
  final String patientId;
  final String appointmentId;

  const CreateConditionPage({
    super.key,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  _CreateConditionPageState createState() => _CreateConditionPageState();
}

class _CreateConditionPageState extends State<CreateConditionPage> {
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
        encounters:
            _selectedEncounterIds.map((id) => EncounterModel(id: id)).toList(),
        serviceRequests: [
          ..._selectedObservationServiceRequestIds.map(
            (id) => ServiceRequestModel(id: id),
          ),
          ..._selectedImagingStudyServiceRequestIds.map(
            (id) => ServiceRequestModel(id: id),
          ),
        ],
      );

      context
          .read<ConditionsCubit>()
          .createCondition(
            condition: condition,
            patientId: widget.patientId,
            appointmentId: widget.appointmentId,
            context: context,
          )
          .then((_) {
            if (context.read<ConditionsCubit>().state
                is ConditionCreatedSuccess) {
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
            if (state is CodeTypesLoading ||
                state is CodesLoading ||
                state is CodeTypesInitial) {
              return LoadingButton();
            }

            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes =
                  state.codes
                      ?.where(
                        (code) => code.codeTypeModel!.name == codeTypeName,
                      )
                      .toList() ??
                  [];
            }
            if (codes.isNotEmpty) {
              return DropdownButtonFormField<String>(
                value: value,
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
                    child: Text('createConditionPage.select'.tr(context)),
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
            } else {
              return Text('');
            }
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
          'createConditionPage.createCondition'.tr(context),
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
          } else if (state is ConditionCreatedSuccess) {
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
                      labelText: 'createConditionPage.healthIssue'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'createConditionPage.pleaseEnterHealthIssue'.tr(
                          context,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'createConditionPage.chronicCondition'.tr(context),
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
                      Text('createConditionPage.notSpecified'.tr(context)),
                      Radio<bool?>(
                        value: true,
                        groupValue: _isChronic,
                        onChanged:
                            (value) => setState(() => _isChronic = value),
                      ),
                      Text('createConditionPage.chronic'.tr(context)),
                      Radio<bool?>(
                        value: false,
                        groupValue: _isChronic,
                        onChanged:
                            (value) => setState(() => _isChronic = value),
                      ),
                      Text('createConditionPage.acute'.tr(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCodeDropdown(
                    title: 'createConditionPage.bodySite',
                    value: _selectedBodySiteId,
                    codeTypeName: 'body_site',
                    onChanged:
                        (value) => setState(() => _selectedBodySiteId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'createConditionPage.clinicalStatus',
                    value: _selectedClinicalStatusId,
                    codeTypeName: 'condition_clinical_status',
                    onChanged:
                        (value) =>
                            setState(() => _selectedClinicalStatusId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'createConditionPage.verificationStatus',
                    value: _selectedVerificationStatusId,
                    codeTypeName: 'condition_verification_status',
                    onChanged:
                        (value) => setState(
                          () => _selectedVerificationStatusId = value,
                        ),
                  ),
                  _buildCodeDropdown(
                    title: 'createConditionPage.stage',
                    value: _selectedStageId,
                    codeTypeName: 'condition_stage',
                    onChanged:
                        (value) => setState(() => _selectedStageId = value),
                  ),
                  Text(
                    'createConditionPage.onsetDate'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _onSetDate != null
                          ? DateFormat('MMM d, y').format(_onSetDate!)
                          : 'createConditionPage.selectOnsetDate'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
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
                    'createConditionPage.abatementDate'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _abatementDate != null
                          ? DateFormat('MMM d, y').format(_abatementDate!)
                          : 'createConditionPage.selectAbatementDate'.tr(
                            context,
                          ),
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
                        setState(() => _abatementDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'createConditionPage.recordDate'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _recordDate != null
                          ? DateFormat('MMM d, y').format(_recordDate!)
                          : 'createConditionPage.selectRecordDate'.tr(context),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
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
                      labelText: 'createConditionPage.summary'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'createConditionPage.notes'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _extraNoteController,
                    decoration: InputDecoration(
                      labelText: 'createConditionPage.additionalNotes'.tr(
                        context,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  ListTile(
                    title: Text(
                      'createConditionPage.select_encounters'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EncounterSelectionPage(
                                patientId: widget.patientId,
                                initiallySelected: _selectedEncounterIds,
                              ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedEncounterIds = result;
                        });
                      }
                    },
                  ),
                  Text(
                    _selectedEncounterIds.isEmpty
                        ? 'createConditionPage.no_encounters_selected'.tr(
                          context,
                        )
                        : "${'createConditionPage.selected'.tr(context)}" +
                            "${' '}" +
                            "${_selectedEncounterIds.length}" +
                            "${' '}" +
                            "${'createConditionPage.encounters'.tr(context)}",
                    style: TextStyle(color: Colors.grey),
                  ),

                  ListTile(
                    title: Text(
                      'createConditionPage.select_service'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result =
                          await Navigator.push<Map<String, List<String>>>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ServiceRequestSelectionPage(
                                    patientId: widget.patientId,
                                    initiallySelectedObservations:
                                        _selectedObservationServiceRequestIds,
                                    initiallySelectedImaging:
                                        _selectedImagingStudyServiceRequestIds,
                                  ),
                            ),
                          );
                      if (result != null) {
                        setState(() {
                          _selectedObservationServiceRequestIds =
                              result['observations'] ?? [];
                          _selectedImagingStudyServiceRequestIds =
                              result['imaging'] ?? [];
                        });
                      }
                    },
                  ),
                  Text(
                    _selectedObservationServiceRequestIds.isEmpty &&
                            _selectedImagingStudyServiceRequestIds.isEmpty
                        ? 'createConditionPage.no_service'.tr(context)
                        : "${'createConditionPage.selected'.tr(context)}" +
                            "${' '}" +
                            "${_selectedObservationServiceRequestIds.length}" +
                            "${' '}" +
                            "${'createConditionPage.observations'.tr(context)}" +
                            "${' '}" +
                            "${'createConditionPage.and'.tr(context)}" +
                            "${' '}" +
                            "${_selectedImagingStudyServiceRequestIds.length}" +
                            "${' '}" +
                            "${'createConditionPage.imaging_studies'.tr(context)}",
                    style: TextStyle(color: Colors.grey),
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
                        'createConditionPage.createConditionButton'.tr(context),
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
