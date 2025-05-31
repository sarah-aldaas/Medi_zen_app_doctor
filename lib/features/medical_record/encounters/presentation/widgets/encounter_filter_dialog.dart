import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';

import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/encounter_filter_model.dart';

class EncounterFilterDialog extends StatefulWidget {
  final EncounterFilterModel currentFilter;

  const EncounterFilterDialog({super.key, required this.currentFilter});

  @override
  _EncounterFilterDialogState createState() => _EncounterFilterDialogState();
}

class _EncounterFilterDialogState extends State<EncounterFilterDialog> {
  late EncounterFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _appointmentIdController = TextEditingController();
  String? _selectedTypeId;
  String? _selectedStatusId;
  DateTime? _minStartDate;
  DateTime? _maxStartDate;

  List<CodeModel> types = [];
  List<CodeModel> statuses = [];

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getEncounterTypeCodes();
    context.read<CodeTypesCubit>().getEncounterStatusCodes();
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _appointmentIdController.text = _filter.appointmentId?.toString() ?? '';
    _selectedTypeId = _filter.typeId?.toString();
    _selectedStatusId = _filter.statusId?.toString();
    _minStartDate = _filter.minStartDate;
    _maxStartDate = _filter.maxStartDate;
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
                const Text("Filter Encounters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        hintText: 'Search encounters...',
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
                    const Text("Appointment ID", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextFormField(
                      controller: _appointmentIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Appointment ID',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(appointmentId: value.isNotEmpty ? int.tryParse(value) : null);
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
                          types = state.codes?.where((code) => code.codeTypeModel?.name == 'encounter_type').toList() ?? [];
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
                          statuses = state.codes?.where((code) => code.codeTypeModel?.name == 'encounter_status').toList() ?? [];
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
                      _filter = EncounterFilterModel();
                      _searchController.clear();
                      _appointmentIdController.clear();
                      _selectedTypeId = null;
                      _selectedStatusId = null;
                      _minStartDate = null;
                      _maxStartDate = null;
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
    _appointmentIdController.dispose();
    super.dispose();
  }
}