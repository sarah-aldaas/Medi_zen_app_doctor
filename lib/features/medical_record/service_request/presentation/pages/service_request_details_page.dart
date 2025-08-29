import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/widgets/edit_service_request_page.dart';

import '../../../../../base/widgets/flexible_image.dart';
import '../../../imaging_study/presentation/pages/imaging_study_details_page.dart';
import '../../../observation/presentation/pages/observation_details_page.dart';
import '../cubit/service_request_cubit/service_request_cubit.dart';

class ServiceRequestDetailsPage extends StatefulWidget {
  final String serviceId;
  final String patientId;
  final String? appointmentId;

  const ServiceRequestDetailsPage({
    super.key,
    required this.serviceId,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  _ServiceRequestDetailsPageState createState() =>
      _ServiceRequestDetailsPageState();
}

class _ServiceRequestDetailsPageState extends State<ServiceRequestDetailsPage> {
  final Map<String, GlobalKey> _tooltipKeys = {};

  void _showCustomTooltip(BuildContext context, String message, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx.clamp(10.0, screenSize.width - 200),
            top: position.dy + renderBox.size.height + 4,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.6,
                  maxHeight: 150,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<ServiceRequestCubit>().getServiceRequestDetails(
      serviceId: widget.serviceId,
      patientId: widget.patientId,
      context: context,
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
        title: Text(
          'serviceRequestDetails.title'.tr(context),
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          if (widget.appointmentId != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryColor),
              onPressed: () {
                final state = context.read<ServiceRequestCubit>().state;
                if (state is ServiceRequestLoaded &&
                    state.serviceRequestDetails != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditServiceRequestPage(
                            serviceRequest: state.serviceRequestDetails!,
                            patientId: widget.patientId,
                          ),
                    ),
                  ).then(
                    (_) => context
                        .read<ServiceRequestCubit>()
                        .getServiceRequestDetails(
                          serviceId: widget.serviceId,
                          patientId: widget.patientId,
                          context: context,
                        ),
                  );
                }
              },
              tooltip: 'serviceRequestDetails.editTooltip'.tr(context),
            ),
          ],
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

          if (state is ServiceRequestLoaded &&
              state.serviceRequestDetails != null) {
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
                    'serviceRequestDetails.noDetailsFound'.tr(context),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'serviceRequestDetails.detailsLoadError'.tr(context),
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

  Widget _buildDetailsContent(
    BuildContext context,
    ServiceRequestModel request,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(context, request),
          const SizedBox(height: 24),

          _buildSectionCard(
            context,
            title: 'serviceRequestDetailsPage.serviceDetailsSectionTitle'.tr(
              context,
            ),
            children: [
              _buildDetailRow(
                context,
                'serviceRequestDetailsPage.categoryLabel'.tr(context),
                request.serviceRequestCategory?.display,
                tooltip: request.serviceRequestCategory?.description,
                tooltipKey: _tooltipKeys['category'] ??= GlobalKey(),
              ),
              _buildDetailRow(
                context,
                'serviceRequestDetailsPage.priorityLabel'.tr(context),
                request.serviceRequestPriority?.display,
                tooltip: request.serviceRequestPriority?.description,
                tooltipKey: _tooltipKeys['priority'] ??= GlobalKey(),
              ),
              if (request.serviceRequestBodySite != null)
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.bodySiteLabel'.tr(context),
                  request.serviceRequestBodySite?.display,
                ),
              _buildDetailRow(
                context,
                'serviceRequestDetailsPage.reasonLabel'.tr(context),
                request.reason,
              ),
              _buildDetailRow(
                context,
                'serviceRequestDetailsPage.notesLabel'.tr(context),
                request.note,
              ),
              if (request.occurrenceDate != null)
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.requestDateLabel'.tr(context),
                  DateFormat(
                    'MMM d, y - hh:mm a',
                  ).format(request.occurrenceDate!),
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (request.observation != null)
            _buildSectionCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ObservationDetailsPage(
                          serviceId: widget.serviceId,
                          observationId: request.observation!.id!,
                          patientId: widget.patientId,
                        ),
                  ),
                );
              },
              context,
              title: 'serviceRequestDetailsPage.observationsSectionTitle'.tr(
                context,
              ),
              children: [
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.testNameLabel'.tr(context),
                  request.observation?.observationDefinition?.title,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.resultLabel'.tr(context),
                  request.observation?.value,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.interpretationLabel'.tr(context),
                  request.observation?.interpretation?.display,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.statusLabel'.tr(context),
                  request.observation?.status?.display,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.dateLabel'.tr(context),
                  request.observation?.effectiveDateTime != null
                      ? DateFormat(
                        'MMM d, y - hh:mm a',
                      ).format(request.observation!.effectiveDateTime!)
                      : null,
                ),
              ],
            ),
          if (request.observation != null) const SizedBox(height: 24),

          if (request.imagingStudy != null)
            _buildSectionCard(
              context,
              title: 'serviceRequestDetailsPage.imagingStudySectionTitle'.tr(
                context,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ImagingStudyDetailsPage(
                          serviceId: widget.serviceId,
                          imagingStudyId: request.imagingStudy!.id!,
                          patientId: widget.patientId,
                        ),
                  ),
                );
              },
              children: [
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.titleLabel'.tr(context),
                  request.imagingStudy?.title,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.modalityLabel'.tr(context),
                  request.imagingStudy?.modality?.display,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.statusLabel'.tr(context),
                  request.imagingStudy?.status?.display,
                ),
                if (request.imagingStudy?.started != null)
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.startedLabel'.tr(context),
                    DateFormat(
                      'MMM d, y - hh:mm a',
                    ).format(request.imagingStudy!.started!),
                  ),
                if (request.imagingStudy?.cancelledReason != null)
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.cancellationReasonLabel'.tr(
                      context,
                    ),
                    request.imagingStudy?.cancelledReason,
                  ),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${'serviceRequestDetailsPage.statusMeaningPrefix'.tr(context)} ${request.imagingStudy!.status!.description!}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
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
              title: 'serviceRequestDetailsPage.encounterDetailsSectionTitle'
                  .tr(context),
              children: [
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.typeLabel'.tr(context),
                  request.encounter?.type?.display,
                  tooltip: request.encounter?.type?.description,
                  tooltipKey: _tooltipKeys['encounterType'] ??= GlobalKey(),
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.statusLabel'.tr(context),
                  request.encounter?.status?.display,
                  tooltip: request.encounter?.status?.description,
                  tooltipKey: _tooltipKeys['encounterStatus'] ??= GlobalKey(),
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.reasonLabel'.tr(context),
                  request.encounter?.reason,
                ),
                if (request.encounter?.actualStartDate != null)
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.startDateLabel'.tr(context),
                    DateFormat('MMM d, y - hh:mm a').format(
                      DateTime.parse(request.encounter!.actualStartDate!),
                    ),
                  ),
                if (request.encounter?.actualEndDate != null)
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.endDateLabel'.tr(context),
                    DateFormat(
                      'MMM d, y - hh:mm a',
                    ).format(DateTime.parse(request.encounter!.actualEndDate!)),
                  ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.specialArrangementsLabel'.tr(
                    context,
                  ),
                  request.encounter?.specialArrangement,
                ),

                if (request.encounter?.appointment != null) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(
                    context,
                    'serviceRequestDetailsPage.appointmentDetailsSubSectionTitle'
                        .tr(context),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.typeLabel'.tr(context),
                    request.encounter?.appointment?.type?.display,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.statusLabel'.tr(context),
                    request.encounter?.appointment?.status?.display,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.descriptionLabel'.tr(context),
                    request.encounter?.appointment?.description,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.notesLabel'.tr(context),
                    request.encounter?.appointment?.note,
                  ),
                ],

                if (request.encounter?.appointment?.doctor != null) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(
                    context,
                    'serviceRequestDetailsPage.doctorInformationSubSectionTitle'
                        .tr(context),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.nameLabel'.tr(context),
                    '${request.encounter!.appointment!.doctor!.prefix} ${request.encounter!.appointment!.doctor!.fName} ${request.encounter!.appointment!.doctor!.lName}',
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.specialtyLabel'.tr(context),
                    request.encounter!.appointment!.doctor!.clinic?.name,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.aboutLabel'.tr(context),
                    request.encounter!.appointment!.doctor!.text,
                  ),
                ],

                if (request.encounter?.appointment?.patient != null) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(
                    context,
                    'serviceRequestDetailsPage.patientInformationSubSectionTitle'
                        .tr(context),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.nameLabel'.tr(context),
                    '${request.encounter!.appointment!.patient!.fName} ${request.encounter!.appointment!.patient!.lName}',
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.dateOfBirthLabel'.tr(context),
                    request.encounter!.appointment!.patient!.dateOfBirth != null
                        ? DateFormat('MMM d, y').format(
                          DateTime.parse(
                            request
                                .encounter!
                                .appointment!
                                .patient!
                                .dateOfBirth!,
                          ),
                        )
                        : null,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.genderLabel'.tr(context),
                    request.encounter!.appointment!.patient!.gender?.display,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.bloodTypeLabel'.tr(context),
                    request.encounter!.appointment!.patient!.bloodType?.display,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.maritalStatusLabel'.tr(context),
                    request
                        .encounter!
                        .appointment!
                        .patient!
                        .maritalStatus
                        ?.display,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.heightLabel'.tr(context),
                    request.encounter!.appointment!.patient!.height != null
                        ? '${request.encounter!.appointment!.patient!.height} ${'serviceRequestDetailsPage.cmSuffix'.tr(context)}'
                        : null,
                  ),
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.weightLabel'.tr(context),
                    request.encounter!.appointment!.patient!.weight != null
                        ? '${request.encounter!.appointment!.patient!.weight} ${'serviceRequestDetailsPage.kgSuffix'.tr(context)}'
                        : null,
                  ),
                ],
              ],
            ),
          if (request.encounter != null) const SizedBox(height: 24),

          if (request.healthCareService != null)
            _buildSectionCard(
              context,
              title: 'serviceRequestDetailsPage.serviceInformationSectionTitle'
                  .tr(context),
              children: [
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.categoryLabel'.tr(context),
                  request.healthCareService?.category?.display,
                  tooltip: request.healthCareService?.category?.description,
                  tooltipKey: _tooltipKeys['serviceCategory'] ??= GlobalKey(),
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.priceLabel'.tr(context),
                  servicePriceFormatted(request.healthCareService?.price),
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.descriptionLabel'.tr(context),
                  request.healthCareService?.comment,
                ),
                _buildDetailRow(
                  context,
                  'serviceRequestDetailsPage.additionalDetailsLabel'.tr(
                    context,
                  ),
                  request.healthCareService?.extraDetails,
                ),
                if (request.healthCareService?.clinic != null)
                  _buildDetailRow(
                    context,
                    'serviceRequestDetailsPage.serviceLocationLabel'.tr(
                      context,
                    ),
                    request.healthCareService?.clinic?.name,
                  ),
                if (request.healthCareService?.photo != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: FlexibleImage(
                        height: 180,
                        imageUrl: request.healthCareService!.photo,
                        errorWidget: Container(
                          height: 180,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
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
    if (price == null || price.isEmpty) return "";
    return  price;
  }

  Widget _buildServiceHeader(
    BuildContext context,
    ServiceRequestModel request,
  ) {
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
                    request.healthCareService?.name ??
                        'serviceRequestDetailsPage.unknownService'.tr(context),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    if (request.serviceRequestStatus?.description != null) {
                      final key = GlobalKey();
                      _showCustomTooltip(
                        context,
                        request.serviceRequestStatus!.description!,
                        key,
                      );
                    }
                  },
                  child: _buildStatusChip(
                    context,
                    request.serviceRequestStatus?.code,
                    request.serviceRequestStatus?.display,
                  ),
                ),
              ],
            ),
            if (request.orderDetails != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  request.orderDetails!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        size: 18,
                      ),
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
        style: TextStyle(
          fontSize: 18,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value, {
    String? tooltip,
    GlobalKey? tooltipKey,
  }) {
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
                color: AppColors.cyan1,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child:
                tooltip != null && tooltip.isNotEmpty
                    ? InkWell(
                      onTap: () {
                        _showCustomTooltip(context, tooltip, tooltipKey!);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          key: tooltipKey,
                          child: Text(
                            value,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              decorationColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    )
                    : Text(
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

  Widget _buildStatusChip(
    BuildContext context,
    String? statusCode,
    String? statusDisplay,
  ) {
    final statusColor = _getStatusColor(statusCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.0),
      ),
      child: Text(
        statusDisplay!,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: statusColor.withAlpha(130),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode) {
      case 'active':
        return Colors.blue;
      case 'on-hold':
        return Colors.orange;
      case 'revoked':
        return Colors.red;
      case 'entered-in-error':
        return Colors.purple;
      case 'rejected':
        return Colors.red.shade800;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }


}