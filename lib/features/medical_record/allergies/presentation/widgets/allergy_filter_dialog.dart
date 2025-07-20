import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/allergy_filter_model.dart';

class AllergyFilterDialog extends StatefulWidget {
  final AllergyFilterModel currentFilter;

  const AllergyFilterDialog({super.key, required this.currentFilter});

  @override
  State<AllergyFilterDialog> createState() => _AllergyFilterDialogState();
}

class _AllergyFilterDialogState extends State<AllergyFilterDialog> {
  late AllergyFilterModel _filter;
  String? _selectedTypeId;
  String? _selectedSort;
  int? _selectedCategoryId;
  int? _selectedClinicalStatusId;
  int? _selectedVerificationStatusId;
  int? _selectedCriticalityId;
  int? _selectedDiscoveredDuringEncounter;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchController = TextEditingController(text: _filter.searchQuery);
    _selectedTypeId = _filter.typeId?.toString();
    _selectedCategoryId = _filter.categoryId;
    _selectedClinicalStatusId = _filter.clinicalStatusId;
    _selectedVerificationStatusId = _filter.verificationStatusId;
    _selectedCriticalityId = _filter.criticalityId;
    _selectedDiscoveredDuringEncounter = _filter.isDiscoveredDuringEncounter;
    _selectedSort = _filter.sort;

