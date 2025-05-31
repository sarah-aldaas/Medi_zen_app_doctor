import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  State<CreateEditEncounterPage> createState() => _CreateEditEncounterPageState();
}

class _CreateEditEncounterPageState extends State<CreateEditEncounterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _specialArrangementController = TextEditingController();
  String? _selectedTypeId;
  String? _selectedStatusId;
  String? _selectedAppointmentId;
  DateTime? _actualStartDate;
  DateTime? _actualEndDate;
  List<CodeModel> types = [];
  List<CodeModel> statuses = [];
  List<AppointmentModel> appointments = [];

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getEncounterTypeCodes();
    context.read<CodeTypesCubit>().getEncounterStatusCodes();
    context.read<AppointmentCubit>().getPatientAppointments(patientId: widget.patientId);

    if (widget.encounter != null) {
      _reasonController.text = widget.encounter!.reason ?? '';
      _specialArrangementController.text = widget.encounter!.specialArrangement ?? '';
      _selectedTypeId = widget.encounter!.type?.id;
      _selectedStatusId = widget.encounter!.status?.id;
      _selectedAppointmentId = widget.encounter!.appointment?.id;
      _actualStartDate = widget.encounter!.actualStartDate != null
          ? DateTime.tryParse(widget.encounter!.actualStartDate!)
          : null;
      _actualEndDate = widget.encounter!.actualEndDate != null
          ? DateTime.tryParse(widget.encounter!.actualEndDate!)
          : null;
    } else if (widget.appointmentId != null) {
      _selectedAppointmentId = widget.appointmentId.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.encounter == null ? 'Create Encounter' : 'Edit Encounter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<EncounterCubit, EncounterState>(
        listener: (context, state) {
          if (state is EncounterActionSuccess) {
            ShowToast.showToastSuccess(
                message: widget.encounter == null ? 'Encounter created successfully' : 'Encounter updated successfully');
            context.pop();
          } else if (state is EncounterError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, codeState) {
            return BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, appointmentState) {
                if (codeState is CodesLoading || appointmentState is AppointmentLoading) {
                  return const Center(child: LoadingPage());
                }

                if (codeState is CodeTypesSuccess) {
                  types = codeState.codes?.where((code) => code.codeTypeModel?.name == 'encounter_type').toList() ?? [];
                  statuses =
                      codeState.codes?.where((code) => code.codeTypeModel?.name == 'encounter_status').toList() ?? [];
                }

                if (appointmentState is AppointmentListSuccess) {
                  appointments = appointmentState.paginatedResponse.paginatedData!.items;
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? 'Reason is required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Appointment',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedAppointmentId,
                            items: appointments.map((appointment) {
                              return DropdownMenuItem<String>(
                                value: appointment.id,
                                child: Text(appointment.reason ?? 'No reason'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAppointmentId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return 'Appointment is required';
                              if (appointments.firstWhereOrNull((app) => app.id == value) == null) {
                                return 'Selected appointment is invalid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedTypeId,
                            items: types.map((type) {
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
                            validator: (value) => value == null ? 'Type is required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedStatusId,
                            items: statuses.map((status) {
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
                            validator: (value) => value == null ? 'Status is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _specialArrangementController,
                            decoration: const InputDecoration(
                              labelText: 'Special Arrangement',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _actualStartDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _actualStartDate = date;
                                      });
                                    }
                                  },
                                  child: Text(_actualStartDate != null
                                      ? _actualStartDate!.toString().split(' ')[0]
                                      : 'Select Start Date'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: _actualEndDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _actualEndDate = date;
                                      });
                                    }
                                  },
                                  child: Text(_actualEndDate != null
                                      ? _actualEndDate!.toString().split(' ')[0]
                                      : 'Select End Date'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                AppointmentModel? appointment = appointments.firstWhereOrNull((app) => app.id == _selectedAppointmentId);
                                if (appointment == null) {
                                  ShowToast.showToastError(message: 'Invalid appointment selected');
                                  return;
                                }

                                final encounter = EncounterModel(
                                  id: widget.encounter?.id,
                                  reason: _reasonController.text,
                                  actualStartDate: _actualStartDate?.toIso8601String(),
                                  actualEndDate: _actualEndDate?.toIso8601String(),
                                  specialArrangement: _specialArrangementController.text.isNotEmpty
                                      ? _specialArrangementController.text
                                      : null,
                                  appointment: appointment,
                                  type: types.firstWhere((type) => type.id == _selectedTypeId),
                                  status: statuses.firstWhere((status) => status.id == _selectedStatusId),
                                  healthCareServices: widget.encounter?.healthCareServices ?? [],
                                );

                                if (widget.encounter == null) {
                                  context.read<EncounterCubit>().createEncounter(
                                    patientId: widget.patientId,
                                    encounter: encounter,
                                  );
                                } else {
                                  context.read<EncounterCubit>().updateEncounter(
                                    patientId: widget.patientId,
                                    encounterId: widget.encounterId!,
                                    encounter: encounter,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            ),
                            child: Text(widget.encounter == null ? 'Create' : 'Update'),
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

  @override
  void dispose() {
    _reasonController.dispose();
    _specialArrangementController.dispose();
    super.dispose();
  }
}