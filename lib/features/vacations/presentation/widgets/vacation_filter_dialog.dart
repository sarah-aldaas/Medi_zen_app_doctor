import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Vacations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _filter = _filter.copyWith(searchQuery: value),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_selectedStartDate != null
                  ? DateFormat('MMM d, y').format(_selectedStartDate!)
                  : 'Select start date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedStartDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedStartDate = date;
                    _filter = _filter.copyWith(startDate: date);
                  });
                }
              },
            ),
            ListTile(
              title: Text(_selectedEndDate != null
                  ? DateFormat('MMM d, y').format(_selectedEndDate!)
                  : 'Select end date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedEndDate ?? DateTime.now(),
                  firstDate: _selectedStartDate ?? DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedEndDate = date;
                    _filter = _filter.copyWith(endDate: date);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = VacationFilterModel();
                      _searchController.clear();
                      _selectedStartDate = null;
                      _selectedEndDate = null;
                    });
                  },
                  child: const Text('CLEAR'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _filter),
                      child: const Text('APPLY'),
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
}