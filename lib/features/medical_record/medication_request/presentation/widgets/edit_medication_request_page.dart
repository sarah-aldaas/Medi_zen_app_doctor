import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../conditions/data/models/conditions_model.dart';
import '../../../conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';

class EditMedicationRequestPage extends StatefulWidget {
  final MedicationRequestModel medicationRequest;
  final String patientId;
  final String conditionId;

  const EditMedicationRequestPage({
    super.key,
    required this.medicationRequest,
    required this.patientId,
    required this.conditionId,
  });

  @override
  _EditMedicationRequestPageState createState() =>
      _EditMedicationRequestPageState();
}

class _EditMedicationRequestPageState extends State<EditMedicationRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _statusReasonController = TextEditingController();
  final _noteController = TextEditingController();
  final _numberOfRepeatsController = TextEditingController();
  bool? _doNotPerform;
  String? _selectedIntentId;
  String? _selectedPriorityId;
  String? _selectedCourseOfTherapyTypeId;
  String? _selectedConditionId;

  @override
  void initState() {
    super.initState();
    _reasonController.text = widget.medicationRequest.reason ?? '';
    _statusReasonController.text = widget.medicationRequest.statusReason ?? '';
    _noteController.text = widget.medicationRequest.note ?? '';
    _numberOfRepeatsController.text =
        widget.medicationRequest.numberOfRepeatsAllowed ?? '';

    _doNotPerform = widget.medicationRequest.doNotPerform;
    _selectedIntentId = widget.medicationRequest.intent?.id;
    _selectedPriorityId = widget.medicationRequest.priority?.id;
    _selectedCourseOfTherapyTypeId =
        widget.medicationRequest.courseOfTherapyType?.id;

    context.read<CodeTypesCubit>().getMedicationRequestIntentTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getMedicationRequestPriorityTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getMedicationRequestTherapyTypeTypeCodes(
      context: context,
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _statusReasonController.dispose();
    _noteController.dispose();
    _numberOfRepeatsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final medicationRequest = MedicationRequestModel(
        id: widget.medicationRequest.id,
        reason: _reasonController.text,
        statusReason:
            _statusReasonController.text.isNotEmpty
                ? _statusReasonController.text
                : null,
        doNotPerform: _doNotPerform,
        numberOfRepeatsAllowed:
            _numberOfRepeatsController.text.isNotEmpty
                ? _numberOfRepeatsController.text
                : null,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,

        intent:
            _selectedIntentId != null
                ? CodeModel(
                  id: _selectedIntentId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        priority:
            _selectedPriorityId != null
                ? CodeModel(
                  id: _selectedPriorityId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        courseOfTherapyType:
            _selectedCourseOfTherapyTypeId != null
                ? CodeModel(
                  id: _selectedCourseOfTherapyTypeId!,
                  display: '',
                  code: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        condition:
            _selectedConditionId != null
                ? ConditionsModel(id: _selectedConditionId)
                : null,
      );

      context
          .read<MedicationRequestCubit>()
          .updateMedicationRequest(
        conditionId: widget.conditionId,
            medicationRequest: medicationRequest,
            patientId: widget.patientId,
            medicationRequestId: widget.medicationRequest.id!,
            context: context,
          )
          .then((_) {
            if (context.read<MedicationRequestCubit>().state
                is MedicationRequestUpdated) {
              Navigator.pop(context);
            }
          });
    }
  }

  Widget _buildCodeDropdown({
    required String titleKey,
    required String? value,
    required String codeTypeName,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleKey.tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, state) {
            if (state is CodeTypesLoading ||
                state is CodesLoading ||
                state is CodeTypesInitial) {
              return  LoadingButton();
            }

            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes =
                  state.codes
                      ?.where(
                        (code) => code.codeTypeModel?.name == codeTypeName,
                      )
                      .toList() ??
                  [];
            }

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
                  child: Text('editMedicationRequestPage.select'.tr(context)),
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
          'editMedicationRequestPage.editMedicationRequest'.tr(context),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is MedicationRequestUpdated) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestLoading) {
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
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'editMedicationRequestPage.reason'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'editMedicationRequestPage.pleaseEnterAReason'
                            .tr(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCodeDropdown(
                    titleKey: 'intent',
                    value: _selectedIntentId,
                    codeTypeName: 'medication_request_intent',
                    onChanged:
                        (value) => setState(() => _selectedIntentId = value),
                  ),
                  _buildCodeDropdown(
                    titleKey: 'priority',
                    value: _selectedPriorityId,
                    codeTypeName: 'medication_request_priority',
                    onChanged:
                        (value) => setState(() => _selectedPriorityId = value),
                  ),
                  _buildCodeDropdown(
                    titleKey: 'courseOfTherapyType',
                    value: _selectedCourseOfTherapyTypeId,
                    codeTypeName: 'medication_request_therapy_type',
                    onChanged:
                        (value) => setState(
                          () => _selectedCourseOfTherapyTypeId = value,
                        ),
                  ),
                  Text(
                    'editMedicationRequestPage.doNotPerform'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<bool?>(
                        value: null,
                        groupValue: _doNotPerform,
                        onChanged:
                            (value) => setState(() => _doNotPerform = value),
                      ),
                      Text(
                        'editMedicationRequestPage.notSpecified'.tr(context),
                      ),
                      Radio<bool?>(
                        value: true,
                        groupValue: _doNotPerform,
                        onChanged:
                            (value) => setState(() => _doNotPerform = value),
                      ),
                      Text('editMedicationRequestPage.yes'.tr(context)),
                      Radio<bool?>(
                        value: false,
                        groupValue: _doNotPerform,
                        onChanged:
                            (value) => setState(() => _doNotPerform = value),
                      ),
                      Text('editMedicationRequestPage.no'.tr(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _statusReasonController,
                    decoration: InputDecoration(
                      labelText: 'editMedicationRequestPage.statusReason'.tr(
                        context,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _numberOfRepeatsController,
                    decoration: InputDecoration(
                      labelText:
                          'editMedicationRequestPage.numberOfRepeatsAllowed'.tr(
                            context,
                          ),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'editMedicationRequestPage.notes'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
                        'editMedicationRequestPage.updateMedicationRequest'.tr(
                          context,
                        ),
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
