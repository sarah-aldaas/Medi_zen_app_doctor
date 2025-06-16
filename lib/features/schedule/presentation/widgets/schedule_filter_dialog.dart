import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart'; // **تمت الإضافة**

import '../../data/model/schedule_filter_model.dart';

class ScheduleFilterDialog extends StatefulWidget {
  final ScheduleFilterModel currentFilter;

  const ScheduleFilterDialog({required this.currentFilter, super.key});

  @override
  State<ScheduleFilterDialog> createState() => _ScheduleFilterDialogState();
}

class _ScheduleFilterDialogState extends State<ScheduleFilterDialog> {
  late ScheduleFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _selectedStartDate = _filter.planningHorizonStart;
    _selectedEndDate = _filter.planningHorizonEnd;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color dialogBackgroundColor =
    isDarkMode ? Theme.of(context).cardTheme.color! : Colors.white;
    final Color dialogSurfaceTintColor =
    isDarkMode ? Colors.transparent : Colors.transparent;

    final Color titleColor = isDarkMode ? Colors.white : primaryColor;
    final Color sectionHeaderColor =
    isDarkMode ? Colors.white : textTheme.titleMedium!.color!;

    final Color dividerColor =
    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

    final Color cancelButtonColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: dialogBackgroundColor,
      surfaceTintColor: dialogSurfaceTintColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'schedulePage.filter_schedules_title'.tr(context), // **تم التعديل**
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'schedulePage.close_filters_tooltip'.tr(context), // **تم التعديل**
                ),
              ],
            ),
            const Gap(16),
            Divider(color: dividerColor),
            const Gap(18),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'schedulePage.search_by_name_label'.tr(context), // **تم التعديل**
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: sectionHeaderColor,
                      ),
                    ),
                    const Gap(10),
                    _buildTextField(
                      context: context,
                      controller: _searchController,
                      hintText: 'schedulePage.search_by_name_hint'.tr(context), // **تم التعديل**
                      prefixIcon: Icons.search_rounded,
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
                      'schedulePage.planning_horizon_filter_label'.tr(context), // **تم التعديل**
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: sectionHeaderColor,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateInput(
                            context: context,
                            label: 'schedulePage.start_date_label'.tr(context), // **تم التعديل**
                            selectedDate: _selectedStartDate,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedStartDate = date;
                                _filter = _filter.copyWith(
                                  planningHorizonStart: date,
                                );
                              });
                            },
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _buildDateInput(
                            context: context,
                            label: 'schedulePage.end_date_label'.tr(context), // **تم التعديل**
                            selectedDate: _selectedEndDate,
                            firstDate: _selectedStartDate ?? DateTime(2000),
                            onDateSelected: (date) {
                              setState(() {
                                _selectedEndDate = date;
                                _filter = _filter.copyWith(
                                  planningHorizonEnd: date,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),

                    Text(
                      'schedulePage.status_filter_label'.tr(context), // **تم التعديل**
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: sectionHeaderColor,
                      ),
                    ),
                    const Gap(10),
                    _buildRadioGroup(
                      context,
                      options: [
                        CodeModel(id: 'true', display: 'schedulePage.status_active_option'.tr(context)), // **تم التعديل**
                        CodeModel(id: 'false', display: 'schedulePage.status_inactive_option'.tr(context)), // **تم التعديل**
                      ],
                      groupValue: _filter.active?.toString(),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            active: value == null ? null : (value == 'true'),
                          );
                        });
                      },
                      allOptionLabel: 'schedulePage.all_statuses_option'.tr(context), // **تم التعديل**
                    ),
                    const Gap(16),
                  ],
                ),
              ),
            ),
            const Gap(16),
            Divider(color: dividerColor),
            const Gap(16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _filter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'schedulePage.apply_filters_button'.tr(context), // **تم التعديل**
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Gap(12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor:
                        cancelButtonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'schedulePage.cancel_button'.tr(context), // **تم التعديل**
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const Gap(16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: Icon(
                        Icons.clear_all_rounded,
                        color:
                        isDarkMode
                            ? Colors.red.shade400
                            : Colors.red,
                      ),
                      label: Text(
                        'schedulePage.clear_all_button'.tr(context), // **تم التعديل**
                        style: TextStyle(
                          color:
                          isDarkMode
                              ? Colors.red.shade400
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDarkMode ? Colors.red.shade600 : Colors.red,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color enabledBorderColor =
    isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;
    final Color? hintTextColor = isDarkMode ? Colors.grey.shade500 : null;
    final Color fillColor =
    isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
    final Color iconColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color suffixIconColor =
    isDarkMode ? Colors.grey.shade400 : Colors.grey;
    final Color inputTextColor = isDarkMode ? Colors.white : Colors.black87;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: inputTextColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
        hintTextColor != null ? TextStyle(color: hintTextColor) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: enabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: iconColor) : null,
        suffixIcon:
        controller.text.isNotEmpty && onClear != null
            ? IconButton(
          icon: Icon(Icons.clear_rounded, color: suffixIconColor),
          onPressed: onClear,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: fillColor,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDateInput({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
    DateTime? firstDate,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color enabledBorderColor =
    isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;
    final Color fillColor =
    isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
    final Color? labelColor = isDarkMode ? Colors.grey.shade400 : null;
    final Color iconColor = isDarkMode ? Colors.grey.shade400 : primaryColor;
    final Color valueTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color hintValueColor =
    isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data:
              isDarkMode
                  ? ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  surface: Theme.of(context).scaffoldBackgroundColor,
                  onSurface: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                ),
                dialogBackgroundColor:
                Theme.of(context).scaffoldBackgroundColor,
              )
                  : ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(primary: primaryColor),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
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
          labelStyle: labelColor != null ? TextStyle(color: labelColor) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: enabledBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          suffixIcon: Icon(Icons.calendar_today_outlined, color: iconColor),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM d, y').format(selectedDate)
              : 'schedulePage.select_date_placeholder'.tr(context), // **تم التعديل**
          style: textTheme.bodySmall?.copyWith(
            color: selectedDate == null ? hintValueColor : valueTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup(
      BuildContext context, {
        required List<CodeModel> options,
        required String? groupValue,
        required ValueChanged<String?> onChanged,
        required String allOptionLabel,
      }) {
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color radioListTileTextColor =
    isDarkMode ? Colors.white : textTheme.bodyLarge!.color!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String?>(
          title: Text(
            allOptionLabel,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: radioListTileTextColor,
            ),
          ),
          value: null,
          groupValue: groupValue,
          activeColor: primaryColor,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        ...options.map(
              (option) => RadioListTile<String>(
            title: Text(
              option.display,
              style: textTheme.bodyLarge?.copyWith(
                color: radioListTileTextColor,
              ),
            ),
            value: option.id,
            groupValue: groupValue,
            activeColor: primaryColor,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = ScheduleFilterModel();
      _searchController.clear();
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CodeModel {
  final String id;
  final String display;

  CodeModel({required this.id, required this.display});
}