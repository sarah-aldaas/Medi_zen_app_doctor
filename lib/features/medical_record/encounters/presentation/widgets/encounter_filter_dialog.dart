import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
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
  final TextEditingController _appointmentIdController =
      TextEditingController();

  String? _selectedTypeId;
  String? _selectedStatusId;
  DateTime? _minStartDate;
  DateTime? _maxStartDate;

  List<CodeModel> _types = [];
  List<CodeModel> _statuses = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;

    _searchController.text = _filter.searchQuery ?? '';
    _appointmentIdController.text = _filter.appointmentId?.toString() ?? '';
    _selectedTypeId = _filter.typeId?.toString();
    _selectedStatusId = _filter.statusId?.toString();
    _minStartDate = _filter.minStartDate;
    _maxStartDate = _filter.maxStartDate;

    context.read<CodeTypesCubit>().getEncounterTypeCodes();
    context.read<CodeTypesCubit>().getEncounterStatusCodes();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ThemeData theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: theme.dialogTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        constraints: BoxConstraints(
          maxWidth: context.width,
          maxHeight: context.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Encounters",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close Filters',
                ),
              ],
            ),
            const Gap(16),
            Divider(color: theme.dividerColor),
            const Gap(16),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Keywords",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    _buildTextField(
                      context: context,
                      controller: _searchController,
                      hintText: 'Search by reason or arrangement...',
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            searchQuery: value.isNotEmpty ? value : null,
                          );
                        });
                      },
                      onClear: () {
                        setState(() {
                          _searchController.clear();
                          _filter = _filter.copyWith(searchQuery: null);
                        });
                      },
                    ),
                    const Gap(24),

                    Text(
                      "Appointment ID",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    _buildTextField(
                      context: context,
                      controller: _appointmentIdController,
                      hintText: 'e.g., 12345',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.perm_identity_outlined,
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            appointmentId:
                                value.isNotEmpty ? int.tryParse(value) : null,
                          );
                        });
                      },
                      onClear: () {
                        setState(() {
                          _appointmentIdController.clear();
                          _filter = _filter.copyWith(appointmentId: null);
                        });
                      },
                    ),
                    const Gap(24),

                    Text(
                      "Encounter Type",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: CircularProgressIndicator(
                                color:
                                    Theme.of(
                                      context,
                                    ).progressIndicatorTheme.color,
                              ),
                            ),
                          );
                        }
                        if (state is CodesError) {
                          return Text(
                            "Error loading types: ${state.error}",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          );
                        }
                        if (state is CodeTypesSuccess) {
                          _types =
                              state.codes
                                  ?.where(
                                    (code) =>
                                        code.codeTypeModel?.name ==
                                        'encounter_type',
                                  )
                                  .toList() ??
                              [];
                        }
                        return _buildRadioGroup(
                          context,
                          options: _types,

                          groupValue: _selectedTypeId,
                          onChanged: (value) {
                            setState(() {
                              _selectedTypeId = value;
                              _filter = _filter.copyWith(
                                typeId: value != null ? int.parse(value) : null,
                              );
                            });
                          },
                          allOptionLabel: "All Types",
                        );
                      },
                    ),
                    const Gap(24),

                    Text(
                      "Encounter Status",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: CircularProgressIndicator(
                                color:
                                    Theme.of(
                                      context,
                                    ).progressIndicatorTheme.color,
                              ),
                            ),
                          );
                        }
                        if (state is CodesError) {
                          return Text(
                            "Error loading statuses: ${state.error}",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          );
                        }
                        if (state is CodeTypesSuccess) {
                          _statuses =
                              state.codes
                                  ?.where(
                                    (code) =>
                                        code.codeTypeModel?.name ==
                                        'encounter_status',
                                  )
                                  .toList() ??
                              [];
                        }
                        return _buildRadioGroup(
                          context,
                          options: _statuses,
                          groupValue: _selectedStatusId,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusId = value;
                              _filter = _filter.copyWith(
                                statusId:
                                    value != null ? int.parse(value) : null,
                              );
                            });
                          },
                          allOptionLabel: "All Statuses",
                        );
                      },
                    ),
                    const Gap(24),

                    Text(
                      "Start Date Range",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateInput(
                            context: context,
                            label: 'Min Date',
                            selectedDate: _minStartDate,
                            onDateSelected: (date) {
                              setState(() {
                                _minStartDate = date;
                                _filter = _filter.copyWith(minStartDate: date);
                              });
                            },
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildDateInput(
                            context: context,
                            label: 'Max Date',
                            selectedDate: _maxStartDate,
                            onDateSelected: (date) {
                              setState(() {
                                _maxStartDate = date;
                                _filter = _filter.copyWith(maxStartDate: date);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                  ],
                ),
              ),
            ),
            const Gap(16),
            Divider(color: theme.dividerColor),
            const Gap(16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "Apply Filters",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                    const Gap(12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: Theme.of(context).textButtonTheme.style,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(18),
                OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: Icon(
                    Icons.clear_all_rounded,
                    color: theme.primaryColor,
                  ),
                  label: Text(
                    "Clear All",
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  style: Theme.of(context).outlinedButtonTheme.style,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    final ThemeData theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.inputDecorationTheme.hintStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder:
            theme.inputDecorationTheme.enabledBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
        focusedBorder:
            theme.inputDecorationTheme.focusedBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: theme.iconTheme.color)
                : null,
        suffixIcon:
            controller.text.isNotEmpty && onClear != null
                ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: theme.iconTheme.color),
                  onPressed: onClear,
                )
                : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildRadioGroup(
    BuildContext context, {
    required List<CodeModel> options,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required String allOptionLabel,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        RadioListTile<String?>(
          title: Text(
            allOptionLabel,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: textTheme.bodyLarge?.color,
            ),
          ),
          value: null,
          groupValue: groupValue,
          activeColor: colorScheme.primary,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        ...options.map(
          (option) => RadioListTile<String>(
            title: Text(
              option.display,
              style: textTheme.bodyLarge?.copyWith(
                color: textTheme.bodyLarge?.color,
              ),
            ),
            value: option.id,
            groupValue: groupValue,
            activeColor: colorScheme.primary,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    //final ColorScheme colorScheme = Theme.of(context).colorSme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: AppColors.primaryColor,
                  onSurface: textTheme.bodyLarge?.color,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        onDateSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.inputDecorationTheme.labelStyle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder:
              theme.inputDecorationTheme.enabledBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
          focusedBorder:
              theme.inputDecorationTheme.focusedBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: theme.iconTheme.color,
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM d,yyyy').format(selectedDate)
              : 'Select Date',
          style: textTheme.bodyLarge?.copyWith(
            color:
                selectedDate == null
                    ? textTheme.bodyLarge?.color?.withOpacity(0.6)
                    : textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = EncounterFilterModel();
      _searchController.clear();
      _appointmentIdController.clear();
      _selectedTypeId = null;
      _selectedStatusId = null;
      _minStartDate = null;
      _maxStartDate = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _appointmentIdController.dispose();
    super.dispose();
  }
}
