import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _emailController.text = _filter.email ?? '';
    _minDateOfBirth = _filter.minDateOfBirth;
    _maxDateOfBirth = _filter.maxDateOfBirth;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(10),
            const Text(
              'Filter Patients',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const Divider(),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged:
                  (value) => _filter = _filter.copyWith(searchQuery: value),
            ),
            Gap(10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => _filter = _filter.copyWith(email: value),
            ),
            const SizedBox(height: 20),
            Text(
              'Date of Birth Range',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      _minDateOfBirth != null
                          ? DateFormat('MMM d, y').format(_minDateOfBirth!)
                          : 'Min Date',
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryColor,
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _minDateOfBirth ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _minDateOfBirth = date;
                          _filter = _filter.copyWith(minDateOfBirth: date);
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      _maxDateOfBirth != null
                          ? DateFormat('MMM d, y').format(_maxDateOfBirth!)
                          : 'Max Date',
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: AppColors.primaryColor,
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _maxDateOfBirth ?? DateTime.now(),
                        firstDate: _minDateOfBirth ?? DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _maxDateOfBirth = date;
                          _filter = _filter.copyWith(maxDateOfBirth: date);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Active'),
              value: _filter.isActive ?? false,
              onChanged:
                  (value) => setState(() {
                    _filter = _filter.copyWith(isActive: value);
                  }),
            ),
            SwitchListTile(
              title: const Text('Deceased'),
              value: _filter.isDeceased ?? false,
              onChanged:
                  (value) => setState(() {
                    _filter = _filter.copyWith(isDeceased: value);
                  }),
            ),
            SwitchListTile(
              title: const Text('Smoker'),
              value: _filter.isSmoker ?? false,
              onChanged:
                  (value) => setState(() {
                    _filter = _filter.copyWith(isSmoker: value);
                  }),
            ),
            SwitchListTile(
              title: const Text('Alcohol Drinker'),
              value: _filter.isAlcoholDrinker ?? false,
              onChanged:
                  (value) => setState(() {
                    _filter = _filter.copyWith(isAlcoholDrinker: value);
                  }),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = PatientFilterModel();
                      _searchController.clear();
                      _emailController.clear();
                      _minDateOfBirth = null;
                      _maxDateOfBirth = null;
                    });
                  },

                  child: Text(
                    'Clear',
                    style: TextStyle(fontSize: 18, color: AppColors.red),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, _filter),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor.withOpacity(
                          0.7,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 3,
                      ),

                      child: Text(
                        'Apply',
                        style: TextStyle(color: AppColors.whiteColor),
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
}
