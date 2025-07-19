import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medication/presentation/pages/my_medications_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medication/presentation/pages/my_medications_of_medication_request_page.dart';
import '../../../../../base/theme/app_color.dart';
import '../../../../../base/widgets/loading_page.dart';
import '../../../../../base/widgets/show_toast.dart';
import '../../data/models/medication_request_model.dart';
import '../cubit/medication_request_cubit/medication_request_cubit.dart';
import '../widgets/delete_medication_request_dialog.dart';
import '../widgets/edit_medication_request_page.dart';

class MedicationRequestDetailsPage extends StatefulWidget {
  final String medicationRequestId;
  final String patientId;
  final String? appointmentId;
  final String? conditionId;

  const MedicationRequestDetailsPage({
    super.key,
    required this.medicationRequestId,
    required this.patientId,
    required this.appointmentId,
     this.conditionId,
  });

  @override
  _MedicationRequestDetailsPageState createState() =>
      _MedicationRequestDetailsPageState();
}

class _MedicationRequestDetailsPageState
    extends State<MedicationRequestDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refresh();
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }



  @override
  void dispose() {
    _tabController.dispose();
    _tabController.removeListener(_handleTabSelection);
    super.dispose();
  }

  void _refresh() {
    context.read<MedicationRequestCubit>().getMedicationRequestDetails(
      patientId: widget.patientId,
      context: context,
      medicationRequestId: widget.medicationRequestId,
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => DeleteMedicationRequestDialog(
        medicationRequestId: widget.medicationRequestId,
        patientId: widget.patientId,
        onConfirm: () {
          context
              .read<MedicationRequestCubit>()
              .deleteMedicationRequest(
            medicationRequestId: widget.medicationRequestId,
            patientId: widget.patientId,
            conditionId: widget.conditionId!,
            context: context,
          )
              .then((_) {
            if (context.read<MedicationRequestCubit>().state
            is MedicationRequestDeleted) {
              Navigator.pop(context);
              Navigator.pop(context);
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "medicationRequestDetailsPage.title".tr(context),
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "medicationRequestDetails.details".tr(context)),
            Tab(text: "medicationRequestDetails.medication".tr(context)),
          ],
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
        ),
        actions: [
          if (widget.appointmentId!=null && _tabController.index==0) ...[
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primaryColor),
              onPressed: () {
                final state = context.read<MedicationRequestCubit>().state;
                if (state is MedicationRequestDetailsSuccess) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMedicationRequestPage(
                        medicationRequest: state.medicationRequest,
                        patientId: widget.patientId,
                        conditionId: widget.conditionId!,
                      ),
                    ),
                  ).then((_) => _refresh());
                }
              },
              tooltip: 'medicationRequestDetailsPage.editTooltip'.tr(context),
            ),
            IconButton(
              icon: Icon(Icons.delete, color:AppColors.primaryColor),
              onPressed: _showDeleteConfirmation,
              tooltip: 'medicationRequestDetailsPage.deleteTooltip'.tr(context),
            ),
          ],
        ],
      ),
      body: BlocConsumer<MedicationRequestCubit, MedicationRequestState>(
        listener: (context, state) {
          if (state is MedicationRequestError) {
            ShowToast.showToastError(
              message: 'medicationRequestDetailsPage.errorToast'.tr(context),
            );
          } else if (state is MedicationRequestDeleted) {
            ShowToast.showToastSuccess(
              message: 'medicationRequestDetailsPage.deletedToast'.tr(context),
            );
          }
        },
        builder: (context, state) {
          if (state is MedicationRequestDetailsSuccess) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(state.medicationRequest),
                if(widget.appointmentId!=null)
                  MyMedicationsOfAppointmentPage(appointmentId: widget.appointmentId!, patientId: widget.patientId, medicationRequestId: widget.medicationRequestId, conditionId: state.medicationRequest.condition!.id!,),
                if(widget.appointmentId==null)
                  MyMedicationsOfMedicationRequestPage(patientId: widget.patientId, medicationRequestId: widget.medicationRequestId, conditionId:state.medicationRequest.condition!.id!,)

              ],
            );
          } else if (state is MedicationRequestLoading) {
            return const Center(child: LoadingPage());
          } else if (state is MedicationRequestError) {
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
                      "medicationRequestDetailsPage.loadErrorText".tr(context),
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'medicationRequestDetailsPage.retryButton'.tr(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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
                "medicationRequestDetailsPage.noDetails".tr(context),
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


  Widget _buildDetailsTab(MedicationRequestModel request) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(request),
          const SizedBox(height: 30),

          _buildInfoSection(
            title: "medicationRequestDetails.requestInfo".tr(context),
            children: [
              _buildDetailRow(label: "medicationRequestDetails.status".tr(context), value: request.status?.display, icon: Icons.info_outline),
              _buildDetailRow(label: "medicationRequestDetails.statusReason".tr(context), value: request.statusReason, icon: Icons.notes),
              _buildDetailRow(
                label: "medicationRequestDetails.statusChanged".tr(context),
                value: request.statusChanged != null ? DateFormat('MMM d, yyyy - hh:mm a').format(DateTime.parse(request.statusChanged!)) : null,
                icon: Icons.calendar_today,
              ),
              _buildDetailRow(label: "medicationRequestDetails.intent".tr(context), value: request.intent?.display, icon: Icons.flag),
              _buildDetailRow(label: "medicationRequestDetails.priority".tr(context), value: request.priority?.display, icon: Icons.priority_high),
            ],
          ),
          const SizedBox(height: 30),

          if (request.condition != null) ...[
            _buildInfoSection(
              title: "medicationRequestDetails.conditionInfo".tr(context),
              children: [
                _buildDetailRow(
                  label: "medicationRequestDetails.condition".tr(context),
                  value: request.condition?.healthIssue,
                  icon: Icons.medical_information,
                ),
                _buildDetailRow(
                  label: "medicationRequestDetails.isChronic".tr(context),
                  value: request.condition?.isChronic == 1 ? 'medicationRequestDetails.yes'.tr(context) : 'medicationRequestDetails.no'.tr(context),
                  icon: Icons.history,
                ),
                _buildDetailRow(label: "medicationRequestDetails.onSetDate".tr(context), value: request.condition?.onSetDate, icon: Icons.date_range),
                _buildDetailRow(label: "medicationRequestDetails.onSetAge".tr(context), value: request.condition?.onSetAge?.toString(), icon: Icons.elderly),
                _buildDetailRow(label: "medicationRequestDetails.recordDate".tr(context), value: request.condition?.recordDate, icon: Icons.receipt),
                _buildDetailRow(
                  label: "medicationRequestDetails.conditionNote".tr(context),
                  value: request.condition?.note,
                  icon: Icons.sticky_note_2_outlined,
                ),
                _buildDetailRow(label: "medicationRequestDetails.summary".tr(context), value: request.condition?.summary, icon: Icons.summarize_outlined),
                _buildDetailRow(label: "medicationRequestDetails.extraNote".tr(context), value: request.condition?.extraNote, icon: Icons.note_add_outlined),
                _buildDetailRow(
                  label: "medicationRequestDetails.clinicalStatus".tr(context),
                  value: request.condition?.clinicalStatus?.display,
                  icon: Icons.bar_chart,
                ),
                _buildDetailRow(
                  label: "medicationRequestDetails.verificationStatus".tr(context),
                  value: request.condition?.verificationStatus?.display,
                  icon: Icons.verified,
                ),
                _buildDetailRow(
                  label: "medicationRequestDetails.bodySite".tr(context),
                  value: request.condition?.bodySite?.display,
                  icon: Icons.sports_handball,
                ),
                _buildDetailRow(label: "medicationRequestDetails.stage".tr(context), value: request.condition?.stage?.display, icon: Icons.stairs),
              ],
            ),
            const SizedBox(height: 30),
            if (request.condition!.encounters != null && request.condition!.encounters!.isNotEmpty) ...[
              _buildInfoSection(
                title: "medicationRequestDetails.encounters".tr(context),
                children:
                request.condition!.encounters!.map((encounter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(label: "medicationRequestDetails.reason".tr(context), value: encounter.reason, icon: Icons.question_mark_outlined),
                        _buildDetailRow(
                          label: "medicationRequestDetails.actualStartDate".tr(context),
                          value:
                          encounter.actualStartDate != null
                              ? DateFormat('MMM d, yyyy - hh:mm a').format(DateTime.parse(encounter.actualStartDate!))
                              : null,
                          icon: Icons.event_available,
                        ),
                        _buildDetailRow(
                          label: "medicationRequestDetails.actualEndDate".tr(context),
                          value:
                          encounter.actualEndDate != null ? DateFormat('MMM d, yyyy - hh:mm a').format(DateTime.parse(encounter.actualEndDate!)) : null,
                          icon: Icons.event_busy_outlined,
                        ),
                        _buildDetailRow(
                          label: "medicationRequestDetails.specialArrangement".tr(context),
                          value: encounter.specialArrangement,
                          icon: Icons.star_outline,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ],

          _buildInfoSection(
            title: "medicationRequestDetails.additionalInfo".tr(context),
            children: [
              _buildDetailRow(
                label: "medicationRequestDetails.courseOfTherapy".tr(context),
                value: request.courseOfTherapyType?.display,
                icon: Icons.directions_walk,
              ),
              _buildDetailRow(
                label: "medicationRequestDetails.repeatsAllowed".tr(context),
                value: request.numberOfRepeatsAllowed?.toString(),
                icon: Icons.repeat,
              ),
              _buildDetailRow(label: "medicationRequestDetails.note".tr(context), value: request.note, icon: Icons.sticky_note_2_outlined),
              _buildDetailRow(
                label: "medicationRequestDetails.doNotPerform".tr(context),
                value:
                request.doNotPerform != null
                    ? (request.doNotPerform == 1 ? 'medicationRequestDetails.yes'.tr(context) : 'medicationRequestDetails.no'.tr(context))
                    : null,
                icon: Icons.block,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(MedicationRequestModel request) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 60),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.medication?.name ?? request.reason ?? "medicationRequestDetails.defaultMedicationRequest".tr(context),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  request.status?.display ?? "medicationRequestDetails.unknownStatus".tr(context),
                  style: TextStyle(fontSize: 15, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildInfoSection({required String title, required List<Widget> children}) {
    final visibleChildren = children.where((widget) => !(widget is SizedBox && widget.key == null)).toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.titel)),
          const Divider(height: 25, thickness: 1.2, color: Colors.grey),
          ...visibleChildren,
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, String? value, required IconData icon}) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.label, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(value, style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildMedicationRequestDetails(
  //     BuildContext context,
  //     MedicationRequestModel request,
  //     ) {
  //   final ColorScheme colorScheme = Theme.of(context).colorScheme;
  //   final TextTheme textTheme = Theme.of(context).textTheme;
  //
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(16.0),
  //           decoration: BoxDecoration(
  //             color: colorScheme.primaryContainer,
  //             borderRadius: BorderRadius.circular(15.0),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: colorScheme.shadow.withOpacity(0.1),
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 5),
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 Icons.receipt_long,
  //                 color: colorScheme.onPrimaryContainer,
  //                 size: 40,
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       request.reason ??
  //                           'medicationRequestDetailsPage.medicationRequestDefaultReason'
  //                               .tr(context),
  //                       style: textTheme.headlineSmall?.copyWith(
  //                         fontWeight: FontWeight.bold,
  //                         color: colorScheme.onPrimaryContainer,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 8),
  //                     _buildStatusBadge(
  //                       context,
  //                       request.status?.display,
  //                       request.status?.code,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         _buildInfoCard(
  //           context,
  //           title: "medicationRequestDetailsPage.requestInformation".tr(
  //             context,
  //           ),
  //           icon: Icons.assignment,
  //           children: [
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.intentLabel",
  //               request.intent?.display,
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.priorityLabel",
  //               request.priority?.display,
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.statusReasonLabel",
  //               request.statusReason,
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.statusChangedLabel",
  //               request.statusChanged,
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         _buildInfoCard(
  //           context,
  //           title: "medicationRequestDetailsPage.conditionInformation".tr(
  //             context,
  //           ),
  //           icon: Icons.medical_information,
  //           children: [
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.conditionLabel",
  //               request.condition?.healthIssue ??
  //                   'medicationRequestDetailsPage.noCondition'.tr(context),
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.clinicalStatusLabel",
  //               request.condition?.clinicalStatus?.display,
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         _buildInfoCard(
  //           context,
  //           title: "medicationRequestDetailsPage.additionalInformation".tr(
  //             context,
  //           ),
  //           icon: Icons.more_horiz,
  //           children: [
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.courseOfTherapyLabel",
  //               request.courseOfTherapyType?.display,
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.repeatsAllowedLabel",
  //               request.numberOfRepeatsAllowed?.toString(),
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.noteLabel",
  //               request.note,
  //             ),
  //             _buildDetailRow(
  //               context,
  //               "medicationRequestDetailsPage.doNotPerformLabel",
  //               request.doNotPerform != null
  //                   ? (request.doNotPerform!
  //                   ? 'medicationRequestDetailsPage.yes'.tr(context)
  //                   : 'medicationRequestDetailsPage.no'.tr(context))
  //                   : null,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  //
  // Widget _buildStatusBadge(
  //     BuildContext context,
  //     String? statusDisplay,
  //     String? statusCode,
  //     ) {
  //   final ColorScheme colorScheme = Theme.of(context).colorScheme;
  //   final TextTheme textTheme = Theme.of(context).textTheme;
  //   Color statusColor = Colors.grey;
  //
  //   switch (statusCode) {
  //     case 'active':
  //       statusColor = Colors.green.shade600;
  //       break;
  //     case 'on-hold':
  //       statusColor = Colors.orange.shade600;
  //       break;
  //     case 'cancelled':
  //       statusColor = Colors.red.shade600;
  //       break;
  //     case 'completed':
  //       statusColor = Colors.blue.shade600;
  //       break;
  //     case 'draft':
  //       statusColor = Colors.grey.shade500;
  //       break;
  //     case 'entered-in-error':
  //       statusColor = Colors.deepOrange.shade600;
  //       break;
  //     case 'stopped':
  //       statusColor = Colors.purple.shade600;
  //       break;
  //     case 'unknown':
  //       statusColor = Colors.brown.shade600;
  //       break;
  //     default:
  //       statusColor = colorScheme.outline;
  //   }
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //     decoration: BoxDecoration(
  //       color: statusColor.withOpacity(0.15),
  //       borderRadius: BorderRadius.circular(20.0),
  //       border: Border.all(color: statusColor, width: 1),
  //     ),
  //     child: Text(
  //       statusDisplay ??
  //           'medicationRequestDetailsPage.notAvailable'.tr(context),
  //       style: textTheme.labelMedium?.copyWith(
  //         color: statusColor,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildInfoCard(
  //     BuildContext context, {
  //       required String title,
  //       required IconData icon,
  //       required List<Widget> children,
  //     }) {
  //   final ColorScheme colorScheme = Theme.of(context).colorScheme;
  //   final TextTheme textTheme = Theme.of(context).textTheme;
  //
  //   return Card(
  //     elevation: 3,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(icon, color: AppColors.secondaryColor, size: 24),
  //               const SizedBox(width: 10),
  //               Text(
  //                 title,
  //                 style: textTheme.titleMedium?.copyWith(
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.primaryColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const Divider(height: 20, thickness: 1),
  //           ...children,
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildDetailRow(BuildContext context, String labelKey, String? value) {
  //   final TextTheme textTheme = Theme.of(context).textTheme;
  //
  //   if (value == null || value.isEmpty) {
  //     return const SizedBox.shrink();
  //   }
  //
  //   final String localizedLabel = labelKey.tr(context);
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(
  //           flex: 2,
  //           child: Text(
  //             "$localizedLabel:",
  //             style: textTheme.bodyMedium?.copyWith(
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColors.cyan1
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           flex: 3,
  //           child: Text(
  //             value,
  //             style: textTheme.bodyMedium?.copyWith(
  //               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}