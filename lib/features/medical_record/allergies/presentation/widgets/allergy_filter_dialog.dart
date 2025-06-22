import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../data/models/allergy_filter_model.dart';

class AllergyFilterDialog extends StatefulWidget {
  final AllergyFilterModel currentFilter;

  const AllergyFilterDialog({super.key, required this.currentFilter});

  @override
  State<AllergyFilterDialog> createState() => _AllergyFilterDialogState();
}

class _AllergyFilterDialogState extends State<AllergyFilterDialog> {
  late AllergyFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'allergyFilterDialog.filterAllergiesTitle'.tr(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'allergyFilterDialog.searchByNameOrNotesLabel'.tr(
                  context,
                ),
                hintText: 'allergyFilterDialog.searchByNameOrNotesHint'.tr(
                  context,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _filter = _filter.copyWith(
                    searchQuery: value.isNotEmpty ? value : null,
                  );
                });
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text('allergyFilterDialog.cancelButton'.tr(context)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _filter.copyWith(
                        searchQuery:
                            _searchController.text.isNotEmpty
                                ? _searchController.text
                                : null,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'allergyFilterDialog.applyFiltersButton'.tr(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
