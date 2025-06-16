import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/base/widgets/loading_page.dart';
import '../../../../../base/data/models/code_type_model.dart';
import '../../../encounters/presentation/pages/encounter_details_page.dart';
import '../../../reactions/presentation/pages/reaction_details_page.dart';
import '../../../reactions/presentation/widgets/reaction_list_item.dart';
import '../../data/models/allergy_model.dart';
import '../cubit/allergy_cubit/allergy_cubit.dart';

class AllergyDetailsPage extends StatefulWidget {
  final String allergyId;
  final String patientId;

  const AllergyDetailsPage({super.key, required this.allergyId, required this.patientId});

  @override
  State<AllergyDetailsPage> createState() => _AllergyDetailsPageState();
}

class _AllergyDetailsPageState extends State<AllergyDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadAllergyDetails();
  }

  void _loadAllergyDetails() {
    context.read<AllergyCubit>().getAllergyDetails(patientId: widget.patientId, allergyId: widget.allergyId);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: theme.appBarTheme.iconTheme?.color), onPressed: () => Navigator.pop(context)),
        title: Text(
          'allergiesPage.allergyDetails'.tr(context),
          style:
          theme.appBarTheme.titleTextStyle?.copyWith(
            // Title style from theme
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ) ??
              TextStyle(color: theme.primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AllergyCubit, AllergyState>(
        listener: (context, state) {
          if (state is AllergyError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error, style: TextStyle(color: theme.colorScheme.onError)), backgroundColor: theme.colorScheme.error));
          }
        },
        builder: (context, state) {
          if (state is AllergyLoading) {
            return Center(child: LoadingPage());
          } else if (state is AllergyDetailsLoaded) {
            return _buildAllergyDetails(context, state.allergy);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'allergiesPage.failedToLoadAllergyDetails'.tr(context), // Translated
                    style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadAllergyDetails,
                    child: Text('allergiesPage.tapToRetry'.tr(context), style: TextStyle(fontSize: 16, color: theme.primaryColor)),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAllergyDetails(BuildContext context, AllergyModel allergy) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    allergy.name ?? 'allergiesPage.unknownAllergy'.tr(context), // Translated
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                  ),
                ),
                const SizedBox(width: 12),
                _buildCriticalityChip(context, allergy.criticality),
              ],
            ),
          ),

          _buildInfoCard(
            context: context,
            title: 'allergiesPage.basicInformation'.tr(context),
            children: [
              _buildDetailRow(context, Icons.info_outline, 'allergiesPage.type'.tr(context), allergy.type?.display),
              _buildDetailRow(context, Icons.category_outlined, 'allergiesPage.category'.tr(context), allergy.category?.display),
              _buildDetailRow(context, Icons.medical_services_outlined, 'allergiesPage.clinicalStatus'.tr(context), allergy.clinicalStatus?.display),
              _buildDetailRow(context, Icons.verified_outlined, 'allergiesPage.verification'.tr(context), allergy.verificationStatus?.display),
              _buildDetailRow(
                context,
                Icons.person_outline,
                'allergiesPage.onsetAge'.tr(context),
                '${allergy.onSetAge ?? 'allergiesPage.notApplicable'.tr(context)} ${'allergiesPage.yearsAbbreviation'.tr(context)}',
              ),
              if (allergy.lastOccurrence != null)
                _buildDetailRow(
                  context,
                  Icons.event_note_outlined,
                  'allergiesPage.lastOccurrence'.tr(context),
                  DateFormat('MMM d, y').format(DateTime.parse(allergy.lastOccurrence!)),
                ),
              if (allergy.note?.isNotEmpty ?? false) _buildDetailRow(context, Icons.notes_outlined, 'allergiesPage.notes'.tr(context), allergy.note),
            ],
          ),
          const SizedBox(height: 16),

          if ( //widget.appointmentId == null &&
          (allergy.reactions?.isNotEmpty ?? false)) ...[
            Text(
              'allergiesPage.reactions'.tr(context),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allergy.reactions!.length,
              itemBuilder: (context, index) {
                final reaction = allergy.reactions![index];

                return ReactionListItem(
                  reaction: reaction,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReactionDetailsPage(patientId: widget.patientId, allergyId: allergy.id!, reactionId: reaction.id!),
                      ),
                    ).then((_) => _loadAllergyDetails());
                  },
                );
              },
            ),
          ],

          // else if (widget.appointmentId != null) ...[
          //   const SizedBox(height: 16),
          //   Card(
          //     elevation: 4,
          //     color: theme.cardColor,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //     clipBehavior: Clip.antiAlias,
          //     child: InkWell(
          //       onTap: () {},
          //       child: Padding(
          //         padding: const EdgeInsets.all(16.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               'allergiesPage.viewAllReactions'.tr(
          //                 context,
          //               ), // Translated
          //               style: theme.textTheme.titleMedium?.copyWith(
          //                 fontWeight: FontWeight.bold,
          //                 color: theme.primaryColor,
          //               ),
          //             ),
          //             Icon(
          //               Icons.arrow_forward_ios,
          //               color: theme.iconTheme.color,
          //               size: 20,
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
          if (allergy.encounter != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              context: context,
              title: 'allergiesPage.encounterInformation'.tr(context),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EncounterDetailsPage(patientId: widget.patientId, encounterId: allergy.encounter!.id!)),
                    ).then((_) => _loadAllergyDetails());
                  },
                  icon: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
                  tooltip: 'allergiesPage.viewEncounterDetails'.tr(context),
                ),
              ],
              children: [
                _buildDetailRow(context, Icons.local_hospital_outlined, 'allergiesPage.reason'.tr(context), allergy.encounter?.reason),
                if (allergy.encounter?.actualStartDate != null)
                  _buildDetailRow(
                    context,
                    Icons.calendar_month_outlined,
                    'allergiesPage.date'.tr(context),
                    DateFormat('MMM d, y - h:mm a').format(DateTime.parse(allergy.encounter!.actualStartDate!)),
                  ),
                if (allergy.encounter?.specialArrangement?.isNotEmpty ?? false)
                  _buildDetailRow(context, Icons.note_alt_outlined, 'allergiesPage.specialNotes'.tr(context), allergy.encounter?.specialArrangement),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({required BuildContext context, required String title, List<Widget>? actions, required List<Widget> children}) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                if (actions != null) Row(children: actions),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String? value) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.iconTheme.color?.withOpacity(0.7)),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodySmall?.color))),
          Expanded(
            child: Text(
              value ?? 'allergiesPage.notSpecified'.tr(context),
              style: TextStyle(fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalityChip(BuildContext context, CodeModel? criticality) {
    final ThemeData theme = Theme.of(context);
    Color chipColor;
    String displayText;

    switch (criticality?.code?.toLowerCase()) {
      case 'high':
        chipColor = Colors.red.shade600;
        displayText = 'allergiesPage.high'.tr(context);
        break;
      case 'moderate':
        chipColor = Colors.orange.shade600;
        displayText = 'allergiesPage.moderate'.tr(context);
        break;
      case 'low':
        chipColor = Colors.green.shade600;
        displayText = 'allergiesPage.low'.tr(context);
        break;
      default:
        chipColor = theme.textTheme.bodySmall?.color?.withOpacity(0.5) ?? Colors.grey.shade500;
        displayText = 'allergiesPage.notApplicable'.tr(context);
    }

    return Chip(
      label: Text(displayText, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}