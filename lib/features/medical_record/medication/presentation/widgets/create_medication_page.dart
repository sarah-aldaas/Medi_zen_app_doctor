import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../../medication_request/data/models/medication_request_model.dart';
import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';

class CreateMedicationPage extends StatefulWidget {
  final String patientId;
  final MedicationRequestModel? medicationRequest;
  final String? appointmentId;

  const CreateMedicationPage({
    super.key,
    required this.patientId,
    this.medicationRequest,
    this.appointmentId,
  });

  @override
  _CreateMedicationPageState createState() => _CreateMedicationPageState();
}

class _CreateMedicationPageState extends State<CreateMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _doseUnitController = TextEditingController();
  final _definitionController = TextEditingController();
  final _dosageInstructionsController = TextEditingController();
  final _additionalInstructionsController = TextEditingController();
  final _patientInstructionsController = TextEditingController();
  final _numeratorValueController = TextEditingController();
  final _numeratorUnitController = TextEditingController();
  final _denominatorValueController = TextEditingController();
  final _denominatorUnitController = TextEditingController();
  final _eventController = TextEditingController();
  final _whenController = TextEditingController();
  final _offsetController = TextEditingController();
  final _offsetUnitController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _asNeeded;
  String? _selectedDoseFormId;
  String? _selectedSiteId;
  String? _selectedRouteId;

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getMedicationDoseFormTypeCodes(context: context);
    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);
    context.read<CodeTypesCubit>().getMedicationRouteTypeCodes(context: context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _doseUnitController.dispose();
    _definitionController.dispose();
    _dosageInstructionsController.dispose();
    _additionalInstructionsController.dispose();
    _patientInstructionsController.dispose();
    _numeratorValueController.dispose();
    _numeratorUnitController.dispose();
    _denominatorValueController.dispose();
    _denominatorUnitController.dispose();
    _eventController.dispose();
    _whenController.dispose();
    _offsetController.dispose();
    _offsetUnitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final medication = MedicationModel(
        name: _nameController.text,
        dose: int.tryParse(_doseController.text),
        doseUnit: _doseUnitController.text.isNotEmpty ? _doseUnitController.text : null,
        effectiveMedicationStartDate: _startDate,
        effectiveMedicationEndDate: _endDate,
        definition: _definitionController.text.isNotEmpty ? _definitionController.text : null,
        dosageInstructions: _dosageInstructionsController.text.isNotEmpty ? _dosageInstructionsController.text : null,
        additionalInstructions: _additionalInstructionsController.text.isNotEmpty ? _additionalInstructionsController.text : null,
        patientInstructions: _patientInstructionsController.text.isNotEmpty ? _patientInstructionsController.text : null,
        asNeeded: _asNeeded,
        maxDosePerPeriod: _numeratorValueController.text.isNotEmpty && _denominatorValueController.text.isNotEmpty
            ? MaxDose(
          numerator: DoseComponent(
            value: int.parse(_numeratorValueController.text),
            unit: _numeratorUnitController.text,
          ),
          denominator: DoseComponent(
            value: int.parse(_denominatorValueController.text),
            unit: _denominatorUnitController.text,
          ),
        )
            : null,
        event: _eventController.text.isNotEmpty ? _eventController.text : null,
        when: _whenController.text.isNotEmpty ? _whenController.text : null,
        offset: int.tryParse(_offsetController.text),
        offsetUnit: _offsetUnitController.text.isNotEmpty ? _offsetUnitController.text : null,
        doseForm: _selectedDoseFormId != null ? CodeModel(id: _selectedDoseFormId!, code: '', display: '', description: '', codeTypeId: '') : null,
        site: _selectedSiteId != null ? CodeModel(id: _selectedSiteId!, code: '', display: '', description: '', codeTypeId: '') : null,
        route: _selectedRouteId != null ? CodeModel(id: _selectedRouteId!, code: '', display: '', description: '', codeTypeId: '') : null,
        medicationRequest: widget.medicationRequest,
      );

      context.read<MedicationCubit>().createMedication(
        medication: medication,
        patientId: widget.patientId,
        context: context,
      ).then((_) {
        if (context.read<MedicationCubit>().state is MedicationCreated) {
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
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('createMedication.select'.tr(context)),
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "createMedication.title".tr(context),
          style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is MedicationCreated) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is MedicationLoading) {
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.name'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'createMedication.nameRequired'.tr(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _doseController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.dose'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _doseUnitController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.doseUnit'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'createMedication.startDate'.tr(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                ListTile(
                  title: Text(
                    _startDate != null
                        ? DateFormat('MMM d, y').format(_startDate!)
                        : 'createMedication.selectStartDate'.tr(context),
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
                      setState(() => _startDate = date);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'createMedication.endDate'.tr(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                ListTile(
                  title: Text(
                    _endDate != null
                        ? DateFormat('MMM d, y').format(_endDate!)
                        : 'createMedication.selectEndDate'.tr(context),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _definitionController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.definition'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dosageInstructionsController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.dosageInstructions'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _additionalInstructionsController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.additionalInstructions'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _patientInstructionsController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.patientInstructions'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'createMedication.asNeeded'.tr(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool?>(
                        title: Text('createMedication.notSpecified'.tr(context)),
                        value: null,
                        groupValue: _asNeeded,
                        onChanged: (value) => setState(() => _asNeeded = value),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('createMedication.yes'.tr(context)),
                        value: true,
                        groupValue: _asNeeded,
                        onChanged: (value) => setState(() => _asNeeded = value),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('createMedication.no'.tr(context)),
                        value: false,
                        groupValue: _asNeeded,
                        onChanged: (value) => setState(() => _asNeeded = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'createMedication.maxDosePerPeriod'.tr(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextFormField(
                  controller: _numeratorValueController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.numeratorValue'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return 'createMedication.invalidNumber'.tr(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _numeratorUnitController,
                  decoration: InputDecoration(
                    labelText: 'createMedication.numeratorUnit'.tr(context),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _denominatorValueController,
                  decoration: InputDecoration(
                      labelText: 'createMedication.denominatorValue'.tr(context),
                      border:OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'createMedication.invalidNumber'.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _denominatorUnitController,
                decoration: InputDecoration(
                  labelText: 'createMedication.denominatorUnit'.tr(context),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _eventController,
                decoration: InputDecoration(
                  labelText: 'createMedication.event'.tr(context),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _whenController,
                decoration: InputDecoration(
                  labelText: 'createMedication.when'.tr(context),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _offsetController,
                decoration: InputDecoration(
                  labelText: 'createMedication.offset'.tr(context),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'createMedication.invalidNumber'.tr(context);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _offsetUnitController,
                decoration: InputDecoration(
                  labelText: 'createMedication.offsetUnit'.tr(context),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildCodeDropdown(
                title: 'createMedication.doseForm',
                value: _selectedDoseFormId,
                codeTypeName: 'medication_dose_form',
                onChanged: (value) => setState(() => _selectedDoseFormId = value),
              ),
              _buildCodeDropdown(
                title: 'createMedication.site',
                value: _selectedSiteId,
                codeTypeName: 'body_site',
                onChanged: (value) => setState(() => _selectedSiteId = value),
              ),
              _buildCodeDropdown(
                title: 'createMedication.route',
                value: _selectedRouteId,
                codeTypeName: 'medication_route',
                onChanged: (value) => setState(() => _selectedRouteId = value),
              ),
              const SizedBox(height: 20),
              if (widget.medicationRequest != null)
          Text(
            'createMedication.linkedRequest ${
              widget.medicationRequest!.reason ?? 'Unknown'
            }',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(double.infinity, 48),
          ),
          child: Text('createMedication.submit'.tr(context)),
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