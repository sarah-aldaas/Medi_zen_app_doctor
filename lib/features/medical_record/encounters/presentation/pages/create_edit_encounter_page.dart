import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../data/models/encounter_model.dart';
import '../cubit/encounter_cubit/encounter_cubit.dart';

class CreateEditEncounterPage extends StatefulWidget {
  final String patientId;
  final String? appointmentId;
  final String? encounterId;
  final EncounterModel? encounter;

  const CreateEditEncounterPage({
    super.key,
    required this.patientId,
    this.appointmentId,
    this.encounterId,
    this.encounter,
  });

  @override
  State<CreateEditEncounterPage> createState() =>
      _CreateEditEncounterPageState();
}

class _CreateEditEncounterPageState extends State<CreateEditEncounterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _specialArrangementController =
  TextEditingController();

  String? _selectedTypeId;
  String? _selectedStatusId;
  DateTime? _actualStartDate;
  DateTime? _actualEndDate;

  List<CodeModel> _types = [];
  List<CodeModel> _statuses = [];


  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.encounter != null;

    context.read<CodeTypesCubit>().getEncounterTypeCodes(context: context);
    context.read<CodeTypesCubit>().getEncounterStatusCodes(context: context);


    if (_isEditMode) {
      _reasonController.text = widget.encounter!.reason ?? '';
      _specialArrangementController.text =
          widget.encounter!.specialArrangement ?? '';
      _selectedTypeId = widget.encounter!.type?.id;
      _selectedStatusId = widget.encounter!.status?.id;
      _actualStartDate =
      widget.encounter!.actualStartDate != null
          ? DateTime.tryParse(widget.encounter!.actualStartDate!)
          : null;
      _actualEndDate =
      widget.encounter!.actualEndDate != null
          ? DateTime.tryParse(widget.encounter!.actualEndDate!)
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation ?? 1,
        centerTitle: theme.appBarTheme.centerTitle ?? false,
        title: Text(
          _isEditMode
              ? 'encounterPage.edit_encounter'.tr(context)
              : 'encounterPage.create_encounter'.tr(context),
          style:
          theme.appBarTheme.titleTextStyle ??
              textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.appBarTheme.foregroundColor ?? theme.primaryColor,
              ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.appBarTheme.iconTheme?.color,
          ),
          onPressed: () => context.pop(),
          tooltip: 'encounterPage.back_tooltip'.tr(context),
        ),
      ),
      body: BlocListener<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterActionSuccess) {
            ShowToast.showToastSuccess(
              message:
              _isEditMode
                  ? 'encounterPage.encounter_updated_success'.tr(context)
                  : 'encounterPage.encounter_created_success'.tr(context),
            );
            context.pop();
          } else if (state is EncounterError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, codeState) {
            if (codeState is CodeTypesSuccess) {
              _types =
                  codeState.codes
                      ?.where(
                        (code) =>
                    code.codeTypeModel?.name == 'encounter_type',
                  )
                      .toList() ??
                      [];
              _statuses =
                  codeState.codes
                      ?.where(
                        (code) =>
                    code.codeTypeModel?.name == 'encounter_status',
                  )
                      .toList() ??
                      [];
            }


            if (codeState is CodeTypesError) {
              return _buildErrorState(codeState.error, theme);
            }


            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'encounterPage.basic_information'.tr(context),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                          textTheme.titleLarge?.color ??
                              (theme.brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.white),
                        ),
                      ),
                      const Gap(20),
                      _buildTextField(
                        controller: _reasonController,
                        labelText:
                        'encounterPage.reason_for_encounter_label'.tr(
                          context,
                        ),
                        hintText: 'encounterPage.reason_for_encounter_hint'
                            .tr(context),
                        validator:
                            (value) =>
                        value!.isEmpty
                            ? 'encounterPage.reason_required_error'
                            .tr(context)
                            : null,
                        keyboardType: TextInputType.text,
                      ),
                      const Gap(20),
                      _buildDropdownField<String>(
                        value: _selectedTypeId,
                        labelText: 'encounterPage.encounter_type_label'.tr(
                          context,
                        ),
                        hintText: 'encounterPage.select_encounter_type_hint'
                            .tr(context),
                        items:
                        _types.map((type) {
                          return DropdownMenuItem<String>(
                            value: type.id,
                            child: Text(
                              type.display,
                              style: textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTypeId = value;
                          });
                        },
                        validator:
                            (value) =>
                        value == null
                            ? 'encounterPage.encounter_type_required_error'
                            .tr(context)
                            : null,
                      ),
                      const Gap(20),
                      _buildDropdownField<String>(
                        value: _selectedStatusId,
                        labelText: 'encounterPage.encounter_status_label'
                            .tr(context),
                        hintText: 'encounterPage.select_current_status_hint'
                            .tr(context),
                        items:
                        _statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status.id,
                            child: Text(
                              status.display,
                              style: textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatusId = value;
                          });
                        },
                        validator:
                            (value) =>
                        value == null
                            ? 'encounterPage.encounter_status_required_error'
                            .tr(context)
                            : null,
                      ),
                      const Gap(28),

                      Text(
                        'encounterPage.time_special_arrangements'.tr(
                          context,
                        ),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                          textTheme.titleLarge?.color ??
                              (theme.brightness == Brightness.light
                                  ? Colors.black87
                                  : Colors.white),
                        ),
                      ),
                      const Gap(20),
                      _buildDateTimePicker(
                        context: context,
                        label: 'encounterPage.actual_start_date_time_label'
                            .tr(context),
                        selectedDateTime: _actualStartDate,
                        onDateTimeChanged: (dateTime) {
                          setState(() {
                            _actualStartDate = dateTime;
                          });
                        },
                        validator:
                            (value) =>
                        value == null
                            ? 'encounterPage.start_date_required_error'
                            .tr(context)
                            : null,
                      ),
                      const Gap(20),
                      _buildDateTimePicker(
                        context: context,
                        label: 'encounterPage.actual_end_date_time_label'
                            .tr(context),
                        selectedDateTime: _actualEndDate,
                        onDateTimeChanged: (dateTime) {
                          setState(() {
                            _actualEndDate = dateTime;
                          });
                        },
                        validator: (value) {
                          if (value == null)
                            return 'encounterPage.end_date_required_error'
                                .tr(context);
                          if (_actualStartDate != null &&
                              value.isBefore(_actualStartDate!)) {
                            return 'encounterPage.end_date_before_start_error'
                                .tr(context);
                          }
                          return null;
                        },
                      ),
                      const Gap(20),
                      _buildTextField(
                        controller: _specialArrangementController,
                        labelText: 'encounterPage.special_arrangement_label'
                            .tr(context),
                        hintText: 'encounterPage.special_arrangement_hint'
                            .tr(context),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const Gap(36),

                      BlocBuilder<EncounterCubit, EncounterState>(
                        builder: (context, state) {
                          if(state is EncounterLoading){
                            return LoadingButton();
                          }
                          return ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _submitForm();
                              }
                            },
                            icon: Icon(
                              _isEditMode ? Icons.save : Icons.add,
                              color:
                              theme.buttonTheme.textTheme ==
                                  ButtonTextTheme.primary
                                  ? (theme.brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.black)
                                  : theme.textTheme.labelLarge?.color,
                            ),
                            label: Text(
                              _isEditMode
                                  ? 'encounterPage.update_encounter_button'.tr(
                                context,
                              )
                                  : 'encounterPage.create_encounter_button'.tr(
                                context,
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                theme.buttonTheme.textTheme ==
                                    ButtonTextTheme.primary
                                    ? (theme.brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black)
                                    : theme.textTheme.labelLarge?.color,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: theme.buttonTheme.height,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ).applyDefaults(theme.inputDecorationTheme),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String labelText,
    String? hintText,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ).applyDefaults(theme.inputDecorationTheme),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      menuMaxHeight: 300,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.iconTheme.color,
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.textTheme.bodyMedium?.color,
      ),
      dropdownColor: theme.cardTheme.color,
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required DateTime? selectedDateTime,
    required ValueChanged<DateTime?> onDateTimeChanged,
    String? Function(DateTime?)? validator,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textTheme.bodyMedium?.color,
          ),
        ),
        const Gap(12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: theme.primaryColor,
                      onPrimary:
                      theme.brightness == Brightness.light
                          ? Colors.white
                          : Colors.black,
                      surface: theme.scaffoldBackgroundColor,
                      onSurface: textTheme.bodyMedium?.color,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(
                  selectedDateTime ?? DateTime.now(),
                ),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      colorScheme: theme.colorScheme.copyWith(
                        primary: theme.primaryColor,
                        onPrimary:
                        theme.brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                        surface: theme.scaffoldBackgroundColor,
                        onSurface: textTheme.bodyMedium?.color,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                onDateTimeChanged(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  ),
                );
              } else {
                onDateTimeChanged(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    selectedDateTime?.hour ?? 0,
                    selectedDateTime?.minute ?? 0,
                  ),
                );
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: theme.iconTheme.color,
              ),
              errorText: validator?.call(selectedDateTime),
            ).applyDefaults(theme.inputDecorationTheme),
            child: Text(
              selectedDateTime != null
                  ? DateFormat('EEE, MMM d, HH:mm a').format(
                selectedDateTime,
              )
                  : 'encounterPage.tap_to_select_date_time'.tr(context),
              style: textTheme.bodyLarge?.copyWith(
                color:
                selectedDateTime == null
                    ? theme.inputDecorationTheme.hintStyle?.color
                    : textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final encounter = EncounterModel(
      reason: _reasonController.text.trim(),
      actualStartDate: _actualStartDate?.toIso8601String(),
      actualEndDate: _actualEndDate?.toIso8601String(),
      specialArrangement:
      _specialArrangementController.text
          .trim()
          .isNotEmpty
          ? _specialArrangementController.text.trim()
          : null,
      type: _types.firstWhere((type) => type.id == _selectedTypeId),
      status: _statuses.firstWhere((status) => status.id == _selectedStatusId),
      healthCareServices: widget.encounter?.healthCareServices ?? [],
    );

    if (_isEditMode) {
      context.read<EncounterCubit>().updateEncounter(
        patientId: widget.patientId,
        encounterId: widget.encounterId!,
        encounter: encounter,
      );
    } else {
      context.read<EncounterCubit>().createEncounter(
        patientId: widget.patientId,
        encounter: encounter,
        appointmentId: widget.appointmentId!,
      );
    }
  }

  Widget _buildErrorState(String errorMessage, ThemeData theme) {
    final textTheme = theme.textTheme;
    final primaryColor = theme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: theme.colorScheme.error),
            const Gap(20),
            Text(
              'encounterPage.failed_to_load_data_title'.tr(context),
              style: textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              errorMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(30),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CodeTypesCubit>().getEncounterTypeCodes(context: context);
                context.read<CodeTypesCubit>().getEncounterStatusCodes(context: context);
              },
              icon: Icon(
                Icons.refresh,
                color:
                theme.buttonTheme.textTheme == ButtonTextTheme.primary
                    ? Colors.white
                    : textTheme.labelLarge?.color,
              ),
              label: Text(
                'encounterPage.retry_button'.tr(context),
                style: theme.textTheme.labelLarge?.copyWith(
                  color:
                  theme.buttonTheme.textTheme == ButtonTextTheme.primary
                      ? Colors.white
                      : textTheme.labelLarge?.color,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: theme.buttonTheme.height,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _specialArrangementController.dispose();
    super.dispose();
  }
}
