import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';

import '../../../../../base/theme/app_color.dart';
import '../../data/models/observation_model.dart';
import '../cubit/observation_cubit/observation_cubit.dart';

class ObservationDetailsPage extends StatefulWidget {
  final String serviceId;
  final String patientId;
  final String observationId;

  const ObservationDetailsPage({
    super.key,
    required this.serviceId,
    required this.observationId,
    required this.patientId,
  });

  @override
  State<ObservationDetailsPage> createState() => _ObservationDetailsPageState();
}

class _ObservationDetailsPageState extends State<ObservationDetailsPage> {
  void _showCustomTooltip(BuildContext context, String message, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlayState = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;

    OverlayEntry overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx.clamp(10.0, screenSize.width - 200),
            top: position.dy + size.height + 5,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width * 0.8,
                  maxHeight: 200,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
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

  Widget _buildClickableTextWithTooltip(
    BuildContext context,
    String? value,
    String? description,
    GlobalKey key,
  ) {
    if (value == null || value.isEmpty) {
      return Text(
        'observationDetailsPage.notSpecified'.tr(context),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    if (description == null || description.isEmpty) {
      return Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    return InkWell(
      key: key,
      onTap: () {
        _showCustomTooltip(context, description, key);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<ObservationCubit>().getObservationDetails(
      context: context,
      serviceId: widget.serviceId,
      patientId: widget.patientId,
      observationId: widget.observationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: Text(
          'observationDetailsPage.appBarTitle'.tr(context),
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BlocBuilder<ObservationCubit, ObservationState>(
        builder: (context, state) {
          if (state is ObservationLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is ObservationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'observationDetailsPage.errorOccurred'.tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ObservationCubit>().getObservationDetails(
                          context: context,
                          serviceId: widget.serviceId,
                          patientId: widget.patientId,
                          observationId: widget.observationId,
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'observationDetailsPage.tryAgain'.tr(context),
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ObservationLoaded) {
            return _buildObservationDetails(context, state.observation);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildObservationDetails(
    BuildContext context,
    ObservationModel observation,
  ) {
    const Color greenColor = Colors.green;
    final Map<GlobalKey, String> tooltipKeys = {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context,
            title:
                observation.observationDefinition?.title ??
                'observationDetailsPage.observationDetailsSectionTitle'.tr(
                  context,
                ),
            icon: Icons.medical_services_outlined,
            children: [
              _buildDetailRow(
                context,
                'observationDetailsPage.valueLabel'.tr(context),
                observation.value,
              ),
              _buildDetailRow(
                context,
                'observationDetailsPage.interpretationLabel'.tr(context),
                observation.interpretation?.display,
                tooltip: observation.interpretation?.description,
              ),
              _buildDetailRow(
                context,
                'observationDetailsPage.statusLabel'.tr(context),
                observation.status?.display,
                tooltip: observation.status?.description,
              ),
              _buildDetailRow(
                context,
                'observationDetailsPage.methodLabel'.tr(context),
                observation.method?.display,
                tooltip: observation.method?.description,
              ),
              _buildDetailRow(
                context,
                'observationDetailsPage.bodySiteLabel'.tr(context),
                observation.bodySite?.display,
                tooltip: observation.bodySite?.description,
              ),
              _buildDetailRow(
                context,
                'observationDetailsPage.notesLabel'.tr(context),
                observation.note,
              ),
              if (observation.effectiveDateTime != null)
                _buildDetailRow(
                  context,
                  'observationDetailsPage.dateLabel'.tr(context),
                  DateFormat(
                    'MMM d, y - hh:mm a',
                  ).format(observation.effectiveDateTime!),
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (observation.pdf != null)
            _buildSectionCard(
              context,
              title: 'observationDetailsPage.testReportSectionTitle'.tr(
                context,
              ),
              icon: Icons.picture_as_pdf_outlined,
              children: [
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewPdfReport(context, observation.pdf!),
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    label: Text(
                      'observationDetailsPage.viewFullReportPDFButton'.tr(
                        context,
                      ),
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
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
              ],
            ),
          if (observation.pdf != null) const SizedBox(height: 24),

          if (observation.observationDefinition != null)
            _buildSectionCard(
              context,
              title: 'observationDetailsPage.testDefinitionSectionTitle'.tr(
                context,
              ),
              icon: Icons.science_outlined,
              children: [
                _buildDetailRow(
                  context,
                  'observationDetailsPage.nameLabel'.tr(context),
                  observation.observationDefinition?.name,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.descriptionLabel'.tr(context),
                  observation.observationDefinition?.description,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.purposeLabel'.tr(context),
                  observation.observationDefinition?.purpose,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.typeLabel'.tr(context),
                  observation.observationDefinition?.type?.display,
                  tooltip: observation.observationDefinition?.type?.description,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.classificationLabel'.tr(context),
                  observation.observationDefinition?.classification?.display,
                  tooltip:
                      observation
                          .observationDefinition
                          ?.classification
                          ?.description,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.preferredUnitLabel'.tr(context),
                  observation.observationDefinition?.permittedUnit?.display,
                  tooltip:
                      observation
                          .observationDefinition
                          ?.permittedUnit
                          ?.description,
                ),

                if (observation
                        .observationDefinition
                        ?.qualifiedValues
                        .isNotEmpty ??
                    false) ...[
                  const SizedBox(height: 16),
                  _buildSubSectionTitle(
                    context,
                    'observationDetailsPage.referenceRangesSubSectionTitle'.tr(
                      context,
                    ),
                  ),
                  ...observation.observationDefinition!.qualifiedValues.map((
                    qv,
                  ) {
                    final key = GlobalKey();
                    tooltipKeys[key] = qv.context?.description ?? '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: greenColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (qv.ageRange != null)
                              _buildDetailRow(
                                context,
                                'observationDetailsPage.ageRangeLabel'.tr(
                                  context,
                                ),
                                '${qv.ageRange!.low?.value} - ${qv.ageRange!.high?.value} ${qv.ageRange!.low?.unit ?? ''}',
                              ),
                            if (qv.valueRange != null)
                              _buildDetailRow(
                                context,
                                'observationDetailsPage.valueRangeLabel'.tr(
                                  context,
                                ),
                                '${qv.valueRange!.low?.value} - ${qv.valueRange!.high?.value} ${qv.valueRange!.low?.unit ?? ''}',
                              ),
                            _buildDetailRow(
                              context,
                              'observationDetailsPage.appliesToLabel'.tr(
                                context,
                              ),
                              qv.appliesTo?.display,
                              tooltip: qv.appliesTo?.description,
                            ),
                            _buildDetailRow(
                              context,
                              'observationDetailsPage.genderLabel'.tr(context),
                              qv.gender?.display,
                              tooltip: qv.gender?.description,
                            ),
                            _buildDetailRow(
                              context,
                              'observationDetailsPage.contextLabel'.tr(context),
                              qv.context?.display,
                              tooltip: qv.context?.description,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          if (observation.observationDefinition != null)
            const SizedBox(height: 24),

          if (observation.laboratory != null)
            _buildSectionCard(
              context,
              title: 'observationDetailsPage.laboratoryInformationSectionTitle'
                  .tr(context),
              icon: Icons.science_outlined,
              children: [
                _buildDetailRow(
                  context,
                  'observationDetailsPage.labSpecialistLabel'.tr(context),
                  '${observation.laboratory!.prefix ?? ''} ${observation.laboratory!.given ?? ''} ${observation.laboratory!.family ?? ''}',
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.emailLabel'.tr(context),
                  observation.laboratory!.email,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.addressLabel'.tr(context),
                  observation.laboratory!.address,
                ),
                if (observation.laboratory!.clinic != null) ...[
                  _buildDetailRow(
                    context,
                    'observationDetailsPage.clinicLabel'.tr(context),
                    observation.laboratory!.clinic!.name,
                  ),
                  _buildDetailRow(
                    context,
                    'observationDetailsPage.clinicDescriptionLabel'.tr(context),
                    observation.laboratory!.clinic!.description,
                  ),
                ],
              ],
            ),
          if (observation.laboratory != null) const SizedBox(height: 24),

          if (observation.serviceRequest != null)
            _buildSectionCard(
              context,
              title: 'observationDetailsPage.relatedServiceRequestSectionTitle'
                  .tr(context),
              icon: Icons.link_outlined,
              children: [
                _buildDetailRow(
                  context,
                  'observationDetailsPage.orderDetailsLabel'.tr(context),
                  observation.serviceRequest!.orderDetails,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.reasonLabel'.tr(context),
                  observation.serviceRequest!.reason,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.priorityLabel'.tr(context),
                  observation.serviceRequest!.serviceRequestPriority?.display,
                  tooltip:
                      observation
                          .serviceRequest!
                          .serviceRequestPriority
                          ?.description,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.statusLabel'.tr(context),
                  observation.serviceRequest!.serviceRequestStatus?.display,
                  tooltip:
                      observation
                          .serviceRequest!
                          .serviceRequestStatus
                          ?.description,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.categoryLabel'.tr(context),
                  observation.serviceRequest!.serviceRequestCategory?.display,
                  tooltip:
                      observation
                          .serviceRequest!
                          .serviceRequestCategory
                          ?.description,
                ),
                _buildDetailRow(
                  context,
                  'observationDetailsPage.bodySiteLabel'.tr(context),
                  observation.serviceRequest!.serviceRequestBodySite?.display,
                  tooltip:
                      observation
                          .serviceRequest!
                          .serviceRequestBodySite
                          ?.description,
                ),
              ],
            ),
        ],
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
      elevation: Theme.of(context).cardTheme.elevation ?? 6,
      shape:
          Theme.of(context).cardTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                      child: Icon(
                        icon,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
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
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
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
    const Color greenColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: greenColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value, {
    String? tooltip,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    final key = GlobalKey();

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
                fontWeight: FontWeight.w600,
                color: Colors.cyan,
                fontSize: 17,
              ),
            ),
          ),
          Expanded(
            child:
                tooltip != null && tooltip.isNotEmpty
                    ? InkWell(
                      key: key,
                      onTap: () {
                        _showCustomTooltip(context, tooltip, key);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
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

  void _viewPdfReport(BuildContext context, String pdfUrl) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'observationDetailsPage.pdfReportDialogTitle'.tr(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blackColor,
              ),
            ),
            content: Text(
              'observationDetailsPage.pdfReportDialogContent'.tr(context),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'observationDetailsPage.pdfReportDialogCancel'.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'observationDetailsPage.pdfReportDialogView'.tr(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
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
    final TextTheme textTheme = Theme.of(context).textTheme;

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
        statusDisplay ?? 'observationDetailsPage.unknownStatus'.tr(context),
        style: textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
      case 'unknown':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getImagingStatusColor(String? statusCode) {
    return _getStatusColor(statusCode);
  }
}
