import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../data/models/diagnostic_report_filter_model.dart';

class DiagnosticReportFilterDialog extends StatefulWidget {
  final DiagnosticReportFilterModel currentFilter;

  const DiagnosticReportFilterDialog({super.key, required this.currentFilter});

  @override
  _DiagnosticReportFilterDialogState createState() =>
      _DiagnosticReportFilterDialogState();
}

class _DiagnosticReportFilterDialogState
    extends State<DiagnosticReportFilterDialog> {
  late DiagnosticReportFilterModel _filter;
  final TextEditingController _searchQueryController = TextEditingController();
  String? _selectedStatusId;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _searchQueryController.text = _filter.searchQuery ?? '';
    _selectedStatusId = _filter.statusId;

    context.read<CodeTypesCubit>().getDiagnosticReportStatusTypeCodes(
      context: context,
    );
  }

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  Widget _buildCodeDropdown({
    required String title,
    required String? value,
    required String codeTypeName,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CodeTypesCubit, CodeTypesState>(
          builder: (context, state) {
            if (state is CodeTypesLoading || state is CodeTypesInitial) {
              return LoadingButton();
            }

            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes =
                  state.codes
                      ?.where(
                        (code) => code.codeTypeModel?.name == codeTypeName,
                      )
                      .toList() ??
                  [];
            }

            return DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'diagnosticFilterPage.diagnosticReportFilter_all'.tr(
                      context,
                    ),
                  ),
                ),
                ...codes
                    .map(
                      (code) => DropdownMenuItem(
                        value: code.id,
                        child: Text(code.display),
                      ),
                    )
                    .toList(),
              ],
              onChanged: onChanged,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 400,
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
                  "diagnosticFilterPage.diagnosticReportFilter_title".tr(
                    context,
                  ),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "diagnosticFilterPage.diagnosticReportFilter_search".tr(
                        context,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _searchQueryController,
                      decoration: InputDecoration(
                        hintText:
                            "diagnosticFilterPage.diagnosticReportFilter_enterSearchTerm"
                                .tr(context),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildCodeDropdown(
                      title:
                          "diagnosticFilterPage.diagnosticReportFilter_status"
                              .tr(context),
                      value: _selectedStatusId,
                      codeTypeName: 'diagnostic_report_status',
                      onChanged:
                          (value) => setState(() => _selectedStatusId = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchQueryController.clear();
                      _selectedStatusId = null;
                    });
                  },
                  child: Text(
                    "diagnosticFilterPage.diagnosticReportFilter_clearFilters"
                        .tr(context),
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "diagnosticFilterPage.diagnosticReportFilter_cancel".tr(
                          context,
                        ),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          DiagnosticReportFilterModel(
                            searchQuery:
                                _searchQueryController.text.isNotEmpty
                                    ? _searchQueryController.text
                                    : null,
                            statusId: _selectedStatusId,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "diagnosticFilterPage.diagnosticReportFilter_apply".tr(
                          context,
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
}
