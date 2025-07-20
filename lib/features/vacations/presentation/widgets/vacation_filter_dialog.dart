import 'package:flutter/material.dart';
import 'package:gap/gap.dart'; // Import gap for consistent spacing
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../data/model/vacation_filter_model.dart';

class VacationFilterDialog extends StatefulWidget {
  final VacationFilterModel currentFilter;

  const VacationFilterDialog({required this.currentFilter, super.key});

  @override
  State<VacationFilterDialog> createState() => _VacationFilterDialogState();
}

class _VacationFilterDialogState extends State<VacationFilterDialog> {
  late VacationFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _selectedStartDate = _filter.startDate;
    _selectedEndDate = _filter.endDate;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    final picked = await showDatePicker(
      context: context,
      initialDate:
          (isStartDate ? _selectedStartDate : _selectedEndDate) ??
          DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: theme.canvasColor,
              onSurface: theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
            _selectedEndDate = picked.add(const Duration(days: 1));
          }
          _filter = _filter.copyWith(startDate: _selectedStartDate);
        } else {
          _selectedEndDate = picked;
          if (_selectedStartDate != null &&
              _selectedStartDate!.isAfter(picked)) {
            _selectedStartDate = picked.subtract(const Duration(days: 1));
          }
          _filter = _filter.copyWith(endDate: _selectedEndDate);
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filter = VacationFilterModel();
      _searchController.clear();
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'vacationFilterDialog.title'.tr(context),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const Divider(height: 30, thickness: 1.5, color: Colors.grey),
            Text(
              'vacationFilterDialog.searchByReason'.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'vacationFilterDialog.searchLabel'.tr(context),
                hintText: 'vacationFilterDialog.searchHint'.tr(context),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    theme.brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              onChanged:
                  (value) => _filter = _filter.copyWith(searchQuery: value),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'vacationFilterDialog.filterByDateRange'.tr(context),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.event_note,
                      color: primaryColor,
                      size: 28,
                    ),
                    title: Text(
                      'vacationFilterDialog.fromDate'.tr(context),
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      _selectedStartDate != null
                          ? DateFormat('MMM d, y').format(_selectedStartDate!)
                          : 'vacationFilterDialog.notSelected'.tr(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(Icons.calendar_month, color: primaryColor),
                    onTap: () => _selectDate(context, true),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(
                      Icons.event_note,
                      color: primaryColor,
                      size: 28,
                    ),
                    title: Text(
                      'vacationFilterDialog.toDate'.tr(context),
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      _selectedEndDate != null
                          ? DateFormat('MMM d, y').format(_selectedEndDate!)
                          : 'vacationFilterDialog.notSelected'.tr(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(Icons.calendar_month, color: primaryColor),
                    onTap: () => _selectDate(context, false),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Moved buttons to separate rows
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _filter),
                  child: Text(
                    'vacationFilterDialog.applyFiltersButton'.tr(context),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
                const Gap(8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'vacationFilterDialog.cancelButton'.tr(context),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: primaryColor.withOpacity(0.8),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearFilters,
                icon: Icon(
                  Icons.clear_all,
                  size: 24,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'vacationFilterDialog.clearAllButton'.tr(context),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.error.withOpacity(0.5),
                  ), // Add a subtle border
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
