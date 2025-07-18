import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';


import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
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

    context.read<CodeTypesCubit>().getEncounterTypeCodes(context: context);
    context.read<CodeTypesCubit>().getEncounterStatusCodes(context: context);
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
          maxWidth: context.width * 0.9,
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
                  "encounterPage.filter_encounters_title".tr(context),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: theme.primaryColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'encounterPage.close_filters_tooltip'.tr(context),
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
                      "encounterPage.keywords_label".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                        textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    _buildTextField(
                      context: context,
                      controller: _searchController,
                      hintText: 'encounterPage.search_hint'.tr(context),
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
                      "encounterPage.appointment_id_label".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                        textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    _buildTextField(
                      context: context,
                      controller: _appointmentIdController,
                      hintText: 'encounterPage.appointment_id_hint'.tr(context),
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
                      "encounterPage.encounter_type_label".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                        textTheme.titleMedium?.color,
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
                              child: LoadingButton()
                            ),
                          );
                        }
                        if (state is CodesError) {
                          return Text(
                            "${'encounterPage.error_loading_types'.tr(context)}: ${state.error}",
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
                                typeId:
                                value != null
                                    ? int.tryParse(value!)
                                    : null,
                              );
                            });
                          },
                          allOptionLabel: "encounterPage.all_types_option".tr(
                            context,
                          ),
                        );
                      },
                    ),
                    const Gap(24),
                    Text(
                      "encounterPage.encounter_status_label".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                        textTheme.titleMedium?.color,
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
                                theme.progressIndicatorTheme.color ??
                                    theme
                                        .primaryColor,
                              ),
                            ),
                          );
                        }
                        if (state is CodesError) {
                          return Text(
                            "${'encounterPage.error_loading_statuses'.tr(context)}: ${state.error}",
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
                                value != null
                                    ? int.tryParse(value!)
                                    : null,
                              );
                            });
                          },
                          allOptionLabel: "encounterPage.all_statuses_option"
                              .tr(context),
                        );
                      },
                    ),
                    const Gap(24),
                    Text(
                      "encounterPage.start_date_range_label".tr(context),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                        textTheme.titleMedium?.color,
                      ),
                    ),
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateInput(
                            context: context,
                            label: 'encounterPage.min_date_label'.tr(context),
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
                            label: 'encounterPage.max_date_label'.tr(context),
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
                        backgroundColor:
                        theme.primaryColor,
                        foregroundColor:
                        theme
                            .colorScheme
                            .onPrimary,
                      ),
                      child: Text(
                        "encounterPage.apply_filters_button".tr(context),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                          theme
                              .colorScheme
                              .onPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Gap(12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: theme.textButtonTheme.style?.copyWith(
                        foregroundColor: MaterialStateProperty.resolveWith((
                            states,
                            ) {
                          return theme.primaryColor;
                        }),
                      ),
                      child: Text(
                        "encounterPage.cancel_button".tr(context),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: 15,
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
                    "encounterPage.clear_all_button".tr(context),
                    style: TextStyle(
                      color: theme.primaryColor,
                    ),
                  ),
                  style: theme.outlinedButtonTheme.style?.copyWith(
                    side: MaterialStateProperty.resolveWith((states) {
                      return BorderSide(
                        color: theme.primaryColor,
                      );
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith((
                        states,
                        ) {
                      return theme.primaryColor;
                    }),
                  ),
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
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: textTheme.bodyMedium?.copyWith(
        color: textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
        theme.inputDecorationTheme.hintStyle ??
            textTheme.bodyMedium?.copyWith(
              color: textTheme.bodyMedium?.color,
            ),
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
                color:
                theme
                    .colorScheme
                    .primary,
                width: 2,
              ),
            ),
        prefixIcon:
        prefixIcon != null
            ? Icon(
          prefixIcon,
          color: theme.iconTheme.color,
        )
            : null,
        suffixIcon:
        controller.text.isNotEmpty && onClear != null
            ? IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: theme.iconTheme.color,
          ),
          onPressed: onClear,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled:
        theme.inputDecorationTheme.filled,
        fillColor:
        theme.inputDecorationTheme.fillColor,
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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

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
                colorScheme: colorScheme.copyWith(
                  primary:
                  theme
                      .primaryColor,
                  onPrimary:
                  colorScheme.onPrimary,
                  surface: theme.scaffoldBackgroundColor,
                  onSurface: textTheme.bodyLarge?.color,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                    theme.primaryColor,
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
          labelStyle:
          theme.inputDecorationTheme.labelStyle ??
              textTheme.bodyLarge?.copyWith(color: textTheme.labelLarge?.color),
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
                  color: theme.primaryColor,
                  width: 2,
                ),
              ),
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: theme.iconTheme.color,
          ),
          filled:
          theme.inputDecorationTheme.filled,
          fillColor:
          theme.inputDecorationTheme.fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM d, yyyy').format(selectedDate)
              : 'encounterPage.select_date_label'.tr(context),
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
