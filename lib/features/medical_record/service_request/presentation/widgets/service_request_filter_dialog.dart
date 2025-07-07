import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/blocs/code_types_bloc/code_types_cubit.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../services/data/model/health_care_services_model.dart';
import '../../../../services/pages/cubits/service_cubit/service_cubit.dart';
import '../../data/models/service_request_filter.dart';

class ServiceRequestFilterDialog extends StatefulWidget {
  final ServiceRequestFilter currentFilter;

  const ServiceRequestFilterDialog({required this.currentFilter, super.key});

  @override
  _ServiceRequestFilterDialogState createState() =>
      _ServiceRequestFilterDialogState();
}

class _ServiceRequestFilterDialogState
    extends State<ServiceRequestFilterDialog> {
  late ServiceRequestFilter _filter;
  String? _selectedStatusId;
  String? _selectedCategoryId;
  String? _selectedBodySiteId;
  String? _selectedHealthCareServiceId;
  String? _selectedPriorityId;
  List<HealthCareServiceModel> _healthCareServices = [];

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _selectedStatusId = _filter.statusId;
    _selectedCategoryId = _filter.categoryId;
    _selectedBodySiteId = _filter.bodySiteId;
    _selectedHealthCareServiceId = _filter.healthCareServiceId;
    _selectedPriorityId = _filter.priorityId;

    context.read<CodeTypesCubit>().getServiceRequestStatusCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getServiceRequestCategoryCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getServiceRequestPriorityCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);

    _loadHealthCareServices();
  }

  Future<void> _loadHealthCareServices() async {
    context.read<ServiceCubit>().getAllServiceHealthCare(filters: {});

    await Future.delayed(Duration.zero);
    await for (final state in context.read<ServiceCubit>().stream) {
      if (state is ServiceHealthCareSuccess) {
        setState(() {
          _healthCareServices = state.paginatedResponse.paginatedData!.items;
        });
        break;
      } else if (state is ServiceHealthCareError) {
        debugPrint('Error loading healthcare services: ${state.error}');
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceCubit, ServiceState>(
      listener: (context, state) {
        if (state is ServiceHealthCareSuccess) {
          setState(() {
            _healthCareServices = state.paginatedResponse.paginatedData!.items;
          });
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'serviceRequestFilterDialog.title'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(
                          title: 'serviceRequestFilterDialog.statusFilterTitle'
                              .tr(context),
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> statusCodes = [];
                              if (state is CodeTypesSuccess) {
                                statusCodes =
                                    state.codes
                                        ?.where(
                                          (code) =>
                                              code.codeTypeModel?.name ==
                                              'service_request_status',
                                        )
                                        .toList() ??
                                    [];
                              }
                              return _buildCodeDropdown(
                                context: context,
                                value: _selectedStatusId,
                                items: statusCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedStatusId = value;
                                    }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFilterSection(
                          title:
                              'serviceRequestFilterDialog.categoryFilterTitle'
                                  .tr(context),
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> categoryCodes = [];
                              if (state is CodeTypesSuccess) {
                                categoryCodes =
                                    state.codes
                                        ?.where(
                                          (code) =>
                                              code.codeTypeModel?.name ==
                                              'service_request_category',
                                        )
                                        .toList() ??
                                    [];
                              }
                              return _buildCodeDropdown(
                                context: context,
                                value: _selectedCategoryId,
                                items: categoryCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedCategoryId = value;
                                    }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildFilterSection(
                          title:
                              'serviceRequestFilterDialog.priorityFilterTitle'
                                  .tr(context),
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> priorityCodes = [];
                              if (state is CodeTypesSuccess) {
                                priorityCodes =
                                    state.codes
                                        ?.where(
                                          (code) =>
                                              code.codeTypeModel?.name ==
                                              'service_request_priority',
                                        )
                                        .toList() ??
                                    [];
                              }
                              return _buildCodeDropdown(
                                context: context,
                                value: _selectedPriorityId,
                                items: priorityCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedPriorityId = value;
                                    }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildFilterSection(
                          title:
                              'serviceRequestFilterDialog.bodySiteFilterTitle'
                                  .tr(context),
                          child: BlocBuilder<CodeTypesCubit, CodeTypesState>(
                            builder: (context, state) {
                              List<CodeModel> bodySiteCodes = [];
                              if (state is CodeTypesSuccess) {
                                bodySiteCodes =
                                    state.codes
                                        ?.where(
                                          (code) =>
                                              code.codeTypeModel?.name ==
                                              'body_site',
                                        )
                                        .toList() ??
                                    [];
                              }
                              return _buildCodeDropdown(
                                context: context,
                                value: _selectedBodySiteId,
                                items: bodySiteCodes,
                                onChanged:
                                    (value) => setState(() {
                                      _selectedBodySiteId = value;
                                    }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildFilterSection(
                          title:
                              'serviceRequestFilterDialog.healthCareServiceFilterTitle'
                                  .tr(context),
                          child: _buildHealthCareServiceDropdown(
                            context,
                            state,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatusId = null;
                          _selectedCategoryId = null;
                          _selectedBodySiteId = null;
                          _selectedHealthCareServiceId = null;
                          _selectedPriorityId = null;
                        });
                      },
                      child: Text(
                        'serviceRequestFilterDialog.clearFilterButton'.tr(
                          context,
                        ),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'serviceRequestFilterDialog.cancelButton'.tr(
                              context,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              ServiceRequestFilter(
                                statusId: _selectedStatusId,
                                categoryId: _selectedCategoryId,
                                bodySiteId: _selectedBodySiteId,
                                healthCareServiceId:
                                    _selectedHealthCareServiceId,
                                priorityId: _selectedPriorityId,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'serviceRequestFilterDialog.applyButton'.tr(
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
      },
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildCodeDropdown({
    required BuildContext context,
    required String? value,
    required List<CodeModel> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('serviceRequestFilterDialog.allLabel'.tr(context)),
        ),
        ...items.map((code) {
          return DropdownMenuItem(
            value: code.id,
            child: Text(
              code.display ??
                  'serviceRequestFilterDialog.unknownLabel'.tr(context),
            ),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildHealthCareServiceDropdown(
    BuildContext context,
    ServiceState state,
  ) {
    return state is ServiceHealthCareLoading
        ? const LoadingPage()
        : DropdownButtonFormField<String>(
          value: _selectedHealthCareServiceId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'serviceRequestFilterDialog.allServicesLabel'.tr(context),
              ),
            ),
            ..._healthCareServices.map((service) {
              return DropdownMenuItem(
                value: service.id,
                child: Text(
                  service.name ??
                      'serviceRequestFilterDialog.unknownServiceLabel'.tr(
                        context,
                      ),
                ),
              );
            }).toList(),
          ],
          onChanged:
              (value) => setState(() {
                _selectedHealthCareServiceId = value;
              }),
        );
  }
}
