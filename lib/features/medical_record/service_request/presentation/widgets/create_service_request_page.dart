import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/blocs/code_types_bloc/code_types_cubit.dart';
import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
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
  _CreateServiceRequestPageState createState() => _CreateServiceRequestPageState();
}

class _CreateServiceRequestPageState extends State<CreateServiceRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderDetailsController = TextEditingController();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _occurrenceDate;
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
    context.read<CodeTypesCubit>().getServiceRequestCategoryCodes(context: context);
    context.read<CodeTypesCubit>().getServiceRequestPriorityCodes(context: context);
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
        occurrenceDate: _occurrenceDate,
        serviceRequestCategory: _selectedCategoryId != null ? CodeModel(id: _selectedCategoryId!, code: '', display: '', description: '', codeTypeId: '') : null,
        serviceRequestPriority: _selectedPriorityId != null ? CodeModel(id: _selectedPriorityId!, code: '', display: '', description: '', codeTypeId: '') : null,
        serviceRequestBodySite: _selectedBodySiteId != null ? CodeModel(id: _selectedBodySiteId!, code: '', display: '', description: '', codeTypeId: '') : null,
        healthCareService: _selectedHealthCareServiceId != null
            ? HealthCareServiceModel(id: _selectedHealthCareServiceId, name: '', comment: '', appointmentRequired: null, price: '', active: null)
            : widget.healthCareService,
      );

      context.read<ServiceRequestCubit>().createServiceRequest(
        patientId: widget.patientId,
        appointmentId: widget.appointmentId,
        serviceRequest: serviceRequest,
        context: context,
      ).then((_) {
        if (context.read<ServiceRequestCubit>().state is ServiceRequestCreated) {
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
            if (state is CodeTypesLoading || state is CodesLoading || state is CodeTypesInitial) {
              return const CircularProgressIndicator();
            }
            List<CodeModel> codes = [];
            if (state is CodeTypesSuccess) {
              codes = state.codes?.where((code) => code.codeTypeModel?.name == codeTypeName).toList() ?? [];
            }
            return DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Select'),
                ),
                ...codes.map((code) => DropdownMenuItem(
                  value: code.id,
                  child: Text(code.display),
                )),
              ],
              onChanged: onChanged,
              validator: (value) => value == null ? 'Please select an option' : null,
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
        const Text(
          'Healthcare Service',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, state) {
            if (state is ServiceHealthCareLoading) {
              return const CircularProgressIndicator();
            }
            List<HealthCareServiceModel> services = [];
            if (state is ServiceHealthCareSuccess) {
              services = state.paginatedResponse.paginatedData!.items;
            }
            return DropdownButtonFormField<String>(
              value: _selectedHealthCareServiceId,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Select'),
                ),
                ...services.map((service) => DropdownMenuItem(
                  value: service.id,
                  child: Text(service.name ?? 'Unknown Service'),
                )),
              ],
              onChanged: widget.healthCareService == null
                  ? (value) => setState(() => _selectedHealthCareServiceId = value)
                  : null,
              validator: (value) => value == null ? 'Please select a healthcare service' : null,
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
        title: const Text(
          'Create Service Request',
          style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
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
                    decoration: const InputDecoration(
                      labelText: 'Order Details',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter order details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Occurrence Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    title: Text(
                      _occurrenceDate != null
                          ? DateFormat('MMM d, y').format(_occurrenceDate!)
                          : 'Select Occurrence Date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _occurrenceDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCodeDropdown(
                    title: 'Category',
                    value: _selectedCategoryId,
                    codeTypeName: 'service_request_category',
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'Priority',
                    value: _selectedPriorityId,
                    codeTypeName: 'service_request_priority',
                    onChanged: (value) => setState(() => _selectedPriorityId = value),
                  ),
                  _buildCodeDropdown(
                    title: 'Body Site',
                    value: _selectedBodySiteId,
                    codeTypeName: 'body_site',
                    onChanged: (value) => setState(() => _selectedBodySiteId = value),
                  ),
                  _buildHealthCareServiceDropdown(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Create Service Request'),
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

