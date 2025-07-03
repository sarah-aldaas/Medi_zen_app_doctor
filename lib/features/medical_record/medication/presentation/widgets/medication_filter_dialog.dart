import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../data/models/medication_filter_model.dart';

class MedicationFilterDialog extends StatefulWidget {
  final MedicationFilterModel currentFilter;

  const MedicationFilterDialog({required this.currentFilter, super.key});

  @override
  _MedicationFilterDialogState createState() => _MedicationFilterDialogState();
}

class _MedicationFilterDialogState extends State<MedicationFilterDialog> {
  late MedicationFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _medicationRequestIdController = TextEditingController();

  // Form values
  String? _searchQuery;
  String? _selectedStatusId;
  String? _selectedDoseForm;
  String? _selectedRouteId;
  String? _selectedSiteId;
  bool? _asNeeded;
  String? _medicationRequestId;
  DateTime? _startFrom;
  DateTime? _endUntil;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchQuery = _filter.searchQuery;
    _selectedStatusId = _filter.statusId;
    _selectedDoseForm = _filter.doseForm;
    _selectedRouteId = _filter.routeId;
    _selectedSiteId = _filter.siteId;
    _asNeeded = _filter.asNeeded;
    _medicationRequestId = _filter.medicationRequestId;
    _startFrom = _filter.startFrom;
    _endUntil = _filter.endUntil;

    _searchController.text = _searchQuery ?? '';
    _medicationRequestIdController.text = _medicationRequestId ?? '';

    // Load code types
    context.read<CodeTypesCubit>().getMedicationStatusTypeCodes(context: context);
    context.read<CodeTypesCubit>().getMedicationDoseFormTypeCodes(context: context);
    context.read<CodeTypesCubit>().getMedicationRouteTypeCodes(context: context);
    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _medicationRequestIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startFrom ?? DateTime.now() : _endUntil ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startFrom = picked;
        } else {
          _endUntil = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: 400, maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("filterMedications.title".tr(context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Query
                    Text("filterMedications.search".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "filterMedications.searchHint".tr(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      ),
                      onChanged: (value) => _searchQuery = value,
                    ),
                    const SizedBox(height: 20),

                    // Status
                    Text("filterMedications.status".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> statusTypes = [];
                        if (state is CodeTypesSuccess) {
                          statusTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_status').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text("filterMedications.allStatuses".tr(context)),
                              value: null,
                              groupValue: _selectedStatusId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) => setState(() => _selectedStatusId = value),
                            ),
                            ...statusTypes.map(
                              (type) => RadioListTile<String>(
                                title: Text(type.display, style: const TextStyle(fontSize: 14)),
                                value: type.id,
                                groupValue: _selectedStatusId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) => setState(() => _selectedStatusId = value),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dose Form
                    Text("filterMedications.doseForm".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> doseForms = [];
                        if (state is CodeTypesSuccess) {
                          doseForms = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_dose_form').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          hint: Text("filterMedications.selectDoseForm".tr(context)),
                          value: _selectedDoseForm,
                          items: [
                            DropdownMenuItem<String>(value: null, child: Text("filterMedications.allDoseForms".tr(context))),
                            ...doseForms.map((type) => DropdownMenuItem<String>(value: type.id, child: Text(type.display))),
                          ],
                          onChanged: (value) => setState(() => _selectedDoseForm = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Route
                    Text("filterMedications.route".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> routes = [];
                        if (state is CodeTypesSuccess) {
                          routes = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_route').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          hint: Text("filterMedications.selectRoute".tr(context)),
                          value: _selectedRouteId,
                          items: [
                            DropdownMenuItem<String>(value: null, child: Text("filterMedications.allRoutes".tr(context))),
                            ...routes.map((type) => DropdownMenuItem<String>(value: type.id, child: Text(type.display))),
                          ],
                          onChanged: (value) => setState(() => _selectedRouteId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Site
                    Text("filterMedications.site".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> sites = [];
                        if (state is CodeTypesSuccess) {
                          sites = state.codes?.where((code) => code.codeTypeModel?.name == 'body_site').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          hint: Text("filterMedications.selectSite".tr(context)),
                          value: _selectedSiteId,
                          items: [
                            DropdownMenuItem<String>(value: null, child: Text("filterMedications.allSites".tr(context))),
                            ...sites.map((type) => DropdownMenuItem<String>(value: type.id, child: Text(type.display))),
                          ],
                          onChanged: (value) => setState(() => _selectedSiteId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // As Needed
                    Text("filterMedications.asNeeded".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text("filterMedications.asNeededLabel".tr(context)),
                      value: _asNeeded ?? false,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => setState(() => _asNeeded = value),
                    ),
                    const SizedBox(height: 20),

                    // Medication Request ID
                    Text("filterMedications.medicationRequestId".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _medicationRequestIdController,
                      decoration: InputDecoration(
                        hintText: "filterMedications.enterMedicationRequestId".tr(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: Icon(Icons.medication, color: Theme.of(context).primaryColor),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => _medicationRequestId = value,
                    ),
                    const SizedBox(height: 20),

                    // Date Range
                    Text("filterMedications.dateRange".tr(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "filterMedications.startFrom".tr(context),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(_startFrom != null ? DateFormat('yyyy-MM-dd').format(_startFrom!) : "filterMedications.selectDate".tr(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "filterMedications.endUntil".tr(context),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(_endUntil != null ? DateFormat('yyyy-MM-dd').format(_endUntil!) : "filterMedications.selectDate".tr(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              () => setState(() {
                                _searchQuery = null;
                                _selectedStatusId = null;
                                _selectedDoseForm = null;
                                _selectedRouteId = null;
                                _selectedSiteId = null;
                                _asNeeded = null;
                                _medicationRequestId = null;
                                _startFrom = null;
                                _endUntil = null;
                                _searchController.clear();
                                _medicationRequestIdController.clear();
                              }),
                          child: Text("filterMedications.clearFilters".tr(context), style: const TextStyle(color: Colors.red)),
                        ),
                        Row(
                          children: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text("filterMedications.cancel".tr(context))),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Validate date range
                                if (_startFrom != null && _endUntil != null && _startFrom!.isAfter(_endUntil!)) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(SnackBar(content: Text("filterMedications.invalidDateRange".tr(context)), backgroundColor: Colors.red));
                                  return;
                                }

                                Navigator.pop(
                                  context,
                                  MedicationFilterModel(
                                    searchQuery: _searchQuery,
                                    statusId: _selectedStatusId,
                                    doseForm: _selectedDoseForm,
                                    routeId: _selectedRouteId,
                                    siteId: _selectedSiteId,
                                    asNeeded: _asNeeded,
                                    medicationRequestId: _medicationRequestId,
                                    startFrom: _startFrom,
                                    endUntil: _endUntil,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text("filterMedications.apply".tr(context)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