    context.read<CodeTypesCubit>().getAllergyTypeCodes(context: context);
    context.read<CodeTypesCubit>().getAllergyCategoryCodes(context: context);
    context.read<CodeTypesCubit>().getAllergyClinicalStatusCodes(context: context);
    context.read<CodeTypesCubit>().getAllergyVerificationStatusCodes(context: context);
    context.read<CodeTypesCubit>().getAllergyCriticalityCodes(context: context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "allergyFilter.filterAllergies".tr(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: theme.dividerColor),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'allergyFilter.search'.tr(
                          context,
                        ), // Translated
                        labelStyle: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.iconTheme.color,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                        ),
                      ),
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "allergyFilter.discoveredDuringEncounter".tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        RadioListTile<int?>(
                          title: Text(
                            "allergyFilter.any".tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          value: null,
                          groupValue: _selectedDiscoveredDuringEncounter,
                          activeColor: theme.primaryColor,
                          tileColor: theme.cardColor,
                          selectedTileColor: theme.primaryColor.withOpacity(
                            0.1,
                          ),
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDiscoveredDuringEncounter = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(
                            "allergyFilter.yes".tr(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          value: 1,
                          groupValue: _selectedDiscoveredDuringEncounter,
                          activeColor: theme.primaryColor,
                          tileColor: theme.cardColor,
                          selectedTileColor: theme.primaryColor.withOpacity(
                            0.1,
                          ),
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDiscoveredDuringEncounter = value;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(
                            "allergyFilter.no".tr(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          value: 0,
                          groupValue: _selectedDiscoveredDuringEncounter,
                          activeColor: theme.primaryColor,
                          tileColor: theme.cardColor,
                          selectedTileColor: theme.primaryColor.withOpacity(
                            0.1,
                          ),
                          onChanged: (int? value) {
                            setState(() {
                              _selectedDiscoveredDuringEncounter = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Divider(color: theme.dividerColor),
                    Text(
                      "allergyFilter.allergyType".tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> allergyTypes = [];
                        if (state is CodeTypesSuccess) {
                          allergyTypes =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'allergy_type',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (allergyTypes.isEmpty) {
                          return Text(
                            "allergyFilter.noAllergyTypesAvailable".tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: Text(
                                "allergyFilter.allTypes".tr(context),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedTypeId,
                              activeColor: theme.primaryColor,
                              tileColor: theme.cardColor,
                              selectedTileColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedTypeId = value;
                                });
                              },
                            ),
                            ...allergyTypes.map((type) {
                              return RadioListTile<String>(
                                title: Text(
                                  type.display ??
                                      'allergyFilter.unknown'.tr(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: type.id,
                                groupValue: _selectedTypeId,
                                activeColor: theme.primaryColor,
                                tileColor: theme.cardColor,
                                selectedTileColor: theme.primaryColor
                                    .withOpacity(0.1),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedTypeId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    Divider(color: theme.dividerColor),
                    Text(
                      "allergyFilter.category".tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> categories = [];
                        if (state is CodeTypesSuccess) {
                          categories =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'allergy_category',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (categories.isEmpty) {
                          return Text(
                            "allergyFilter.noCategoriesAvailable".tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<int?>(
                              title: Text(
                                "allergyFilter.allCategories".tr(context),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedCategoryId,
                              activeColor: theme.primaryColor,
                              tileColor: theme.cardColor,
                              selectedTileColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            ),
                            ...categories.map((category) {
                              return RadioListTile<int>(
                                title: Text(
                                  category.display ??
                                      'allergyFilter.unknown'.tr(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: int.parse(category.id),
                                groupValue: _selectedCategoryId,
                                activeColor: theme.primaryColor,
                                tileColor: theme.cardColor,
                                selectedTileColor: theme.primaryColor
                                    .withOpacity(0.1),
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    Divider(color: theme.dividerColor),
                    Text(
                      "allergyFilter.clinicalStatus".tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> clinicalStatuses = [];
                        if (state is CodeTypesSuccess) {
                          clinicalStatuses =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'allergy_clinical_status',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (clinicalStatuses.isEmpty) {
                          return Text(
                            "allergyFilter.noClinicalStatusesAvailable".tr(
                              context,
                            ), // Translated
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<int?>(
                              title: Text(
                                "allergyFilter.allStatuses".tr(context),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedClinicalStatusId,
                              activeColor: theme.primaryColor,
                              tileColor: theme.cardColor,
                              selectedTileColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedClinicalStatusId = value;
                                });
                              },
                            ),
                            ...clinicalStatuses.map((status) {
                              return RadioListTile<int>(
                                title: Text(
                                  status.display ??
                                      'allergyFilter.unknown'.tr(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: int.parse(status.id),
                                groupValue: _selectedClinicalStatusId,
                                activeColor: theme.primaryColor,
                                tileColor: theme.cardColor,
                                selectedTileColor: theme.primaryColor
                                    .withOpacity(0.1),
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedClinicalStatusId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    Text(
                      "allergyFilter.criticality".tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<CodeTypesCubit, CodeTypesState>(
                      builder: (context, state) {
                        List<CodeModel> criticalities = [];
                        if (state is CodeTypesSuccess) {
                          criticalities =
                              state.codes
                                  ?.where(
                                    (code) =>
                                code.codeTypeModel?.name ==
                                    'allergy_criticality',
                              )
                                  .toList() ??
                                  [];
                        }
                        if (state is CodesLoading) {
                          return Center(child: LoadingButton());
                        }
                        if (criticalities.isEmpty) {
                          return Text(
                            "allergyFilter.noCriticalitiesAvailable".tr(
                              context,
                            ),
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            RadioListTile<int?>(
                              title: Text(
                                "allergyFilter.allCriticalities".tr(context),
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              value: null,
                              groupValue: _selectedCriticalityId,
                              activeColor: theme.primaryColor,
                              tileColor: theme.cardColor,
                              selectedTileColor: theme.primaryColor.withOpacity(
                                0.1,
                              ),
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedCriticalityId = value;
                                });
                              },
                            ),
                            ...criticalities.map((criticality) {
                              return RadioListTile<int>(
                                title: Text(
                                  criticality.display ??
                                      'allergyFilter.unknown'.tr(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                value: int.parse(criticality.id),
                                groupValue: _selectedCriticalityId,
                                activeColor: theme.primaryColor,
                                tileColor: theme.cardColor,
                                selectedTileColor: theme.primaryColor
                                    .withOpacity(0.1),
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedCriticalityId = value;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Sort Order
                    Text(
                      "allergyFilter.sortOrder".tr(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: theme.iconTheme.color,
                      ),
                      dropdownColor: theme.cardColor,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            "allergyFilter.default".tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'asc',
                          child: Text(
                            "allergyFilter.oldestFirst".tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'desc',
                          child: Text(
                            "allergyFilter.newestFirst".tr(context),
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() {
                        _selectedSort = value;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTypeId = null;
                      _selectedCategoryId = null;
                      _selectedClinicalStatusId = null;
                      _selectedVerificationStatusId = null;
                      _selectedCriticalityId = null;
                      _selectedDiscoveredDuringEncounter = null;
                      _searchController.clear();
                      _selectedSort = null;
                      _filter = AllergyFilterModel();
                    });
                  },
                  child: Text(
                    "allergyFilter.clearFilters".tr(context),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "allergyFilter.cancel".tr(context),
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          AllergyFilterModel(
                            searchQuery: _filter.searchQuery,
                            isDiscoveredDuringEncounter:
                            _selectedDiscoveredDuringEncounter,
                            typeId:
                            _selectedTypeId != null
                                ? int.tryParse(_selectedTypeId!)
                                : null,
                            clinicalStatusId: _selectedClinicalStatusId,
                            verificationStatusId: _selectedVerificationStatusId,
                            categoryId: _selectedCategoryId,
                            criticalityId: _selectedCriticalityId,
                            sort: _selectedSort,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text("allergyFilter.apply".tr(context)),
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
