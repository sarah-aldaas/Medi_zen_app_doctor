import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/theme/app_color.dart';

import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_model.dart';
import '../cubit/medication_cubit/medication_cubit.dart';
import '../widgets/delete_medication_dialog.dart';
import '../widgets/edit_medication_page.dart';

class MedicationDetailsPage extends StatefulWidget {
  final String medicationId;
  final String patientId;
  final String? appointmentId;
  final String? conditionId;
  final String medicationRequestId;

  const MedicationDetailsPage({
    super.key,
    required this.medicationId,
    required this.patientId,
    required this.medicationRequestId,
    this.conditionId,
    required this.appointmentId,
  });

  @override
  _MedicationDetailsPageState createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  final Map<String, GlobalKey> _tooltipKeys = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    context.read<MedicationCubit>().getMedicationDetails(
      context: context,
      medicationId: widget.medicationId,
      patientId: widget.patientId,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => DeleteMedicationDialog(
            medicationId: widget.medicationId,
            patientId: widget.patientId,
            onConfirm: () {
              context
                  .read<MedicationCubit>()
                  .deleteMedication(
                    conditionId: widget.conditionId!,
                    medicationRequestId: widget.medicationRequestId,
                    patientId: widget.patientId,
                    medicationId: widget.medicationId,
                    context: context,
                  )
                  .then((_) {
                    if (context.read<MedicationCubit>().state
                        is MedicationDeleted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  });
            },
          ),
    );
  }

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
            top: position.dy + 30,
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "medicationDetails.title".tr(context),
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (widget.appointmentId != null) ...[
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primaryColor),
              onPressed: () {
                final state = context.read<MedicationCubit>().state;
                if (state is MedicationDetailsSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditMedicationPage(
                            medication: state.medication,
                            patientId: widget.patientId,
                            conditionId: widget.conditionId!,
                            medicationRequestId: widget.medicationRequestId,
                          ),
                    ),
                  ).then((_) => _refresh());
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.primaryColor),
              onPressed: _showDeleteConfirmation,
            ),
          ],
        ],
      ),
      body: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationError) {
            ShowToast.showToastError(message: state.error);
          } else if (state is MedicationDeleted) {
            ShowToast.showToastSuccess(message: state.message);
          }
        },
        builder: (context, state) {
          if (state is MedicationDetailsSuccess) {
            return _buildMedicationDetails(context, state.medication);
          } else if (state is MedicationLoading) {
            return const Center(child: LoadingPage());
          } else if (state is MedicationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "medicationDetails.failedToLoad".tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: Icon(Icons.refresh, color: AppColors.whiteColor),
                      label: Text(
                        'medicationDetails.retry'.tr(context),
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                "medicationDetails.noDetailsAvailable".tr(context),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMedicationDetails(
    BuildContext context,
    MedicationModel medication,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, medication),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: "medicationDetails.dosageInformation".tr(context),
            icon: Icons.access_time,
            children: [
              _buildDetailRow(
                context,
                "medicationDetails.dose".tr(context),
                '${medication.dose ?? 'medicationDetails.notAvailableAbbr'.tr(context)} ${medication.doseUnit ?? ''}',
              ),
              if (medication.maxDosePerPeriod != null)
                _buildDetailRow(
                  context,
                  "medicationDetails.maxDose".tr(context),
                  '${medication.maxDosePerPeriod!.numerator.value} ${medication.maxDosePerPeriod!.numerator.unit} ${"medicationDetails.per".tr(context)} ${medication.maxDosePerPeriod!.denominator.value} ${medication.maxDosePerPeriod!.denominator.unit}',
                ),
              _buildDetailRow(
                context,
                "medicationDetails.instructions".tr(context),
                medication.dosageInstructions ?? 'N/A',
              ),
              _buildDetailRow(
                context,
                "medicationDetails.doseForm".tr(context),
                medication.doseForm?.display ?? 'N/A',
                tooltip: medication.doseForm?.description,
              ),
              _buildDetailRow(
                context,
                "medicationDetails.route".tr(context),
                medication.route?.display ?? 'N/A',
                tooltip: medication.route?.description,
              ),
              _buildDetailRow(
                context,
                "medicationDetails.site".tr(context),
                medication.site?.display ?? 'N/A',
                tooltip: medication.site?.description,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: "medicationDetails.instructionsTitle".tr(context),
            icon: Icons.notes,
            children: [
              _buildDetailRow(
                context,
                "medicationDetails.patientInstructions".tr(context),
                medication.patientInstructions ?? 'N/A',
              ),
              _buildDetailRow(
                context,
                "medicationDetails.additionalInstructions".tr(context),
                medication.additionalInstructions ?? 'N/A',
              ),
              _buildDetailRow(
                context,
                "medicationDetails.asNeeded".tr(context),
                medication.asNeeded != null
                    ? (medication.asNeeded!
                        ? 'medicationDetails.yes'.tr(context)
                        : 'medicationDetails.no'.tr(context))
                    : 'N/A',
              ),
              _buildDetailRow(
                context,
                "medicationDetails.event".tr(context),
                medication.event ?? 'N/A',
              ),
              _buildDetailRow(
                context,
                "medicationDetails.when".tr(context),
                medication.when ?? 'N/A',
              ),
              if (medication.offset != null && medication.offsetUnit != null)
                _buildDetailRow(
                  context,
                  "medicationDetails.offset".tr(context),
                  "${medication.offset} ${medication.offsetUnit?.codeTypeModel}",
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            context,
            title: "medicationDetails.statusAndDates".tr(context),
            icon: Icons.calendar_today,
            children: [
              _buildDetailRow(
                context,
                "medicationDetails.status".tr(context),
                medication.status?.display ?? 'N/A',
                tooltip: medication.status?.description,
              ),
              _buildDetailRow(
                context,
                "medicationDetails.startDate".tr(context),
                medication.effectiveMedicationStartDate != null
                    ? DateFormat(
                      'MMM d, y',
                    ).format(medication.effectiveMedicationStartDate!)
                    : 'N/A',
              ),
              _buildDetailRow(
                context,
                "medicationDetails.endDate".tr(context),
                medication.effectiveMedicationEndDate != null
                    ? DateFormat(
                      'MMM d, y',
                    ).format(medication.effectiveMedicationEndDate!)
                    : 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MedicationModel medication) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication,
            color: colorScheme.onTertiaryContainer,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name ??
                      'medicationDetails.unknownMedication'.tr(context),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  medication.definition ??
                      'medicationDetails.noDescriptionAvailable'.tr(context),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.secondaryColor.withOpacity(0.7),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    String? tooltip,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    if (value.isEmpty || value == 'N/A') {
      return const SizedBox.shrink();
    }

    final key = ValueKey(label);
    _tooltipKeys[label] = _tooltipKeys[label] ?? GlobalKey();

    Widget valueWidget = Text(value, style: const TextStyle(fontSize: 15));

    if (tooltip != null && tooltip.isNotEmpty) {
      valueWidget = GestureDetector(
        onTap: () => _showCustomTooltip(context, tooltip, _tooltipKeys[label]!),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            key: _tooltipKeys[label],
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: valueWidget,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.cyan1,
              ),
            ),
          ),
          SizedBox(width: 30),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }
}
