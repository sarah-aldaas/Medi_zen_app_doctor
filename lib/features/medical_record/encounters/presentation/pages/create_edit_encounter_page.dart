import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../../../appointment/data/models/appointment_model.dart';
import '../../../../appointment/presentation/cubit/appointment_cubit/appointment_cubit.dart';
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
  String? _selectedAppointmentId;
  DateTime? _actualStartDate;
  DateTime? _actualEndDate;

  List<CodeModel> _types = [];
  List<CodeModel> _statuses = [];
  List<AppointmentModel> _appointments = [];

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.encounter != null;

    context.read<CodeTypesCubit>().getEncounterTypeCodes();
    context.read<CodeTypesCubit>().getEncounterStatusCodes();
    context.read<AppointmentCubit>().getPatientAppointments(
      patientId: widget.patientId,
    );

    if (_isEditMode) {
      _reasonController.text = widget.encounter!.reason ?? '';
      _specialArrangementController.text =
          widget.encounter!.specialArrangement ?? '';
      _selectedTypeId = widget.encounter!.type?.id;
      _selectedStatusId = widget.encounter!.status?.id;
      _selectedAppointmentId = widget.encounter!.appointment?.id;
      _actualStartDate =
      widget.encounter!.actualStartDate != null
          ? DateTime.tryParse(widget.encounter!.actualStartDate!)
          : null;
      _actualEndDate =
      widget.encounter!.actualEndDate != null
          ? DateTime.tryParse(widget.encounter!.actualEndDate!)
          : null;
    } else if (widget.appointmentId != null) {
      _selectedAppointmentId = widget.appointmentId.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        centerTitle: false,
        title: Text(
          _isEditMode ? 'Edit Encounter' : 'Create Encounter',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
      ),
      body: BlocListener<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterActionSuccess) {
            ShowToast.showToastSuccess(
              message:
              _isEditMode
                  ? 'Encounter updated successfully!'
                  : 'Encounter created successfully!',
            );
            context.pop();
          } else if (state is EncounterError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, codeState) {
            return BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, appointmentState) {
                if (codeState is CodesLoading ||
                    appointmentState is AppointmentLoading) {
                  return const Center(child: LoadingPage());
                }

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

                if (appointmentState is AppointmentListSuccess) {
                  _appointments =
                      appointmentState.paginatedResponse.paginatedData!.items;
                }

                if (codeState is CodeTypesError) {
                  return _buildErrorState(
                    codeState.error,
                    textTheme,
                    primaryColor,
                  );
                }
                if (appointmentState is AppointmentError) {
                  return _buildErrorState(
                    appointmentState.error,
                    textTheme,
                    primaryColor,
                  );
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
                            'Basic Information',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(20),
                          _buildTextField(
                            controller: _reasonController,
                            labelText: 'Reason for Encounter',
                            hintText: 'e.g., Follow-up visit, New diagnosis',
                            validator:
                                (value) =>
                            value!.isEmpty
                                ? 'Reason is required'
                                : null,
                            keyboardType: TextInputType.text,
                          ),
                          const Gap(20),
                          _buildDropdownField<String>(
                            value: _selectedAppointmentId,
                            labelText: 'Associated Appointment',
                            hintText: 'Select an appointment',
                            items:
                            _appointments.map((appointment) {
                              return DropdownMenuItem<String>(
                                value: appointment.id,
                                child: Text(
                                  appointment.reason ??
                                      'No reason provided',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAppointmentId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null)
                                return 'Appointment is required';
                              if (_appointments.firstWhereOrNull(
                                    (app) => app.id == value,
                              ) ==
                                  null) {
                                return 'Selected appointment is invalid';
                              }
                              return null;
                            },
                            enabled: widget.appointmentId == null,
                          ),
                          const Gap(20),
                          _buildDropdownField<String>(
                            value: _selectedTypeId,
                            labelText: 'Encounter Type',
                            hintText: 'Select type of encounter',
                            items:
                            _types.map((type) {
                              return DropdownMenuItem<String>(
                                value: type.id,
                                child: Text(type.display),
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
                                ? 'Encounter type is required'
                                : null,
                          ),
                          const Gap(20),
                          _buildDropdownField<String>(
                            value: _selectedStatusId,
                            labelText: 'Encounter Status',
                            hintText: 'Select current status',
                            items:
                            _statuses.map((status) {
                              return DropdownMenuItem<String>(
                                value: status.id,
                                child: Text(status.display),
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
                                ? 'Encounter status is required'
                                : null,
                          ),
                          const Gap(28),

                          Text(
                            'Time & Special Arrangements',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(20),
                          _buildDateTimePicker(
                            context: context,
                            label: 'Actual Start Date & Time',
                            selectedDateTime: _actualStartDate,
                            onDateTimeChanged: (dateTime) {
                              setState(() {
                                _actualStartDate = dateTime;
                              });
                            },
                            validator:
                                (value) =>
                            value == null
                                ? 'Start date is required'
                                : null,
                          ),
                          const Gap(20),
                          _buildDateTimePicker(
                            context: context,
                            label: 'Actual End Date & Time',
                            selectedDateTime: _actualEndDate,
                            onDateTimeChanged: (dateTime) {
                              setState(() {
                                _actualEndDate = dateTime;
                              });
                            },
                            validator: (value) {
                              if (value == null) return 'End date is required';
                              if (_actualStartDate != null &&
                                  value.isBefore(_actualStartDate!)) {
                                return 'End date cannot be before start date';
                              }
                              return null;
                            },
                          ),
                          const Gap(20),
                          _buildTextField(
                            controller: _specialArrangementController,
                            labelText: 'Special Arrangement',
                            hintText:
                            'e.g., Wheelchair access needed, specific equipment',
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                          ),
                          const Gap(36),

                          ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _submitForm();
                              }
                            },

                            label: Text(
                              _isEditMode
                                  ? 'Update Encounter'
                                  : 'Create Encounter',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      menuMaxHeight: 300,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required DateTime? selectedDateTime,
    required ValueChanged<DateTime?> onDateTimeChanged,
    String? Function(DateTime?)? validator,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
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
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(primary: primaryColor),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
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
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: Icon(
                Icons.calendar_month_outlined,
                color: primaryColor,
              ),
              errorText: validator?.call(selectedDateTime),
            ),
            child: Text(
              selectedDateTime != null
                  ? DateFormat(
                'EEE, MMM d, yyyy - hh:mm a',
              ).format(selectedDateTime)
                  : 'Tap to select date and time',
              style: textTheme.bodyLarge?.copyWith(
                color:
                selectedDateTime == null
                    ? Colors.grey.shade600
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return; // Form is not valid
    }

    final selectedAppointment = _appointments.firstWhereOrNull(
          (app) => app.id == _selectedAppointmentId,
    );
    if (selectedAppointment == null) {
      ShowToast.showToastError(
        message: 'Invalid appointment selected. Please choose from the list.',
      );
      return;
    }

    final encounter = EncounterModel(
      id: widget.encounter?.id,
      reason: _reasonController.text.trim(),
      actualStartDate: _actualStartDate?.toIso8601String(),
      actualEndDate: _actualEndDate?.toIso8601String(),
      specialArrangement:
      _specialArrangementController.text.trim().isNotEmpty
          ? _specialArrangementController.text.trim()
          : null,
      appointment: selectedAppointment,
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
        appointmentId: '',
      );
    }
  }

  Widget _buildErrorState(
      String errorMessage,
      TextTheme textTheme,
      Color primaryColor,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const Gap(20),
            Text(
              'Failed to load necessary data.',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              errorMessage,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(30),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CodeTypesCubit>().getEncounterTypeCodes();
                context.read<CodeTypesCubit>().getEncounterStatusCodes();
                context.read<AppointmentCubit>().getPatientAppointments(
                  patientId: widget.patientId,
                );
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
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