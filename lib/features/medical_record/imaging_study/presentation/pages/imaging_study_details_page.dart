import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';

import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../observation/data/models/laboratory_model.dart';
import '../../../series/data/models/series_model.dart';
import '../../../series/presentation/pages/full_screen_image_viewer.dart';
import '../../../series/presentation/pages/series_details_page.dart';
import '../../../service_request/data/models/service_request_model.dart';
import '../../data/models/imaging_study_model.dart';
import '../cubit/imaging_study_cubit/imaging_study_cubit.dart';

class ImagingStudyDetailsPage extends StatefulWidget {
  final String serviceId;
  final String imagingStudyId;
  final String patientId;

  const ImagingStudyDetailsPage({
    super.key,
    required this.serviceId,
    required this.imagingStudyId,
    required this.patientId,
  });

  @override
  State<ImagingStudyDetailsPage> createState() =>
      _ImagingStudyDetailsPageState();
}

class _ImagingStudyDetailsPageState extends State<ImagingStudyDetailsPage> {
  @override
  void initState() {
    context.read<ImagingStudyCubit>().loadImagingStudy(
      serviceId: widget.serviceId,
      patientId: widget.patientId,
      imagingStudyId: widget.imagingStudyId,
      context: context,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
        ),
        title: Text(
          'imagingStudyDetailsPage.appBarTitle'.tr(context),
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      body: BlocBuilder<ImagingStudyCubit, ImagingStudyState>(
        builder: (context, state) {
          if (state is ImagingStudyLoading) {
            return const Center(child: LoadingPage());
          }

          if (state is ImagingStudyError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'imagingStudyDetailsPage.failedToLoadStudyDetails'.tr(
                    context,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            );
          }

          if (state is ImagingStudyLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudyDetailsCard(context, state.imagingStudy),
                  if (state.imagingStudy.serviceRequest != null)
                    _buildSectionHeader(
                      'imagingStudyDetailsPage.serviceRequestSectionTitle'.tr(
                        context,
                      ),
                    ),
                  if (state.imagingStudy.serviceRequest != null)
                    _buildServiceRequestCard(
                      context,
                      state.imagingStudy.serviceRequest!,
                    ),
                  if (state.imagingStudy.radiology != null)
                    _buildSectionHeader(
                      'imagingStudyDetailsPage.radiologistInformationSectionTitle'
                          .tr(context),
                    ),
                  if (state.imagingStudy.radiology != null)
                    _buildRadiologistCard(
                      context,
                      state.imagingStudy.radiology!,
                    ),
                  if (state.imagingStudy.series != null &&
                      state.imagingStudy.series!.isNotEmpty)
                    _buildSectionHeader(
                      'imagingStudyDetailsPage.imageSeriesSectionTitle'.tr(
                        context,
                      ),
                    ),
                  if (state.imagingStudy.series != null &&
                      state.imagingStudy.series!.isNotEmpty)
                    _buildSeriesSection(context, state),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildStudyDetailsCard(BuildContext context, ImagingStudyModel study) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              study.title ??
                  'imagingStudyDetailsPage.imagingStudyDefaultTitle'.tr(
                    context,
                  ),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const Divider(height: 24, thickness: 1.5),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.descriptionLabel'.tr(context),
              study.description,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.modalityLabel'.tr(context),
              study.modality?.display,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.modalityDescriptionLabel'.tr(context),
              study.modality?.description,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.statusLabel'.tr(context),
              _getLocalizedStatusDisplay(context, study.status?.display),
              valueColor: _getStatusColor(study.status?.display),
            ),
            if (study.status?.description != null)
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.statusMeaningLabel'.tr(context),
                study.status?.description,
              ),
            if (study.started != null)
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.studyDateLabel'.tr(context),
                DateFormat('MMM d, y - hh:mm a').format(study.started!),
              ),
            // Modified to use _buildDetailRow for cancellation reason
            if (study.cancelledReason != null)
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.cancellationReasonLabel'.tr(
                  context,
                ), // New localization key
                study.cancelledReason,
                valueColor: Colors.red[800],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in-progress':
        return Colors.orange;
      case 'registered':
        return Colors.blue.shade600;
      case 'preliminary':
        return Colors.orange.shade600;
      case 'final':
        return Colors.green.shade600;
      case 'amended':
        return Colors.purple.shade600;
      case 'entered-in-error':
        return Colors.deepOrange.shade600;
      case 'unknown':
      default:
        return Colors.blueGrey;
    }
  }

  String? _getLocalizedStatusDisplay(BuildContext context, String? statusCode) {
    switch (statusCode) {
      case 'completed':
        return 'imagingStudyDetailsPage.statusCompleted'.tr(context);
      case 'cancelled':
        return 'imagingStudyDetailsPage.statusCancelled'.tr(context);
      case 'in-progress':
        return 'imagingStudyDetailsPage.statusInProgress'.tr(context);
      case 'registered':
        return 'imagingStudyDetailsPage.imagingStatusRegistered'.tr(context);
      case 'preliminary':
        return 'imagingStudyDetailsPage.imagingStatusPreliminary'.tr(context);
      case 'final':
        return 'imagingStudyDetailsPage.imagingStatusFinal'.tr(context);
      case 'amended':
        return 'imagingStudyDetailsPage.imagingStatusAmended'.tr(context);
      case 'entered-in-error':
        return 'imagingStudyDetailsPage.imagingStatusEnteredInError'.tr(
          context,
        );
      default:
        return null;
    }
  }

  Widget _buildServiceRequestCard(
    BuildContext context,
    ServiceRequestModel serviceRequest,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.orderDetailsLabel'.tr(context),
              serviceRequest.orderDetails,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.reasonLabel'.tr(context),
              serviceRequest.reason,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.notesLabel'.tr(context),
              serviceRequest.note,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.priorityLabel'.tr(context),
              _getLocalizedPriorityDisplay(
                context,
                serviceRequest.serviceRequestPriority?.display,
              ),
              valueColor: _getPriorityColor(
                serviceRequest.serviceRequestPriority?.display,
              ),
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.statusLabel'.tr(context),
              _getLocalizedStatusDisplay(
                context,
                serviceRequest.serviceRequestStatus?.display,
              ),
              valueColor: _getStatusColor(
                serviceRequest.serviceRequestStatus?.display,
              ),
            ),
            if (serviceRequest.serviceRequestStatus?.description != null)
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.statusMeaningLabel'.tr(context),
                serviceRequest.serviceRequestStatus?.description,
              ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.categoryLabel'.tr(context),
              serviceRequest.serviceRequestCategory?.display,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.bodySiteLabel'.tr(context),
              serviceRequest.serviceRequestBodySite?.display,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return Colors.deepOrange;
      case 'high':
        return Colors.orange;
      case 'routine':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  String? _getLocalizedPriorityDisplay(
    BuildContext context,
    String? priorityCode,
  ) {
    switch (priorityCode) {
      case 'urgent':
        return 'imagingStudyDetailsPage.priorityUrgent'.tr(context);
      case 'high':
        return 'imagingStudyDetailsPage.priorityHigh'.tr(context);
      case 'routine':
        return 'imagingStudyDetailsPage.priorityRoutine'.tr(context);
      default:
        return null;
    }
  }

  Widget _buildRadiologistCard(
    BuildContext context,
    LaboratoryModel radiologist,
  ) {
    String fullName = [
      radiologist.prefix,
      radiologist.given,
      radiologist.family,
      radiologist.suffix,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.nameLabel'.tr(context),
              fullName.isNotEmpty
                  ? fullName
                  : 'imagingStudyDetailsPage.notApplicable'.tr(context),
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.specializationLabel'.tr(context),
              radiologist.text,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.emailLabel'.tr(context),
              radiologist.email,
            ),
            _buildDetailRow(
              context,
              'imagingStudyDetailsPage.addressLabel'.tr(context),
              radiologist.address,
            ),
            if (radiologist.clinic != null) ...[
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.clinicLabel'.tr(context),
                radiologist.clinic!.name,
              ),
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.clinicDescriptionLabel'.tr(context),
                radiologist.clinic!.description,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesSection(BuildContext context, ImagingStudyLoaded state) {
    if (state.imagingStudy.series == null ||
        state.imagingStudy.series!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'imagingStudyDetailsPage.noImageSeriesAvailable'.tr(context),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.imagingStudy.series!.length,
      itemBuilder: (context, index) {
        final series = state.imagingStudy.series![index];
        return _buildSeriesCard(context, series);
      },
    );
  }

  Widget _buildSeriesCard(BuildContext context, SeriesModel series) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SeriesDetailsPage(
                    patientId: widget.patientId,
                    serviceId: widget.serviceId,
                    imagingStudyId: widget.imagingStudyId,
                    seriesId: series.id!,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                series.title ??
                    'imagingStudyDetailsPage.seriesDetailsDefaultTitle'.tr(
                      context,
                    ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const Divider(height: 16),
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.descriptionLabel'.tr(context),
                series.description,
              ),
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.bodySiteLabel'.tr(context),
                series.bodySite?.display,
              ),
              _buildDetailRow(
                context,
                'imagingStudyDetailsPage.imagesCountLabel'.tr(context),
                "{${series.images.length}}", // Pass count as arg
              ),
              if (series.images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: series.images.length,
                      itemBuilder: (context, index) {
                        final imageUrl = series.images[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: GestureDetector(
                            onTap:
                                () => _viewImageFullScreen(context, imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 120,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 120,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 40,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String? value, {
    Color? valueColor,
  }) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.cyan,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }
}
