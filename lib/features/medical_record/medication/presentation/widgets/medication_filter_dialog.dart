import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../medication_request/data/models/medication_request_model.dart';
import '../../../medication_request/presentation/cubit/medication_request_cubit/medication_request_cubit.dart';
import '../../data/models/medication_filter_model.dart';

class MedicationFilterDialog extends StatefulWidget {
  final MedicationFilterModel currentFilter;
  final String patientId;

  const MedicationFilterDialog({
    required this.currentFilter,
    required this.patientId,
    super.key,
  });

  @override
  _MedicationFilterDialogState createState() => _MedicationFilterDialogState();
}

class _MedicationFilterDialogState extends State<MedicationFilterDialog> {
  late MedicationFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _medicationRequestIdController =
      TextEditingController();

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

    context.read<CodeTypesCubit>().getMedicationStatusTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getMedicationDoseFormTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getMedicationRouteTypeCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);

    context.read<MedicationRequestCubit>().getAllMedicationRequests(
      patientId: widget.patientId,
      context: context,
    );
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
      initialDate:
          isStartDate
              ? _startFrom ?? DateTime.now()
              : _endUntil ?? DateTime.now(),
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

  Future<void> _showMedicationRequestSelectionDialog(
    BuildContext context,
  ) async {
    final cubit = context.read<MedicationRequestCubit>();
    final state = cubit.state;

    if (state is! MedicationRequestSuccess) {
      await cubit.getAllMedicationRequests(
        patientId: widget.patientId,
        context: context,
      );
    }

    final medicationRequests =
        (state is MedicationRequestSuccess)
            ? state.paginatedResponse.paginatedData!.items
            : <MedicationRequestModel>[];

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "medicationFilterDialog.selectMedicationRequest".tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      medicationRequests.isEmpty
                          ? Center(
                            child: Text(
                              "medicationFilterDialog.noMedicationRequestsAvailable"
                                  .tr(context),
                            ),
                          )
                          : ListView.builder(
                            itemCount: medicationRequests.length,
                            itemBuilder: (context, index) {
                              final request = medicationRequests[index];
                              return ListTile(
                                title: Text(request.reason ?? ''),
                                subtitle: Text('${request.priority?.display}'),
                                onTap: () {
                                  setState(() {
                                    _medicationRequestId = request.id;
                                    _medicationRequestIdController.text =
                                        request.id ?? '';
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _medicationRequestId = null;
                      _medicationRequestIdController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "medicationFilterDialog.clearSelection".tr(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "medicationFilterDialog.filterMedications".tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
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
                    Text(
                      "medicationFilterDialog.search".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "medicationFilterDialog.searchHint".tr(
                          context,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onChanged: (value) => _searchQuery = value,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.status".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> statusTypes = [];
                        if (state is CodeTypesSuccess) {
                          statusTypes =
                              state.codes
                                  ?.where(
                                    (code) =>
                                        code.codeTypeModel?.name ==
                                        'medication_status',
                                  )
                                  .toList() ??
                              [];
                        }
                        if (state is CodeTypesLoading ||
                            state is CodesLoading ||
                            state is CodeTypesInitial) {
                          return  Center(
                            child: LoadingButton(),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                "medicationFilterDialog.allStatuses".tr(
                                  context,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedStatusId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged:
                                  (value) =>
                                      setState(() => _selectedStatusId = value),
                            ),
                            ...statusTypes.map(
                              (type) => RadioListTile<String>(
                                title: Text(
                                  type.display,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: type.id,
                                groupValue: _selectedStatusId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged:
                                    (value) => setState(
                                      () => _selectedStatusId = value,
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.doseForm".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> doseForms = [];
                        if (state is CodeTypesSuccess) {
                          doseForms =
                              state.codes
                                  ?.where(
                                    (code) =>
                                        code.codeTypeModel?.name ==
                                        'medication_dose_form',
                                  )
                                  .toList() ??
                              [];
                        }
                        if (state is CodeTypesLoading ||
                            state is CodesLoading ||
                            state is CodeTypesInitial) {
                          return  Center(
                            child: LoadingButton(),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text(
                            "medicationFilterDialog.selectDoseForm".tr(context),
                          ),
                          value: _selectedDoseForm,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                "medicationFilterDialog.allDoseForms".tr(
                                  context,
                                ),
                              ),
                            ),
                            ...doseForms.map(
                              (type) => DropdownMenuItem<String>(
                                value: type.id,
                                child: Text(type.display),
                              ),
                            ),
                          ],
                          onChanged:
                              (value) =>
                                  setState(() => _selectedDoseForm = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.route".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> routes = [];
                        if (state is CodeTypesSuccess) {
                          routes =
                              state.codes
                                  ?.where(
                                    (code) =>
                                        code.codeTypeModel?.name ==
                                        'medication_route',
                                  )
                                  .toList() ??
                              [];
                        }
                        if (state is CodeTypesLoading ||
                            state is CodesLoading ||
                            state is CodeTypesInitial) {
                          return  Center(
                            child: LoadingButton(),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text(
                            "medicationFilterDialog.selectRoute".tr(context),
                          ),
                          value: _selectedRouteId,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                "medicationFilterDialog.allRoutes".tr(context),
                              ),
                            ),
                            ...routes.map(
                              (type) => DropdownMenuItem<String>(
                                value: type.id,
                                child: Text(type.display),
                              ),
                            ),
                          ],
                          onChanged:
                              (value) =>
                                  setState(() => _selectedRouteId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.site".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> sites = [];
                        if (state is CodeTypesSuccess) {
                          sites =
                              state.codes
                                  ?.where(
                                    (code) =>
                                        code.codeTypeModel?.name == 'body_site',
                                  )
                                  .toList() ??
                              [];
                        }
                        if (state is CodeTypesLoading ||
                            state is CodesLoading ||
                            state is CodeTypesInitial) {
                          return  Center(
                            child: LoadingButton(),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text(
                            "medicationFilterDialog.selectSite".tr(context),
                          ),
                          value: _selectedSiteId,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                "medicationFilterDialog.allSites".tr(context),
                              ),
                            ),
                            ...sites.map(
                              (type) => DropdownMenuItem<String>(
                                value: type.id,
                                child: Text(type.display),
                              ),
                            ),
                          ],
                          onChanged:
                              (value) =>
                                  setState(() => _selectedSiteId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.asNeeded".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      children: [
                        RadioListTile<bool?>(
                          title: Text(
                            "medicationFilterDialog.notSpecified".tr(context),
                          ),
                          value: null,
                          groupValue: _asNeeded,
                          onChanged:
                              (value) => setState(() => _asNeeded = value),
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            "medicationFilterDialog.yes".tr(context),
                          ),
                          value: true,
                          groupValue: _asNeeded,
                          onChanged:
                              (value) => setState(() => _asNeeded = value),
                        ),
                        RadioListTile<bool>(
                          title: Text(
                            "medicationFilterDialog.no".tr(context),
                          ),
                          value: false,
                          groupValue: _asNeeded,
                          onChanged:
                              (value) => setState(() => _asNeeded = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.medicationRequest".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          () => _showMedicationRequestSelectionDialog(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _medicationRequestIdController,
                          decoration: InputDecoration(
                            labelText:
                                "medicationFilterDialog.selectMedicationRequest"
                                    .tr(context),
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.startFrom".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        _startFrom != null
                            ? DateFormat('MMM d, y').format(_startFrom!)
                            : "medicationFilterDialog.selectDate".tr(context),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "medicationFilterDialog.endUntil".tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        _endUntil != null
                            ? DateFormat('MMM d, y').format(_endUntil!)
                            : "medicationFilterDialog.selectDate".tr(context),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newFilter = MedicationFilterModel(
                                searchQuery: _searchQuery,
                                statusId: _selectedStatusId,
                                doseForm: _selectedDoseForm,
                                routeId: _selectedRouteId,
                                siteId: _selectedSiteId,
                                asNeeded: _asNeeded,
                                medicationRequestId: _medicationRequestId,
                                startFrom: _startFrom,
                                endUntil: _endUntil,
                              );
                              Navigator.pop(context, newFilter);
                            },
                            child: Text(
                              "medicationFilterDialog.applyFilter".tr(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _medicationRequestIdController.clear();
                                _searchQuery = null;
                                _selectedStatusId = null;
                                _selectedDoseForm = null;
                                _selectedRouteId = null;
                                _selectedSiteId = null;
                                _asNeeded = null;
                                _medicationRequestId = null;
                                _startFrom = null;
                                _endUntil = null;
                              });
                              Navigator.pop(context, MedicationFilterModel());
                            },
                            child: Text(
                              "medicationFilterDialog.clearFilter".tr(context),
                            ),
                          ),
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
