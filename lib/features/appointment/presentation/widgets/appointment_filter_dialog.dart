import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';

import '../../../../base/data/models/code_type_model.dart';
import '../../data/models/appointment_filter_model.dart';

class AppointmentFilterDialog extends StatefulWidget {
  final AppointmentFilterModel currentFilter;

  const AppointmentFilterDialog({super.key, required this.currentFilter});

  @override
  _AppointmentFilterDialogState createState() =>
      _AppointmentFilterDialogState();
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
  bool _isCreatedByPractitioner = false;

  List<CodeModel> _types = [];
  List<CodeModel> _statuses = [];

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
    _isCreatedByPractitioner = _filter.createdByPractitioner == 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _doctorIdController.dispose();
    _patientIdController.dispose();
    _clinicIdController.dispose();
    super.dispose();
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Divider(
          height: 20,
          thickness: 1,
          color: colorScheme.outline.withOpacity(0.5),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required DateTime? selectedDate,
    required String label,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              return Theme(
                data: ThemeData.from(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    surface: isDarkMode ? Colors.grey[800]! : Colors.white,
                    onSurface: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textTheme: Theme.of(context).textTheme,
                  useMaterial3: true,
                ).copyWith(
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onDateSelected(picked);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate)
                    : label,
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      selectedDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
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
      _isCreatedByPractitioner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: BoxConstraints(
          maxWidth: context.width * 0.95,
          maxHeight: context.height * 0.85,
        ),
        decoration: BoxDecoration(
          color:
              isDarkMode ? Theme.of(context).cardColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter Appointments",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close Filters',
                ),
              ],
            ),
            Divider(
              height: 25,
              thickness: 1.5,
              color: colorScheme.outline.withOpacity(0.5),
            ),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      title: "Basic Filters",
                      children: [
                        TextFormField(
                          controller: _searchController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Search by keyword',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'e.g., reason, patient name',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.search,
                              color: colorScheme.primary,
                            ),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: colorScheme.secondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _filter = _filter.copyWith(
                                            searchQuery: null,
                                          );
                                        });
                                      },
                                    )
                                    : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                searchQuery: value.isNotEmpty ? value : null,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _doctorIdController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Doctor ID',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'Enter Doctor ID (numeric)',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.person,
                              color: colorScheme.primary,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                doctorId:
                                    value.isNotEmpty
                                        ? int.tryParse(value)
                                        : null,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _patientIdController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Patient ID',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'Enter patient ID (numeric)',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.people,
                              color: colorScheme.primary,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                patientId:
                                    value.isNotEmpty
                                        ? int.tryParse(value)
                                        : null,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _clinicIdController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Clinic ID',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'Enter clinic ID (numeric)',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              Icons.local_hospital,
                              color: colorScheme.primary,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _filter = _filter.copyWith(
                                clinicId:
                                    value.isNotEmpty
                                        ? int.tryParse(value)
                                        : null,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    Gap(14),

                    _buildFilterSection(
                      title: "Appointment Type",
                      children: [
                        BlocBuilder<CodeTypesCubit, CodeTypesState>(
                          builder: (context, state) {
                            if (state is CodesLoading) {
                              return Center(child: LoadingButton());
                            }
                            if (state is CodesError) {
                              return Text(
                                "Error loading types: ${state.error}",
                                style: const TextStyle(color: Colors.red),
                              );
                            }
                            if (state is CodeTypesSuccess) {
                              _types =
                                  state.codes
                                      ?.where(
                                        (code) =>
                                            code.codeTypeModel?.name ==
                                            'appointment_type',
                                      )
                                      .toList() ??
                                  [];
                            }
                            Gap(10);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile<String?>(
                                  title: Text(
                                    "All Types",
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  value: null,
                                  groupValue: _selectedTypeId,
                                  activeColor: colorScheme.primary,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedTypeId = value;
                                      _filter = _filter.copyWith(typeId: null);
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                ..._types
                                    .map(
                                      (type) => RadioListTile<String>(
                                        title: Text(
                                          type.display,
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontSize: 15,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        value: type.id,
                                        groupValue: _selectedTypeId,
                                        activeColor: colorScheme.primary,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedTypeId = value;
                                            _filter = _filter.copyWith(
                                              typeId:
                                                  value != null
                                                      ? int.parse(value)
                                                      : null,
                                            );
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Gap(10),
                    _buildFilterSection(
                      title: "Appointment Status",
                      children: [
                        BlocBuilder<CodeTypesCubit, CodeTypesState>(
                          builder: (context, state) {
                            if (state is CodesLoading) {
                              return Center(child: LoadingButton());
                            }
                            if (state is CodesError) {
                              return Text(
                                "Error loading statuses: ${state.error}",
                                style: const TextStyle(color: Colors.red),
                              );
                            }
                            if (state is CodeTypesSuccess) {
                              _statuses =
                                  state.codes
                                      ?.where(
                                        (code) =>
                                            code.codeTypeModel?.name ==
                                            'appointment_status',
                                      )
                                      .toList() ??
                                  [];
                            }
                            Gap(10);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile<String?>(
                                  title: Text(
                                    "All Statuses",
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  value: null,
                                  groupValue: _selectedStatusId,
                                  activeColor: colorScheme.primary,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedStatusId = value;
                                      _filter = _filter.copyWith(
                                        statusId: null,
                                      );
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                ..._statuses
                                    .map(
                                      (status) => RadioListTile<String>(
                                        title: Text(
                                          status.display,
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontSize: 15,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        value: status.id,
                                        groupValue: _selectedStatusId,
                                        activeColor: colorScheme.primary,
                                        onChanged: (String? value) {
                                          setState(() {
                                            _selectedStatusId = value;
                                            _filter = _filter.copyWith(
                                              statusId:
                                                  value != null
                                                      ? int.parse(value)
                                                      : null,
                                            );
                                          });
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity:
                                            VisualDensity
                                                .compact, // Make it more compact
                                      ),
                                    )
                                    .toList(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Gap(10),

                    // --- Created By Practitioner Switch ---
                    _buildFilterSection(
                      title: "Practitioner Options",
                      children: [
                        SwitchListTile(
                          title: Text(
                            "Created by Current Practitioner",
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ), // Text color
                          ),
                          value: _isCreatedByPractitioner,
                          activeColor: colorScheme.primary, // Active color
                          inactiveTrackColor:
                              colorScheme
                                  .surfaceVariant, // Inactive track color
                          inactiveThumbColor: colorScheme.onSurface.withOpacity(
                            0.6,
                          ), // Inactive thumb color
                          onChanged: (bool value) {
                            setState(() {
                              _isCreatedByPractitioner = value;
                              _filter = _filter.copyWith(
                                createdByPractitioner: value ? 1 : null,
                              );
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    Gap(10),
                    _buildFilterSection(
                      title: "Appointment Dates",
                      children: [
                        Text(
                          "Start Date Range",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ), // Text color
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _minStartDate,
                              label: 'Min Start Date',
                              onDateSelected: (date) {
                                setState(() {
                                  _minStartDate = date;
                                  _filter = _filter.copyWith(
                                    minStartDate: date,
                                  );
                                });
                              },
                            ),
                            const SizedBox(width: 5),
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _maxStartDate,
                              label: 'Max Start Date',
                              onDateSelected: (date) {
                                setState(() {
                                  _maxStartDate = date;
                                  _filter = _filter.copyWith(
                                    maxStartDate: date,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "End Date Range",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _minEndDate,
                              label: 'Min End Date',
                              onDateSelected: (date) {
                                setState(() {
                                  _minEndDate = date;
                                  _filter = _filter.copyWith(minEndDate: date);
                                });
                              },
                            ),
                            const SizedBox(width: 5),
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _maxEndDate,
                              label: 'Max End Date',
                              onDateSelected: (date) {
                                setState(() {
                                  _maxEndDate = date;
                                  _filter = _filter.copyWith(maxEndDate: date);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Cancellation Date Range",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ), // Text color
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _minCancellationDate,
                              label: 'Min Cancel Date',
                              onDateSelected: (date) {
                                setState(() {
                                  _minCancellationDate = date;
                                  _filter = _filter.copyWith(
                                    minCancellationDate: date,
                                  );
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _maxCancellationDate,
                              label: 'Max Cancel Date',
                              onDateSelected: (date) {
                                setState(() {
                                  _maxCancellationDate = date;
                                  _filter = _filter.copyWith(
                                    maxCancellationDate: date,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Gap(12),

                    _buildFilterSection(
                      title: "Sort Order",

                      children: [
                        ToggleButtons(
                          isSelected: [
                            _selectedSort == 'asc',
                            _selectedSort == 'desc',
                          ],
                          onPressed: (int index) {
                            setState(() {
                              if (index == 0) {
                                _selectedSort = 'asc';
                              } else {
                                _selectedSort = 'desc';
                              }
                              _filter = _filter.copyWith(sort: _selectedSort);
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor:
                              colorScheme.onPrimary,
                          fillColor:
                              colorScheme
                                  .primary,
                          borderColor: colorScheme.primary,
                          selectedBorderColor:
                              colorScheme.primary,
                          color:
                              colorScheme
                                  .onSurface,
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Ascending'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Descending'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.start, // محاذاة لليسار
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _filter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).elevatedButtonTheme.style?.backgroundColor?.resolve({
                          MaterialState.pressed,
                        }),
                        foregroundColor: Theme.of(
                          context,
                        ).elevatedButtonTheme.style?.foregroundColor?.resolve({
                          MaterialState.pressed,
                        }),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                      ),
                      child: const Text('Apply Filters'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(
                          context,
                        ).outlinedButtonTheme.style?.foregroundColor?.resolve({
                          MaterialState.pressed,
                        }),
                        side: Theme.of(
                          context,
                        ).outlinedButtonTheme.style?.side?.resolve({
                          MaterialState.pressed,
                        }),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(
                        context,
                      ).textButtonTheme.style?.foregroundColor?.resolve({
                        MaterialState.pressed,
                      }),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
