import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import 'package:medi_zen_app_doctor/base/widgets/show_toast.dart';

import '../../../../../base/theme/app_color.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';
import '../widgets/allergy_form_page.dart';

class AllergyDetailsPage extends StatefulWidget {
  final String patientId;
  final String allergyId;
  const AllergyDetailsPage({
    super.key,
    required this.patientId,
    required this.allergyId,
  });

  @override
  State<AllergyDetailsPage> createState() => _AllergyDetailsPageState();
}

class _AllergyDetailsPageState extends State<AllergyDetailsPage> {
  late AllergyModel allergyModel;

  @override
  void initState() {
    super.initState();
    context.read<AllergyCubit>().getAllergyDetails(
      patientId: widget.patientId,
      allergyId: widget.allergyId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),

        title: Text(
          'Allergy Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.9), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, size: 28),
            color: AppColors.primaryColor,
            onPressed: _navigateToEdit,
            tooltip: 'Edit Allergy',
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, size: 28),
            color: AppColors.primaryColor,
            onPressed: _confirmDelete,
            tooltip: 'Delete Allergy',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyDeleted) {
            Navigator.pop(context);
            ShowToast.showToastSuccess(message: 'Allergy deleted successfully');
          }
          if (state is AllergyError) {
            ShowToast.showToastError(message: state.error);
          }
        },
        builder: (context, state) {
          if (state is AllergyDetailsLoaded) {
            allergyModel = state.allergy;
            return _buildAllergyDetails(state.allergy);
          }
          if (state is AllergyLoading) {
            return const Center(child: LoadingPage());
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 70,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Failed to load allergy details.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please check your connection or try again later.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildAllergyDetails(AllergyModel allergy) {
    final theme = Theme.of(context);

    return Container(
      color:
          theme.brightness == Brightness.light
              ? Colors.grey[50]
              : Colors.grey[900],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.9),
                      AppColors.primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        allergy.name ?? 'Unknown Allergy',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'General Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildDetailItem(
                      context,
                      'Onset Age',
                      allergy.onSetAge,
                      Icons.child_care,
                    ),
                    _buildDetailItem(
                      context,
                      'Last Occurrence',
                      allergy.lastOccurrence,
                      Icons.event_note,
                    ),
                    _buildDetailItem(
                      context,
                      'Discovered During Encounter',
                      allergy.discoveredDuringEncounter == "1" ? "Yes" : "No",
                      Icons.medical_services,
                    ),
                    if (allergy.note != null && allergy.note!.isNotEmpty)
                      _buildDetailItem(
                        context,
                        'Additional Notes',
                        allergy.note,
                        Icons.notes,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Clinical Classification',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (allergy.type != null)
                      _buildDetailItem(
                        context,
                        'Type',
                        allergy.type!.display,
                        Icons.category,
                      ),
                    if (allergy.clinicalStatus != null)
                      _buildDetailItem(
                        context,
                        'Clinical Status',
                        allergy.clinicalStatus!.display,
                        Icons.health_and_safety,
                      ),
                    if (allergy.verificationStatus != null)
                      _buildDetailItem(
                        context,
                        'Verification Status',
                        allergy.verificationStatus!.display,
                        Icons.verified,
                      ),
                    if (allergy.category != null)
                      _buildDetailItem(
                        context,
                        'Category',
                        allergy.category!.display,
                        Icons.class_,
                      ),
                    if (allergy.criticality != null)
                      _buildDetailItem(
                        context,
                        'Criticality',
                        allergy.criticality!.display,
                        Icons.priority_high,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (allergy.reactions != null && allergy.reactions!.isNotEmpty) ...[
              Text(
                'Associated Reactions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 18),
              ...allergy.reactions!
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reaction ${entry.key + 1}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,

                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const Divider(height: 28, thickness: 0.8),
                              _buildDetailItem(
                                context,
                                'Substance',
                                entry.value.substance,
                                Icons.medical_information,
                              ),
                              _buildDetailItem(
                                context,
                                'Manifestation',
                                entry.value.manifestation,
                                Icons.local_hospital,
                              ),
                              _buildDetailItem(
                                context,
                                'Description',
                                entry.value.description,
                                Icons.description,
                              ),
                              _buildDetailItem(
                                context,
                                'Onset',
                                entry.value.onSet,
                                Icons.access_time,
                              ),
                              if (entry.value.note != null &&
                                  entry.value.note!.isNotEmpty)
                                _buildDetailItem(
                                  context,
                                  'Notes',
                                  entry.value.note,
                                  Icons.edit_note,
                                ),
                              if (entry.value.severity != null)
                                _buildDetailItem(
                                  context,
                                  'Severity',
                                  entry.value.severity!.display,
                                  Icons.sick,
                                ),
                              if (entry.value.exposureRoute != null)
                                _buildDetailItem(
                                  context,
                                  'Exposure Route',
                                  entry.value.exposureRoute!.display,
                                  Icons.route,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 32),
            ],

            if (allergy.encounter != null) ...[
              Text(
                'Discovery Encounter',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDetailItem(
                        context,
                        'Reason',
                        allergy.encounter!.reason,
                        Icons.assignment,
                      ),
                      _buildDetailItem(
                        context,
                        'Start Date',
                        allergy.encounter!.actualStartDate,
                        Icons.date_range,
                      ),
                      _buildDetailItem(
                        context,
                        'End Date',
                        allergy.encounter!.actualEndDate,
                        Icons.date_range,
                      ),
                      if (allergy.encounter!.specialArrangement != null &&
                          allergy.encounter!.specialArrangement!.isNotEmpty)
                        _buildDetailItem(
                          context,
                          'Special Arrangement',
                          allergy.encounter!.specialArrangement,
                          Icons.handshake,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String? value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.primaryColor.withOpacity(0.8)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,

                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'Not specified',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: theme.colorScheme.onSurface.withOpacity(
                    0.1,
                  ), // Lighter divider
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Confirm Deletion',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you absolutely sure you want to delete this allergy record? This action cannot be undone.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor.withOpacity(0.7),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Delete',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      context.read<AllergyCubit>().deleteAllergy(
        patientId: widget.patientId,
        allergyId: widget.allergyId,
      );
    }
  }

  void _navigateToEdit() async {
    final currentState = context.read<AllergyCubit>().state;
    if (currentState is AllergyDetailsLoaded) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AllergyFormPage(
                patientId: widget.patientId,
                allergy: allergyModel,
              ),
        ),
      );
      if (mounted) {
        context.read<AllergyCubit>().getAllergyDetails(
          patientId: widget.patientId,
          allergyId: widget.allergyId,
        );
      }
    } else {
      ShowToast.showToastError(
        message: 'Cannot edit: Allergy details not loaded.',
      );
    }
  }
}
