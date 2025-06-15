import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart'; // تأكد أن هذا يحتوي على AppColors.whiteColor إذا كنت تستخدمه
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart'; // يفترض أن LoadingButton هو جزء من هذا أو تم تعريفه

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

  static const Color _primaryGreenColor = Color(0xFF47BD93);

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
    _minEndDate = _filter.maxEndDate;
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
    bool addTopGap = true,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color effectivePrimaryColor = _primaryGreenColor;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addTopGap) const SizedBox(height: 24),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: effectivePrimaryColor,
            fontSize: 18,
          ),
        ),
        Divider(
          height: 15,
          thickness: 1.5,
          color: effectivePrimaryColor.withOpacity(0.5),
        ),
        const SizedBox(height: 10),
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
    final Color effectivePrimaryColor = _primaryGreenColor;

    return Expanded(
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: ThemeData.from(
                  colorScheme: ColorScheme.light(
                    primary: effectivePrimaryColor,
                    onPrimary: Colors.white,
                    surface: Theme.of(context).canvasColor,
                    onSurface: colorScheme.onSurface,
                  ),
                  textTheme: Theme.of(context).textTheme,
                  useMaterial3: true,
                ).copyWith(
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: effectivePrimaryColor,
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(10),
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[850]
                    : Colors.grey[50],
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
                  fontSize: 10,
                ),
              ),
              Icon(
                Icons.calendar_today,
                size: 15,
                color: effectivePrimaryColor,
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
    final effectivePrimaryColor = _primaryGreenColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: context.height * 30,
        ),
        decoration: BoxDecoration(
          color:
              isDarkMode ? Theme.of(context).cardColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                  "Filter appointments",
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: effectivePrimaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 28,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close filters',
                ),
              ],
            ),
            Divider(
              height: 25,
              thickness: 1.5,
              color: effectivePrimaryColor.withOpacity(0.4),
            ),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      title: "Basic Filters",
                      addTopGap: false,
                      children: [
                        TextFormField(
                          controller: _searchController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Search by keyword',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'ex: reason, patient name',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor:
                                isDarkMode ? Colors.grey[850] : Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.search,
                              color: effectivePrimaryColor,
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
                        const Gap(15),
                        TextFormField(
                          controller: _doctorIdController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Doctor ID',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'Enter doctor ID (numeric)',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor:
                                isDarkMode ? Colors.grey[850] : Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.person,
                              color: effectivePrimaryColor,
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
                        const Gap(15),
                        TextFormField(
                          controller: _patientIdController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: 'patient ID',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            hintText: 'Enter patient ID (numeric)',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor:
                                isDarkMode ? Colors.grey[850] : Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.people,
                              color: effectivePrimaryColor,
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
                        const Gap(15),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor:
                                isDarkMode ? Colors.grey[850] : Colors.grey[50],
                            prefixIcon: Icon(
                              Icons.local_hospital,
                              color: effectivePrimaryColor,
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

                    _buildFilterSection(
                      title: "Appointment type",
                      children: [
                        BlocBuilder<CodeTypesCubit, CodeTypesState>(
                          builder: (context, state) {
                            if (state is CodesLoading) {
                              return Center(child: LoadingPage()); //
                            }
                            if (state is CodesError) {
                              return Text(
                                "Error loading types: ${state.error}",
                                style: TextStyle(color: colorScheme.error),
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile<String?>(
                                  title: Text(
                                    "All types",
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  value: null,
                                  groupValue: _selectedTypeId,
                                  activeColor: effectivePrimaryColor,
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
                                        activeColor: effectivePrimaryColor,
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

                    _buildFilterSection(
                      title: "Appointment status",
                      children: [
                        BlocBuilder<CodeTypesCubit, CodeTypesState>(
                          builder: (context, state) {
                            if (state is CodesLoading) {
                              return Center(child: LoadingPage());
                            }
                            if (state is CodesError) {
                              return Text(
                                "Error loading statuses: ${state.error}",
                                style: TextStyle(color: colorScheme.error),
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
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile<String?>(
                                  title: Text(
                                    "All statuses",
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  value: null,
                                  groupValue: _selectedStatusId,
                                  activeColor: effectivePrimaryColor,
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
                                        activeColor: effectivePrimaryColor,
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

                    _buildFilterSection(
                      title: "Doctor options",
                      children: [
                        SwitchListTile(
                          title: Text(
                            "Created by current doctor",
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          value: _isCreatedByPractitioner,
                          activeColor: effectivePrimaryColor,
                          inactiveTrackColor: colorScheme.surfaceVariant,
                          inactiveThumbColor: colorScheme.onSurface.withOpacity(
                            0.6,
                          ),
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

                    _buildFilterSection(
                      title: "Appointment dates",
                      children: [
                        Text(
                          "Start date range",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _minStartDate,
                              label: 'Min start date',

                              onDateSelected: (date) {
                                setState(() {
                                  _minStartDate = date;
                                  _filter = _filter.copyWith(
                                    minStartDate: date,
                                  );
                                });
                              },
                            ),
                            const Gap(10),
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _maxStartDate,
                              label: 'Max start date',
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
                        const Gap(20),
                        Text(
                          "End date range",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _minEndDate,
                              label: 'Minimum end date',
                              onDateSelected: (date) {
                                setState(() {
                                  _minEndDate = date;
                                  _filter = _filter.copyWith(minEndDate: date);
                                });
                              },
                            ),
                            const Gap(10),
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _maxEndDate,
                              label: 'Max end date',
                              onDateSelected: (date) {
                                setState(() {
                                  _maxEndDate = date;
                                  _filter = _filter.copyWith(maxEndDate: date);
                                });
                              },
                            ),
                          ],
                        ),
                        const Gap(20),
                        Text(
                          "Cancellation date range",
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _minCancellationDate,
                              label: 'Min cancel date',
                              onDateSelected: (date) {
                                setState(() {
                                  _minCancellationDate = date;
                                  _filter = _filter.copyWith(
                                    minCancellationDate: date,
                                  );
                                });
                              },
                            ),
                            const Gap(10),
                            _buildDatePickerField(
                              context: context,
                              selectedDate: _maxCancellationDate,
                              label: 'Max cancel date',
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

                    _buildFilterSection(
                      title: "Sort order",
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
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: Colors.white,
                          fillColor: effectivePrimaryColor,
                          borderColor: effectivePrimaryColor.withOpacity(0.7),
                          selectedBorderColor: effectivePrimaryColor,
                          color: colorScheme.onSurface,
                          textStyle: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text('Asc'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Text('Des'),
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
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context, _filter),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Apply filters ',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: effectivePrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                      ),
                      const Gap(15),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: effectivePrimaryColor,
                        ),
                        label: Text(
                          'cancel',
                          style: textTheme.titleMedium?.copyWith(
                            color: effectivePrimaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: effectivePrimaryColor,
                          side: BorderSide(
                            color: effectivePrimaryColor,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _resetFilters,
                      icon: Icon(Icons.refresh, color: effectivePrimaryColor),
                      label: Text(
                        'Reset',
                        style: textTheme.titleMedium?.copyWith(
                          color: effectivePrimaryColor,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: effectivePrimaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
