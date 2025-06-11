import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../base/theme/app_color.dart';
import '../../data/models/patient_filter_model.dart';

class PatientFilterDialog extends StatefulWidget {
  final PatientFilterModel currentFilter;

  const PatientFilterDialog({required this.currentFilter, super.key});

  @override
  State<PatientFilterDialog> createState() => _PatientFilterDialogState();
}

class _PatientFilterDialogState extends State<PatientFilterDialog> {
  late PatientFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _minDateOfBirth;
  DateTime? _maxDateOfBirth;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter.copyWith();
    _searchController.text = _filter.searchQuery ?? '';
    _emailController.text = _filter.email ?? '';
    _minDateOfBirth = _filter.minDateOfBirth;
    _maxDateOfBirth = _filter.maxDateOfBirth;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isMinDate,
  }) async {
    final DateTime initialDate =
        (isMinDate ? _minDateOfBirth : _maxDateOfBirth) ?? DateTime.now();
    final DateTime firstDate =
        isMinDate ? DateTime(1900) : (_minDateOfBirth ?? DateTime(1900));
    final DateTime lastDate = DateTime.now();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.from(
            colorScheme: ColorScheme.light(
              primary:
                  Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface:
                  isDarkMode
                      ? Colors.grey[800]!
                      : Colors.white,
              onSurface:
                  isDarkMode
                      ? Colors.white
                      : Colors.black87,
            ),
            textTheme: Theme.of(context).textTheme,
            useMaterial3: true,
          ).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isMinDate) {
          _minDateOfBirth = pickedDate;
          _filter = _filter.copyWith(minDateOfBirth: pickedDate);
        } else {
          _maxDateOfBirth = pickedDate;
          _filter = _filter.copyWith(maxDateOfBirth: pickedDate);
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _filter = PatientFilterModel();
      _searchController.clear();
      _emailController.clear();
      _minDateOfBirth = null;
      _maxDateOfBirth = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).cardColor
              : AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Filter Patients',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        colorScheme.onSurface,
                  ),
                ),
              ),
              Divider(
                height: 30,
                thickness: 1.5,
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),

              Text(
                'General Search',
                style: textTheme.titleSmall?.copyWith(
                  color:
                      isDarkMode
                          ? AppColors.primaryColor
                          : AppColors.primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Search by Name/ID',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                onChanged:
                    (value) => _filter = _filter.copyWith(searchQuery: value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Filter by Email',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _filter = _filter.copyWith(email: value),
              ),
              const SizedBox(height: 30),


              Text(
                'Date of Birth Range',
                style: textTheme.titleSmall?.copyWith(
                  color:
                      isDarkMode
                          ? AppColors.primaryColor
                          : AppColors.primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _selectDate(context, isMinDate: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _minDateOfBirth != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_minDateOfBirth!)
                                  : 'Min Date',
                              style: textTheme.bodyLarge?.copyWith(
                                color:
                                    _minDateOfBirth != null
                                        ? colorScheme
                                            .onSurface
                                        : isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors
                                            .grey
                                            .shade600,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color:
                                  colorScheme
                                      .primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _selectDate(context, isMinDate: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _maxDateOfBirth != null
                                  ? DateFormat(
                                    'MMM d, y',
                                  ).format(_maxDateOfBirth!)
                                  : 'Max Date',
                              style: textTheme.bodyLarge?.copyWith(
                                color:
                                    _maxDateOfBirth != null
                                        ? colorScheme
                                            .onSurface
                                        : isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors
                                            .grey
                                            .shade600,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color:
                                  colorScheme
                                      .primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Text(
                'Patient Status',
                style: textTheme.titleSmall?.copyWith(
                  color:
                      isDarkMode
                          ? AppColors.primaryColor
                          : AppColors.primaryColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Active',
                value: _filter.isActive ?? false,
                onChanged:
                    (value) => _filter = _filter.copyWith(isActive: value),
              ),
              _buildSwitchTile(
                title: 'Deceased',
                value: _filter.isDeceased ?? false,
                onChanged:
                    (value) => _filter = _filter.copyWith(isDeceased: value),
              ),
              _buildSwitchTile(
                title: 'Smoker',
                value: _filter.isSmoker ?? false,
                onChanged:
                    (value) => _filter = _filter.copyWith(isSmoker: value),
              ),
              _buildSwitchTile(
                title: 'Alcohol Drinker',
                value: _filter.isAlcoholDrinker ?? false,
                onChanged:
                    (value) =>
                        _filter = _filter.copyWith(isAlcoholDrinker: value),
              ),
              const SizedBox(height: 24),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, _filter),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              colorScheme
                                  .primary,
                          foregroundColor:
                              colorScheme.onPrimary,
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
                          foregroundColor:
                              colorScheme
                                  .onSurface,
                          side: BorderSide(
                            color: colorScheme.outline,
                          ),
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
                  const SizedBox(
                    height: 1,
                  ),
                  Align(

                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetFilters,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            colorScheme.error,
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
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (newValue) {
              setState(() {
                onChanged(newValue);
              });
            },
            activeColor: colorScheme.primary,
            inactiveTrackColor:
                colorScheme
                    .surfaceVariant,
            inactiveThumbColor: colorScheme.primary.withOpacity(
              0.6,
            ),
          ),
        ],
      ),
    );
  }
}
