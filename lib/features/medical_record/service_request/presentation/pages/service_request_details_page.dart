import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/services/di/injection_container_common.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/data_source/service_request_remote_data_source.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/widgets/delete_service_request_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/widgets/edit_service_request_page.dart';
import '../../../imaging_study/presentation/pages/imaging_study_details_page.dart';
import '../../../observation/presentation/pages/observation_details_page.dart';
import '../cubit/service_request_cubit/service_request_cubit.dart';

class ServiceRequestDetailsPage extends StatefulWidget {
  final String serviceId;
  final String patientId;

  const ServiceRequestDetailsPage({
    super.key,
    required this.serviceId,
    required this.patientId,
  });

  @override
  _ServiceRequestDetailsPageState createState() => _ServiceRequestDetailsPageState();
}

class _ServiceRequestDetailsPageState extends State<ServiceRequestDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceRequestCubit>().getServiceRequestDetails(
      serviceId: widget.serviceId,
      patientId: widget.patientId,
      context: context,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteServiceRequestDialog(
        serviceId: widget.serviceId,
        patientId: widget.patientId,
        onConfirm: () {
          context.read<ServiceRequestCubit>().deleteServiceRequest(
            serviceId: widget.serviceId,
            patientId: widget.patientId,
            context: context,
          ).then((_) {
            if (context.read<ServiceRequestCubit>().state is ServiceRequestDeleted) {
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop details page
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: const Text(
          'Service Request Details',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () {
              final state = context.read<ServiceRequestCubit>().state;
              if (state is ServiceRequestLoaded && state.serviceRequestDetails != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditServiceRequestPage(serviceRequest:state.serviceRequestDetails! , patientId: widget.patientId))).then((_) => context.read<ServiceRequestCubit>().getServiceRequestDetails(
                  serviceId: widget.serviceId,
                  patientId: widget.patientId,
                  context: context,
                ));
              }
            },
            tooltip: 'Edit Service Request',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.primaryColor),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Service Request',
          ),
        ],
      ),
      body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
        listener: (context, state) {
          if (state is ServiceRequestError) {
            ShowToast.showToastError(message: state.message);
          }
          if (state is ServiceRequestDeleted) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is ServiceRequestLoading && state.isDetailsLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is ServiceRequestLoaded && state.serviceRequestDetails != null) {
            return _buildDetailsContent(context, state.serviceRequestDetails!);
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 80,
                    color: colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Details Found',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service request details could not be loaded.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.6),
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

  Widget _buildDetailsContent(BuildContext context, ServiceRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(context, request),
          const SizedBox(height: 24),
          _buildSectionCard(
            context,
            title: 'Service Details',
            icon: Icons.assignment_outlined,
            children: [
              _buildDetailRow(context, 'Category', request.serviceRequestCategory?.display),
              _buildDetailRow(context, 'Priority', request.serviceRequestPriority?.display),
              if (request.serviceRequestBodySite != null)
                _buildDetailRow(context, 'Body Site', request.serviceRequestBodySite?.display),
              _buildDetailRow(context, 'Reason', request.reason),
              _buildDetailRow(context, 'Note', request.note),
              if (request.occurrenceDate != null)
                _buildDetailRow(
                  context,
                  'Request Date',
                  DateFormat('MMM d, y - hh:mm a').format(request.occurrenceDate!),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (request.observation != null)
            _buildSectionCard(
              context,
              title: 'Observations',
              icon: Icons.medical_information_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ObservationDetailsPage(
                      serviceId: widget.serviceId,
                      observationId: request.observation!.id!, patientId: widget.patientId,
                    ),
                  ),
                );
              },
              children: [
                _buildDetailRow(context, 'Test Name', request.observation?.observationDefinition?.title),
                _buildDetailRow(context, 'Result', request.observation?.value),
                _buildDetailRow(context, 'Interpretation', request.observation?.interpretation?.display),
                _buildDetailRow(context, 'Status', request.observation?.status?.display),
                _buildDetailRow(
                  context,
                  'Date',
                  request.observation?.effectiveDateTime != null
                      ? DateFormat('MMM d, y - hh:mm a').format(request.observation!.effectiveDateTime!)
                      : null,
                ),
                if (request.observation!.pdf != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.picture_as_pdf_outlined,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        label: Text(
                          'View Test Report PDF',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          if (request.observation != null) const SizedBox(height: 24),
          if (request.imagingStudy != null)
            _buildSectionCard(
              context,
              title: 'Imaging Study',
              icon: Icons.camera_alt_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagingStudyDetailsPage(
                      serviceId: widget.serviceId,
                      imagingStudyId: request.imagingStudy!.id!, patientId: widget.patientId,
                    ),
                  ),
                );
              },
              children: [
                _buildDetailRow(context, 'Title', request.imagingStudy?.title),
                _buildDetailRow(context, 'Modality', request.imagingStudy?.modality?.display),
                _buildDetailRow(context, 'Status', request.imagingStudy?.status?.display),
                if (request.imagingStudy?.started != null)
                  _buildDetailRow(
                    context,
                    'Started',
                    DateFormat('MMM d, y - hh:mm a').format(request.imagingStudy!.started!),
                  ),
                if (request.imagingStudy?.cancelledReason != null)
                  _buildDetailRow(context, 'Cancellation Reason', request.imagingStudy?.cancelledReason),
                if (request.imagingStudy?.status?.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Tooltip(
                      message: request.imagingStudy!.status!.description!,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Status Meaning: ${request.imagingStudy!.status!.description!}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          if (request.imagingStudy != null) const SizedBox(height: 24),
          if (request.encounter != null)
            _buildSectionCard(
              context,
              title: 'Encounter Details',
              icon: Icons.meeting_room_outlined,
              children: [
                _buildDetailRow(context, 'Type', request.encounter?.type?.display),
                _buildDetailRow(context, 'Status', request.encounter?.status?.display),
                _buildDetailRow(context, 'Reason', request.encounter?.reason),
                if (request.encounter?.actualStartDate != null)
                  _buildDetailRow(
                    context,
                    'Start Date',
                    DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(request.encounter!.actualStartDate!)),
                  ),
                if (request.encounter?.actualEndDate != null)
                  _buildDetailRow(
                    context,
                    'End Date',
                    DateFormat('MMM d, y - hh:mm a').format(DateTime.parse(request.encounter!.actualEndDate!)),
                  ),
                _buildDetailRow(context, 'Special Arrangements', request.encounter?.specialArrangement),
                if (request.encounter?.appointment != null) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(context, 'Appointment Details'),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  _buildDetailRow(context, 'Type', request.encounter?.appointment?.type?.display),
                  _buildDetailRow(context, 'Status', request.encounter?.appointment?.status?.display),
                  _buildDetailRow(context, 'Description', request.encounter?.appointment?.description),
                  _buildDetailRow(context, 'Note', request.encounter?.appointment?.note),
                ],
                if (request.encounter?.appointment?.doctor != null) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(context, 'Doctor Information'),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  _buildDetailRow(
                    context,
                    'Name',
                    '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.given} ${request.encounter!.appointment!.doctor!.family}',
                  ),
                  _buildDetailRow(context, 'Specialty', request.encounter!.appointment!.doctor!.clinic?.name),
                  _buildDetailRow(context, 'About', request.encounter!.appointment!.doctor!.text),
                ],
                if (request.encounter?.appointment?.patient != null) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(context, 'Patient Information'),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  _buildDetailRow(
                    context,
                    'Name',
                    '${request.encounter!.appointment!.patient!.prefix} ${request.encounter!.appointment!.patient!.given} ${request.encounter!.appointment!.patient!.family}',
                  ),
                  _buildDetailRow(
                    context,
                    'Date of Birth',
                    request.encounter!.appointment!.patient!.dateOfBirth != null
                        ? DateFormat('MMM d, y').format(DateTime.parse(request.encounter!.appointment!.patient!.dateOfBirth!))
                        : null,
                  ),
                  _buildDetailRow(context, 'Gender', request.encounter!.appointment!.patient!.gender?.display),
                  _buildDetailRow(context, 'Blood Type', request.encounter!.appointment!.patient!.bloodType?.display),
                  _buildDetailRow(context, 'Marital Status', request.encounter!.appointment!.patient!.maritalStatus?.display),
                  _buildDetailRow(
                    context,
                    'Height',
                    request.encounter!.appointment!.patient!.height != null
                        ? '${request.encounter!.appointment!.patient!.height} cm'
                        : null,
                  ),
                  _buildDetailRow(
                    context,
                    'Weight',
                    request.encounter!.appointment!.patient!.weight != null
                        ? '${request.encounter!.appointment!.patient!.weight} kg'
                        : null,
                  ),
                ],
              ],
            ),
          if (request.encounter != null) const SizedBox(height: 24),
          if (request.healthCareService != null)
            _buildSectionCard(
              context,
              title: 'Service Information',
              icon: Icons.local_hospital_outlined,
              children: [
                _buildDetailRow(context, 'Category', request.healthCareService?.category?.display),
                _buildDetailRow(context, 'Price', servicePriceFormatted(request.healthCareService?.price)),
                _buildDetailRow(context, 'Description', request.healthCareService?.comment),
                _buildDetailRow(context, 'Additional Details', request.healthCareService?.extraDetails),
                if (request.healthCareService?.clinic != null)
                  _buildDetailRow(context, 'Service Location', request.healthCareService?.clinic?.name),
                if (request.healthCareService?.photo != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        request.healthCareService!.photo!,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  String? servicePriceFormatted(String? price) {
    if (price == null || price.isEmpty) return null;
    return price.contains('\$') ? price : '$price\$';
  }

  Widget _buildServiceHeader(BuildContext context, ServiceRequestModel request) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.healthCareService?.name ?? 'Unknown Service',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusChip(context, request.serviceRequestStatus?.code, request.serviceRequestStatus?.display),
              ],
            ),
            if (request.orderDetails != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  request.orderDetails!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      BuildContext context, {
        required String title,
        required List<Widget> children,
        IconData? icon,
        VoidCallback? onTap,
      }) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(icon, size: 28, color: AppColors.green300),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1.5,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String? statusCode, String? statusDisplay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: _getStatusColor(statusCode),
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(statusCode).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        _getStatusDisplay(statusCode) ?? 'Unknown Status',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String? _getStatusDisplay(String? statusCode) {
    switch (statusCode) {
      case 'active':
        return 'Active';
      case 'on-hold':
        return 'On Hold';
      case 'revoked':
        return 'Revoked';
      case 'entered-in-error':
        return 'Entered in Error';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'in-progress':
        return 'In Progress';
      case 'cancelled':
        return 'Cancelled';
      case 'registered':
        return 'Registered';
      case 'preliminary':
        return 'Preliminary';
      case 'final':
        return 'Final';
      case 'amended':
        return 'Amended';
      case 'unknown':
        return 'Unknown';
      default:
        return null;
    }
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
        return Colors.lightBlue.shade600;
      case 'on-hold':
        return Colors.orange.shade600;
      case 'revoked':
        return Colors.red.shade600;
      case 'entered-in-error':
        return Colors.purple.shade600;
      case 'rejected':
        return Colors.red.shade700;
      case 'completed':
        return Colors.green.shade600;
      case 'in-progress':
        return Colors.blue.shade600;
      case 'cancelled':
        return Colors.red.shade800;
      case 'registered':
        return Colors.blue.shade600;
      case 'preliminary':
        return Colors.orange.shade600;
      case 'final':
        return Colors.green.shade600;
      case 'amended':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}