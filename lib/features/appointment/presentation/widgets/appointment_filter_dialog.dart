import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import '../../../../base/data/models/code_type_model.dart';
import '../../data/models/appointment_filter_model.dart';

class AppointmentFilterDialog extends StatefulWidget {
  final AppointmentFilterModel currentFilter;

  const AppointmentFilterDialog({super.key, required this.currentFilter});

  @override
  _AppointmentFilterDialogState createState() => _AppointmentFilterDialogState();
}

class _AppointmentFilterDialogState extends State<AppointmentFilterDialog> {
  late AppointmentFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _clinicIdController = TextEditingController();
  String? _selectedTypeId;
  String? _selectedStatusId;
  String? _selectedSort;
  DateTime? _minStartDate;
  DateTime? _maxStartDate;
  DateTime? _minEndDate;
  DateTime? _maxEndDate;
  DateTime? _minCancellationDate;
  DateTime? _maxCancellationDate;
  int? _createdByPractitioner;

  List<CodeModel> types = [];
  List<CodeModel> statuses = [];

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getAppointmentTypeCodes();
    context.read<CodeTypesCubit>().getAppointmentStatusCodes();
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _doctorIdController.text = _filter.doctorId?.toString() ?? '';
    _patientIdController.text = _filter.patientId?.toString() ?? '';
    _clinicIdController.text = _filter.clinicId?.toString() ?? '';
    _selectedTypeId = _filter.typeId?.toString();
    _selectedStatusId = _filter.statusId?.toString();
    _selectedSort = _filter.sort;
    _minStartDate = _filter.minStartDate;
    _maxStartDate = _filter.maxStartDate;
    _minEndDate = _filter.minEndDate;
    _maxEndDate = _filter.maxEndDate;
    _minCancellationDate = _filter.minCancellationDate;
    _maxCancellationDate = _filter.maxCancellationDate;
    _createdByPractitioner = _filter.createdByPractitioner;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: context.width,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Search", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search appointments...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _filter = _filter.copyWith(searchQuery: null);
                            });
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value.isNotEmpty ? value : null);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Doctor ID", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextFormField(
                      controller: _doctorIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Doctor ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(doctorId: value.isNotEmpty ? int.tryParse(value) : null);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Patient ID", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextFormField(
                      controller: _patientIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter patient ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(patientId: value.isNotEmpty ? int.tryParse(value) : null);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Clinic ID", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextFormField(
                      controller: _clinicIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter clinic ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(clinicId: value.isNotEmpty ? int.tryParse(value) : null);
                        });
                      },
                    ),
                    const Divider(),
                    const Text("Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (state is CodesError) {
                          return Text("Error loading types: ${state.error}");
                        }
                        if (state is CodeTypesSuccess) {
                          types = state.codes?.where((code) => code.codeTypeModel?.name == 'appointment_type').toList() ?? [];
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Types"),
                              value: null,
                              groupValue: _selectedTypeId,
                              activeColor: Colors.blue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedTypeId = value;
                                  _filter = _filter.copyWith(typeId: null);
                                });
                              },
                            ),
                            ...types.map((type) => RadioListTile<String>(
                              title: Text(type.display, style: const TextStyle(fontSize: 14)),
                              value: type.id,
                              groupValue: _selectedTypeId,
                              activeColor: Colors.blue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedTypeId = value;
                                  _filter = _filter.copyWith(typeId: value != null ? int.parse(value) : null);
                                });
                              },
                            )).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    const Text("Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (state is CodesError) {
                          return Text("Error loading statuses: ${state.error}");
                        }
                        if (state is CodeTypesSuccess) {
                          statuses = state.codes?.where((code) => code.codeTypeModel?.name == 'appointment_status').toList() ?? [];
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Statuses"),
                              value: null,
                              groupValue: _selectedStatusId,
                              activeColor: Colors.blue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedStatusId = value;
                                  _filter = _filter.copyWith(statusId: null);
                                });
                              },
                            ),
                            ...statuses.map((status) => RadioListTile<String>(
                              title: Text(status.display, style: const TextStyle(fontSize: 14)),
                              value: status.id,
                              groupValue: _selectedStatusId,
                              activeColor: Colors.blue,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedStatusId = value;
                                  _filter = _filter.copyWith(statusId: value != null ? int.parse(value) : null);
                                });
                              },
                            )).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    const Text("Created By Practitioner", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SwitchListTile(
                      title: const Text("Created by Practitioner"),
                      value: _createdByPractitioner == 1,
                      activeColor: Colors.blue,
                      onChanged: (bool value) {
                        setState(() {
                          _createdByPractitioner = value ? 1 : null;
                          _filter = _filter.copyWith(createdByPractitioner: _createdByPractitioner);
                        });
                      },
                    ),
                    const Divider(),
                    const Text("Start Date Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _minStartDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _minStartDate = date;
                                  _filter = _filter.copyWith(minStartDate: date);
                                });
                              }
                            },
                            child: Text(_minStartDate != null ? _minStartDate!.toString().split(' ')[0] : 'Select Min Date'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _maxStartDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _maxStartDate = date;
                                  _filter = _filter.copyWith(maxStartDate: date);
                                });
                              }
                            },
                            child: Text(_maxStartDate != null ? _maxStartDate!.toString().split(' ')[0] : 'Select Max Date'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text("End Date Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _minEndDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _minEndDate = date;
                                  _filter = _filter.copyWith(minEndDate: date);
                                });
                              }
                            },
                            child: Text(_minEndDate != null ? _minEndDate!.toString().split(' ')[0] : 'Select Min Date'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _maxEndDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _maxEndDate = date;
                                  _filter = _filter.copyWith(maxEndDate: date);
                                });
                              }
                            },
                            child: Text(_maxEndDate != null ? _maxEndDate!.toString().split(' ')[0] : 'Select Max Date'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text("Cancellation Date Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _minCancellationDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _minCancellationDate = date;
                                  _filter = _filter.copyWith(minCancellationDate: date);
                                });
                              }
                            },
                            child: Text(_minCancellationDate != null ? _minCancellationDate!.toString().split(' ')[0] : 'Select Min Date'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _maxCancellationDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  _maxCancellationDate = date;
                                  _filter = _filter.copyWith(maxCancellationDate: date);
                                });
                              }
                            },
                            child: Text(_maxCancellationDate != null ? _maxCancellationDate!.toString().split(' ')[0] : 'Select Max Date'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text("Sort Order", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String?>(
                            title: const Text("Ascending"),
                            value: 'asc',
                            groupValue: _selectedSort,
                            activeColor: Colors.blue,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedSort = value;
                                _filter = _filter.copyWith(sort: value);
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String?>(
                            title: const Text("Descending"),
                            value: 'desc',
                            groupValue: _selectedSort,
                            activeColor: Colors.blue,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedSort = value;
                                _filter = _filter.copyWith(sort: value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = AppointmentFilterModel();
                      _searchController.clear();
                      _doctorIdController.clear();
                      _patientIdController.clear();
                      _clinicIdController.clear();
                      _selectedTypeId = null;
                      _selectedStatusId = null;
                      _selectedSort = null;
                      _minStartDate = null;
                      _maxStartDate = null;
                      _minEndDate = null;
                      _maxEndDate = null;
                      _minCancellationDate = null;
                      _maxCancellationDate = null;
                      _createdByPractitioner = null;
                    });
                  },
                  child: const Text("CLEAR", style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text("APPLY"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _doctorIdController.dispose();
    _patientIdController.dispose();
    _clinicIdController.dispose();
    super.dispose();
  }
}