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
  final TextEditingController _searchController =
      TextEditingController();
  String?
  _selectedSeverityId;
  String? _selectedExposureRouteId;

  List<CodeModel> severities = [];
  List<CodeModel> exposureRoutes = [];

  @override
  void initState() {
    super.initState();

    context.read<CodeTypesCubit>().getAllergyReactionSeverityCodes();
    context.read<CodeTypesCubit>().getAllergyReactionExposureRouteCodes();


    _filter = widget.currentFilter;
    _searchController.text =
        _filter.searchQuery ?? '';
    _selectedSeverityId =
        _filter.severityId?.toString();
    _selectedExposureRouteId = _filter.exposureRouteId?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: BoxConstraints(
          maxWidth: context.width * 0.9,
          maxHeight:
              MediaQuery.of(context).size.height *
              0.8,
        ),
        decoration: BoxDecoration(
          color:
              theme
                  .cardColor,
          borderRadius: BorderRadius.circular(20.0),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildDialogHeader(context, theme),
            const SizedBox(height: 16),
            Divider(
              color: theme.dividerColor.withOpacity(0.6),
              thickness: 1.5,
            ),
            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildFilterSectionTitle("Search", theme),
                    const SizedBox(height: 8),
                    _buildSearchField(theme),
                    const SizedBox(height: 24),

                    _buildFilterSectionTitle("Severity", theme),
                    const SizedBox(height: 8),
                    _buildSeverityFilter(theme),
                    const SizedBox(height: 24),


                    _buildFilterSectionTitle("Exposure Route", theme),
                    const SizedBox(height: 8),
                    _buildExposureRouteFilter(theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }


  Widget _buildDialogHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Filter Reactions",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            size: 28,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close filter',
        ),
      ],
    );
  }


  Widget _buildFilterSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(

          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }


  Widget _buildSearchField(ThemeData theme) {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search reactions...',
        hintStyle: TextStyle(color: theme.hintColor),
        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(
            12.0,
          ),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: theme.iconTheme.color,
        ),
        suffixIcon:
            _searchController
                    .text
                    .isNotEmpty
                ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.iconTheme.color,
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 16.0,
        ),
      ),
      onChanged: (value) {

        setState(() {
          _filter = _filter.copyWith(
            searchQuery: value.isNotEmpty ? value : null,
          );
        });
      },
    );
  }

  Widget _buildSeverityFilter(ThemeData theme) {
    return BlocConsumer<CodeTypesCubit, CodeTypesState>(
      listener: (context, state) {
        if (state is CodeTypesSuccess) {
          setState(() {

            severities =
                state.codes
                    ?.where(
                      (code) => code.codeTypeModel?.name == 'reaction_severity',
                    )
                    .toList() ??
                [];
          });
        }
      },
      builder: (context, state) {
        if (state is CodesLoading) {
          return Center(
            child: LoadingPage(),
          );
        }
        if (state is CodesError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Error loading severities: ${state.error}",
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }
        return Column(
          children: [

            RadioListTile<String?>(
              title: Text(
                "All Severities",
                style: theme.textTheme.bodyLarge,
              ),
              value: null,
              groupValue: _selectedSeverityId,
              activeColor: theme.colorScheme.primary,
              onChanged: (String? value) {
                setState(() {
                  _selectedSeverityId = value;
                  _filter = _filter.copyWith(
                    severityId: null,
                  );
                });
              },
            ),

            ...severities.map((severity) {
              return RadioListTile<String>(
                title: Text(
                  severity.display,
                  style: theme.textTheme.bodyMedium,
                ),
                value: severity.id,
                groupValue: _selectedSeverityId,
                activeColor: theme.colorScheme.primary,
                onChanged: (String? value) {
                  setState(() {
                    _selectedSeverityId = value;
                    _filter = _filter.copyWith(
                      severityId: value != null ? int.tryParse(value) : null,
                    );
                  });
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }


  Widget _buildExposureRouteFilter(ThemeData theme) {
    return BlocConsumer<CodeTypesCubit, CodeTypesState>(
      listener: (context, state) {
        if (state is CodeTypesSuccess) {
          setState(() {
            exposureRoutes =
                state.codes
                    ?.where(
                      (code) =>
                          code.codeTypeModel?.name == 'reaction_exposure_route',
                    )
                    .toList() ??
                [];
          });
        }
      },
      builder: (context, state) {
        if (state is CodesLoading) {
          return Center(child: LoadingPage());
        }
        if (state is CodesError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Error loading exposure routes: ${state.error}",
              style: TextStyle(color: theme.colorScheme.error),
            ),
          );
        }
        return Column(
          children: [
            RadioListTile<String?>(
              title: Text(
                "All Exposure Routes",
                style: theme.textTheme.bodyLarge,
              ),
              value: null,
              groupValue: _selectedExposureRouteId,
              activeColor: theme.colorScheme.primary,
              onChanged: (String? value) {
                setState(() {
                  _selectedExposureRouteId = value;
                  _filter = _filter.copyWith(exposureRouteId: null);
                });
              },
            ),
            ...exposureRoutes.map((route) {
              return RadioListTile<String>(
                title: Text(route.display, style: theme.textTheme.bodyMedium),
                value: route.id,
                groupValue: _selectedExposureRouteId,
                activeColor: theme.colorScheme.primary,
                onChanged: (String? value) {
                  setState(() {
                    _selectedExposureRouteId = value;
                    _filter = _filter.copyWith(
                      exposureRouteId:
                          value != null ? int.tryParse(value) : null,
                    );
                  });
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
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
          child: Text(
            "CLEAR",
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CANCEL",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _filter,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    theme.colorScheme.primary,
                foregroundColor:
                    theme
                        .colorScheme
                        .onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
              ),
              child: const Text(
                "APPLY",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
