import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_model.dart';
import 'package:medi_zen_app_doctor/features/services/data/model/health_care_services_model.dart';
import 'package:medi_zen_app_doctor/features/services/pages/cubits/service_cubit/service_cubit.dart';

import '../cubit/service_request_cubit/service_request_cubit.dart';

class CreateServiceRequestPage extends StatefulWidget {
  final String patientId;
  final String appointmentId;
  final HealthCareServiceModel? healthCareService;

  const CreateServiceRequestPage({
    super.key,
    required this.patientId,
    required this.appointmentId,
    this.healthCareService,
  });

  @override
  _CreateServiceRequestPageState createState() =>
      _CreateServiceRequestPageState();
}

class _CreateServiceRequestPageState extends State<CreateServiceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderDetailsController = TextEditingController();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedPriorityId;
  String? _selectedBodySiteId;
  String? _selectedHealthCareServiceId;

  @override
  void initState() {
    super.initState();
    if (widget.healthCareService != null) {
      _selectedHealthCareServiceId = widget.healthCareService!.id;
    }
    context.read<CodeTypesCubit>().getServiceRequestCategoryCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getServiceRequestPriorityCodes(
      context: context,
    );
    context.read<CodeTypesCubit>().getBodySiteCodes(context: context);
    context.read<ServiceCubit>().getAllServiceHealthCare();
  }

  @override
  void dispose() {
    _orderDetailsController.dispose();
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final serviceRequest = ServiceRequestModel(
        orderDetails: _orderDetailsController.text,
        reason: _reasonController.text,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        serviceRequestCategory:
            _selectedCategoryId != null
                ? CodeModel(
                  id: _selectedCategoryId!,
                  code: '',
                  display: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        serviceRequestPriority:
            _selectedPriorityId != null
                ? CodeModel(
                  id: _selectedPriorityId!,
                  code: '',
                  display: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        serviceRequestBodySite:
            _selectedBodySiteId != null
                ? CodeModel(
                  id: _selectedBodySiteId!,
                  code: '',
                  display: '',
                  description: '',
                  codeTypeId: '',
                )
                : null,
        healthCareService:
            _selectedHealthCareServiceId != null
                ? HealthCareServiceModel(
                  id: _selectedHealthCareServiceId,
                  name: '',
                  comment: '',
                  appointmentRequired: null,
                  price: '',
                  active: null,
                )
                : widget.healthCareService,
      );

      context
          .read<ServiceRequestCubit>()
          .createServiceRequest(
            patientId: widget.patientId,
            appointmentId: widget.appointmentId,
            serviceRequest: serviceRequest,
            context: context,
          )
          .then((_) {
            if (context.read<ServiceRequestCubit>().state
                is ServiceRequestCreated) {
              Navigator.pop(context);
            }
          });
    }
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
            if (state is CodeTypesLoading ||
                state is CodesLoading ||
                state is CodeTypesInitial) {
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('createServiceRequest.select'.tr(context)),
                ),
                ...codes.map(
                  (code) => DropdownMenuItem(
                    value: code.id,
                    child: Text(code.display),
                  ),
                ),
              ],
              onChanged: onChanged,
              validator:
                  (value) =>
                      value == null
                          ? 'createServiceRequest.pleaseSelectOption'.tr(
                            context,
                          )
                          : null,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHealthCareServiceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'createServiceRequest.healthcareService'.tr(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, state) {
            if (state is ServiceHealthCareLoading) {
              return  LoadingButton();
            }
            List<HealthCareServiceModel> services = [];
            if (state is ServiceHealthCareSuccess) {
              services = state.paginatedResponse.paginatedData!.items;
            }
            return DropdownButtonFormField<String>(
              value: _selectedHealthCareServiceId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('createServiceRequest.select'.tr(context)),
                ),
                ...services.map(
                  (service) => DropdownMenuItem(
                    value: service.id,
                    child: Text(
                      service.name ??
                          'createServiceRequest.unknownService'.tr(context),
                    ),
                  ),
                ),
              ],
              onChanged:
                  widget.healthCareService == null
                      ? (value) =>
                          setState(() => _selectedHealthCareServiceId = value)
                      : null,
              validator:
                  (value) =>
                      value == null
                          ? 'createServiceRequest.pleaseSelectHealthcareService'
                              .tr(context)
                          : null,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'createServiceRequest.createServiceRequest'.tr(context),
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
        listener: (context, state) {
          if (state is ServiceRequestError) {
            ShowToast.showToastError(message: state.message);
          } else if (state is ServiceRequestCreated) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ServiceRequestLoading && !state.isLoadMore) {
            return const Center(child: LoadingPage());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _orderDetailsController,
                    decoration: InputDecoration(
                      labelText: 'createServiceRequest.orderDetails'.tr(
                        context,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'createServiceRequest.pleaseEnterOrderDetails'
                            .tr(context);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: 'createServiceRequest.reason'.tr(context),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'createServiceRequest.pleaseEnterReason'.tr(
                          context,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'createServiceRequest.noteOptional'.tr(
                        context,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildCodeDropdown(
                    title: 'createServiceRequest.category'.tr(context),
                    value: _selectedCategoryId,
                    codeTypeName: 'service_request_category',
                    onChanged:
                        (value) => setState(() => _selectedCategoryId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'createServiceRequest.priority'.tr(context),
                    value: _selectedPriorityId,
                    codeTypeName: 'service_request_priority',
                    onChanged:
                        (value) => setState(() => _selectedPriorityId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'createServiceRequest.bodySite'.tr(context),
                    value: _selectedBodySiteId,
                    codeTypeName: 'body_site',
                    onChanged:
                        (value) => setState(() => _selectedBodySiteId = value),
                  ),
                  _buildHealthCareServiceDropdown(),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),

                        elevation: 3,
                      ),
                      child: Text(
                        'createServiceRequest.createServiceRequestButton'.tr(
                          context,
                        ),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
