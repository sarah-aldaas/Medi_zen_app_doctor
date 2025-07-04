import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../conditions/data/models/conditions_model.dart';
import '../../../conditions/presentation/cubit/condition_cubit/conditions_cubit.dart';
import '../../data/models/medication_request_filter.dart';

class MedicationRequestFilterDialog extends StatefulWidget {
  final MedicationRequestFilterModel currentFilter;
final String patientId;
  const MedicationRequestFilterDialog({required this.currentFilter, super.key, required this.patientId});

  @override
  _MedicationRequestFilterDialogState createState() => _MedicationRequestFilterDialogState();
}

class _MedicationRequestFilterDialogState extends State<MedicationRequestFilterDialog> {
  late MedicationRequestFilterModel _filter;
  String? _selectedStatusId;
  String? _selectedIntentId;
  String? _selectedPriorityId;
  String? _selectedCourseOfTherapyTypeId;
  String? _selectedConditionId;
  bool? _doNotPerform;
  String? _searchQuery;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _selectedStatusId = _filter.statusId;
    _selectedIntentId = _filter.intentId;
    _selectedPriorityId = _filter.priorityId;
    _selectedCourseOfTherapyTypeId = _filter.courseOfTherapyTypeId;
    _selectedConditionId = _filter.conditionId;
    _doNotPerform = _filter.doNotPerform;
    _searchQuery = _filter.searchQuery;
    _searchController.text = _searchQuery ?? '';
    _selectedStartDate = _filter.minNumberOfRepeatsAllowed != null ? DateTime.tryParse(_filter.minNumberOfRepeatsAllowed!) : null;
    _selectedEndDate = _filter.maxNumberOfRepeatsAllowed != null ? DateTime.tryParse(_filter.maxNumberOfRepeatsAllowed!) : null;
    context.read<CodeTypesCubit>().getMedicationRequestTherapyTypeTypeCodes(context: context);
    context.read<CodeTypesCubit>().getMedicationRequestIntentTypeCodes(context: context);
    context.read<CodeTypesCubit>().getMedicationRequestPriorityTypeCodes(context: context);
    context.read<CodeTypesCubit>().getMedicationRequestStatusTypeCodes(context: context);
    context.read<ConditionsCubit>().getAllConditions(context: context, patientId:widget.patientId );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  "filterMedicationRequests",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    // Search Query
                    Text(
                      "search",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "searchHint",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      ),
                      onChanged: (value) => _searchQuery = value,
                    ),
                    const SizedBox(height: 20),

                    // Do Not Perform
                    Text(
                      "doNotPerform",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text("doNotPerformLabel"),
                      value: _doNotPerform ?? false,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => setState(() => _doNotPerform = value),
                    ),
                    const SizedBox(height: 20),

                    // Status
                    Text(
                      "status",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> statusTypes = [];
                        if (state is CodeTypesSuccess) {
                          statusTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_request_status').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text("allStatuses"),
                              value: null,
                              groupValue: _selectedStatusId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) => setState(() => _selectedStatusId = value),
                            ),
                            ...statusTypes.map((type) => RadioListTile<String>(
                              title: Text(type.display, style: const TextStyle(fontSize: 14)),
                              value: type.id,
                              groupValue: _selectedStatusId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (value) => setState(() => _selectedStatusId = value),
                            )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Intent
                    Text(
                      "intent",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> intentTypes = [];
                        if (state is CodeTypesSuccess) {
                          intentTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_request_intent').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          hint: Text("selectIntent"),
                          value: _selectedIntentId,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("allIntents"),
                            ),
                            ...intentTypes.map((type) => DropdownMenuItem<String>(
                              value: type.id,
                              child: Text(type.display),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedIntentId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Priority
                    Text(
                      "priority",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> priorityTypes = [];
                        if (state is CodeTypesSuccess) {
                          priorityTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_request_priority').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          hint: Text("selectPriority"),
                          value: _selectedPriorityId,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("allPriorities"),
                            ),
                            ...priorityTypes.map((type) => DropdownMenuItem<String>(
                              value: type.id,
                              child: Text(type.display),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedPriorityId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Course of Therapy Type
                    Text(
                      "courseOfTherapy",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> therapyTypes = [];
                        if (state is CodeTypesSuccess) {
                          therapyTypes = state.codes?.where((code) => code.codeTypeModel?.name == 'medication_request_therapy_type').toList() ?? [];
                        }
                        if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          hint: Text("selectCourseOfTherapy"),
                          value: _selectedCourseOfTherapyTypeId,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("allCourses"),
                            ),
                            ...therapyTypes.map((type) => DropdownMenuItem<String>(
                              value: type.id,
                              child: Text(type.display),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedCourseOfTherapyTypeId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Condition
                    Text(
                      "condition",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<ConditionsCubit, ConditionsState>(
                      builder: (context, state) {
                        List<ConditionsModel> conditions = [];
                        if (state is ConditionsSuccess) {
                          conditions = state.paginatedResponse.paginatedData!.items ?? [];
                        }
                        if (state is ConditionsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          hint: Text("selectCondition"),
                          value: _selectedConditionId,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text("allConditions"),
                            ),
                            ...conditions.map((condition) => DropdownMenuItem<String>(
                              value: condition.id,
                              child: Text(condition.healthIssue ?? 'Unknown Condition'),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedConditionId = value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Start Date
                    Text(
                      "startDate",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedStartDate != null
                            ? DateFormat('MMM d, y').format(_selectedStartDate!)
                            : "selectStartDate",
                        style: TextStyle(color: _selectedStartDate != null ? Colors.black : Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedStartDate = picked;
                            if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
                              _selectedEndDate = null;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // End Date
                    Text(
                      "endDate",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _selectedEndDate != null
                            ? DateFormat('MMM d, y').format(_selectedEndDate!)
                            : "selectEndDate",
                        style: TextStyle(color: _selectedEndDate != null ? Colors.black : Colors.grey[600]),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
                          firstDate: _selectedStartDate ?? DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) setState(() => _selectedEndDate = picked);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedStatusId = null;
                            _selectedIntentId = null;
                            _selectedPriorityId = null;
                            _selectedCourseOfTherapyTypeId = null;
                            _selectedConditionId = null;
                            _doNotPerform = null;
                            _searchQuery = null;
                            _searchController.clear();
                            _selectedStartDate = null;
                            _selectedEndDate = null;
                            _filter = MedicationRequestFilterModel();
                          }),
                          child: Text("clearFilters", style: const TextStyle(color: Colors.red)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  MedicationRequestFilterModel(
                                    searchQuery: _searchQuery,
                                    doNotPerform: _doNotPerform,
                                    statusId: _selectedStatusId,
                                    intentId: _selectedIntentId,
                                    priorityId: _selectedPriorityId,
                                    courseOfTherapyTypeId: _selectedCourseOfTherapyTypeId,
                                    conditionId: _selectedConditionId,
                                    minNumberOfRepeatsAllowed: _selectedStartDate?.toIso8601String(),
                                    maxNumberOfRepeatsAllowed: _selectedEndDate?.toIso8601String(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text("apply"),
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