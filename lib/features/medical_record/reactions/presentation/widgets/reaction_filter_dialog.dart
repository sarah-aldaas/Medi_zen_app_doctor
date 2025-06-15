import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/media_query_extension.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/reaction_filter_model.dart';

class ReactionFilterDialog extends StatefulWidget {
  final ReactionFilterModel currentFilter;

  const ReactionFilterDialog({required this.currentFilter, super.key});

  @override
  _ReactionFilterDialogState createState() => _ReactionFilterDialogState();
}

class _ReactionFilterDialogState extends State<ReactionFilterDialog> {
  late ReactionFilterModel _filter;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSeverityId;
  String? _selectedExposureRouteId;

  @override
  void initState() {
    super.initState();
    context.read<CodeTypesCubit>().getAllergyReactionSeverityCodes();
    context.read<CodeTypesCubit>().getAllergyReactionExposureRouteCodes();
    _filter = widget.currentFilter;
    _searchController.text = _filter.searchQuery ?? '';
    _selectedSeverityId = _filter.severityId?.toString();
    _selectedExposureRouteId = _filter.exposureRouteId?.toString();
  }

  List<CodeModel> severities = [];
  List<CodeModel> exposureRoutes = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: context.width, maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(16.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter Reactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Search", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search reactions...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _filter = _filter.copyWith(searchQuery: null);
                            });
                          },
                        )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(searchQuery: value.isNotEmpty ? value : null);
                        });
                      },
                    ),
                    const Divider(),
                    const Text("Severity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    BlocConsumer<CodeTypesCubit, CodeTypesState>(
                      listener: (context, state) {
                        if (state is CodeTypesSuccess) {
                          setState(() {
                            severities = state.codes?.where((code) => code.codeTypeModel?.name == 'reaction_severity').toList() ?? [];
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (state is CodesError) {
                          return Text("Error loading severities: ${state.error}");
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Severities"),
                              value: null,
                              groupValue: _selectedSeverityId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedSeverityId = value;
                                  _filter = _filter.copyWith(severityId: null);
                                });
                              },
                            ),
                            ...severities.map((severity) {
                              return RadioListTile<String>(
                                title: Text(severity.display, style: const TextStyle(fontSize: 14)),
                                value: severity.id,
                                groupValue: _selectedSeverityId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedSeverityId = value;
                                    _filter = _filter.copyWith(severityId: value != null ? int.tryParse(value) : null);
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    const Text("Exposure Route", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    BlocConsumer<CodeTypesCubit, CodeTypesState>(
                      listener: (context, state) {
                        if (state is CodeTypesSuccess) {
                          setState(() {
                            exposureRoutes = state.codes?.where((code) => code.codeTypeModel?.name == 'reaction_exposure_route').toList() ?? [];
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is CodesLoading) {
                          return  Center(child: LoadingButton());
                        }
                        if (state is CodesError) {
                          return Text("Error loading exposure routes: ${state.error}");
                        }
                        return Column(
                          children: [
                            RadioListTile<String?>(
                              title: const Text("All Exposure Routes"),
                              value: null,
                              groupValue: _selectedExposureRouteId,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedExposureRouteId = value;
                                  _filter = _filter.copyWith(exposureRouteId: null);
                                });
                              },
                            ),
                            ...exposureRoutes.map((route) {
                              return RadioListTile<String>(
                                title: Text(route.display, style: const TextStyle(fontSize: 14)),
                                value: route.id,
                                groupValue: _selectedExposureRouteId,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedExposureRouteId = value;
                                    _filter = _filter.copyWith(exposureRouteId: value != null ? int.tryParse(value) : null);
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      },
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
                      _filter = ReactionFilterModel();
                      _searchController.clear();
                      _selectedSeverityId = null;
                      _selectedExposureRouteId = null;
                    });
                  },
                  child: const Text("CLEAR", style: TextStyle(color: Colors.red)),
                ),
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: const Text("APPLY"),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}