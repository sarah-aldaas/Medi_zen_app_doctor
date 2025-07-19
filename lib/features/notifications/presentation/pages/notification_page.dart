import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medical_record_for_appointment.dart';
import '../../../../base/widgets/loading_page.dart';
import '../../../../base/widgets/not_found_data_page.dart';
import '../../../../base/widgets/show_toast.dart';
import '../../../medical_record/service_request/presentation/pages/service_request_details_page.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notification_cubit/notification_cubit.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _showUnreadOnly = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialNotifications() {
    _isLoadingMore = false;
    context.read<NotificationCubit>().getMyNotifications(
      context: context,
      isRead: !_showUnreadOnly,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context
          .read<NotificationCubit>()
          .getMyNotifications(
        loadMore: true,
        context: context,
        isRead: !_showUnreadOnly,
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        actions: [
          IconButton(
            icon: Icon(_showUnreadOnly ?  Icons.mark_email_unread:Icons.mark_email_read ),
            onPressed: () {
              setState(() {
                _showUnreadOnly = !_showUnreadOnly;
                _loadInitialNotifications();
              });
            },
            tooltip: _showUnreadOnly
                ? "show_all"
                : "show_unread",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<NotificationCubit, NotificationState>(
          listener: (context, state) {
            if (state is NotificationError) {
              ShowToast.showToastError(message: state.error);
            } else if (state is FCMOperationSuccess) {
              ShowToast.showToastSuccess(message: state.response.msg ?? 'Operation successful');
            }
          },
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: LoadingPage());
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error),
                    ElevatedButton(
                      onPressed: _loadInitialNotifications,
                      child: Text('retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationSuccess || state is NotificationLoading) {
              return _buildContent(state is NotificationSuccess ? state : null);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(NotificationSuccess? state) {
    final notifications = state?.paginatedResponse.paginatedData?.items ?? [];
    final hasMore = state?.hasMore ?? false;

    if (notifications.isEmpty) {
      return NotFoundDataPage();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationCubit>().getMyNotifications(
          context: context,
          isRead: !_showUnreadOnly,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: notifications.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < notifications.length) {
            return _buildNotificationItem(
              notification: notifications[index],
              context: context,
            );
          } else if (hasMore) {
            return  Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LoadingButton(),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required NotificationModel notification,
    required BuildContext context,
  }) {
    final cubit = context.read<NotificationCubit>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final icon = _getNotificationIcon(notification);
    final color = notification.isRead ?
    (isDarkMode ? Colors.grey[600] : Colors.grey[300]) :
    theme.primaryColor;

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context, notification.id);
        }
        return false;
      },
      onDismissed: (direction) {
        cubit.deleteNotification(notificationId: notification.id, context: context,isRead: !_showUnreadOnly);

      },
      child:cubit.state is NotificationOperationLoading? Center(child: LoadingButton(),):Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ?
        (isDarkMode ? Colors.grey[800] : Colors.grey[100]) :
        (isDarkMode ? Colors.grey[900] : null),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              cubit.markNotificationAsRead(
                  notificationId: notification.id,
                  context: context
              );
              _loadInitialNotifications();
            }
            _handleNotificationTap(notification, context);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 30),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Gap(4),
                      Text(
                        _formatDate(notification.sentAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Icon(Icons.brightness_1,
                      color: theme.colorScheme.error,
                      size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String notificationId) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete notification"),
        content: Text("Do you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("delete"),
          ),
        ],
      ),
    ) ?? false;
  }

  IconData _getNotificationIcon(NotificationModel notification) {
    switch (notification.typeNotification) {
      case NotificationType.articleCreated:
        return Icons.article_outlined;
      case NotificationType.allergyCreated:
      case NotificationType.allergyUpdated:
      case NotificationType.allergyDeleted:
        return Icons.warning_amber_outlined;
      case NotificationType.organizationUpdated:
        return Icons.business_outlined;
      case NotificationType.reactionCreated:
      case NotificationType.reactionUpdated:
      case NotificationType.reactionDeleted:
        return Icons.coronavirus_outlined;
      case NotificationType.invoiceCreated:
      case NotificationType.invoiceUpdated:
      case NotificationType.invoiceCanceled:
        return Icons.receipt_outlined;
      case NotificationType.serviceRequestCreated:
      case NotificationType.serviceRequestUpdated:
      case NotificationType.serviceRequestChangedStatus:
      case NotificationType.serviceRequestCanceled:
      case NotificationType.serviceRequestChangedStatusForLabOrRadiology:
        return Icons.medical_services_outlined;
      case NotificationType.observationCreated:
      case NotificationType.observationUpdated:
      case NotificationType.observationChangedStatus:
        return Icons.monitor_heart_outlined;
      case NotificationType.imagingStudyCreated:
      case NotificationType.imagingStudyUpdated:
      case NotificationType.imagingStudyChangedStatus:
        return Icons.scanner_outlined;
      case NotificationType.seriesCreated:
      case NotificationType.seriesUpdated:
        return Icons.collections_outlined;
      case NotificationType.encounterCreated:
      case NotificationType.encounterUpdated:
        return Icons.medical_information_outlined;
      case NotificationType.appointmentCreated:
      case NotificationType.appointmentUpdated:
      case NotificationType.appointmentCanceled:
      case NotificationType.reminderAppointment:
        return Icons.calendar_today_outlined;
      case NotificationType.conditionCreated:
      case NotificationType.conditionUpdated:
      case NotificationType.conditionCanceled:
        return Icons.healing_outlined;
      case NotificationType.medicationRequestCreated:
      case NotificationType.medicationRequestUpdated:
      case NotificationType.medicationRequestCanceled:
      // case NotificationType.reminderMedication:
        return Icons.medication_outlined;
      case NotificationType.medicationCreated:
      case NotificationType.medicationUpdated:
      case NotificationType.medicationCanceled:
      case NotificationType.reminderMedication:
        return Icons.medication_liquid_outlined;
      case NotificationType.diagnosticReportCreated:
      case NotificationType.diagnosticReportUpdated:
      case NotificationType.diagnosticReportCanceled:
      case NotificationType.diagnosticReportFinalized:
        return Icons.description_outlined;
      case NotificationType.complaintCreated:
      case NotificationType.complaintResolved:
      case NotificationType.complaintRejected:
      case NotificationType.complaintClosed:
      case NotificationType.complaintResponded:
        return Icons.report_problem_outlined;
      case NotificationType.dailyHealthTip:
        return Icons.lightbulb_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  void _handleNotificationTap(NotificationModel notification, BuildContext context) {
    switch (notification.typeNotification) {
      case NotificationType.serviceRequestCreated:
      case NotificationType.serviceRequestUpdated:
      case NotificationType.serviceRequestChangedStatus:
      case NotificationType.serviceRequestCanceled:
      case NotificationType.serviceRequestChangedStatusForLabOrRadiology:
        _navigateToServiceRequestDetails(notification.data, context);
        break;
      case NotificationType.appointmentCreated:
      case NotificationType.appointmentUpdated:
      case NotificationType.appointmentCanceled:
      case NotificationType.reminderAppointment:
        _navigateToAppointmentDetails(notification.data, context);
        break;

    // case NotificationType.articleCreated:
      //   _navigateToArticleDetails(notification.data, context);
      //   break;
      // case NotificationType.allergyCreated:
      // case NotificationType.allergyUpdated:
      // case NotificationType.allergyDeleted:
      //   _navigateToAllergyDetails(notification.data, context);
      //   break;
      // case NotificationType.organizationUpdated:
      //   _navigateToOrganizationDetails(notification.data, context);
      //   break;
      // case NotificationType.reactionCreated:
      // case NotificationType.reactionUpdated:
      // case NotificationType.reactionDeleted:
      //   _navigateToReactionDetails(notification.data, context);
      //   break;
      // case NotificationType.invoiceCreated:
      // case NotificationType.invoiceUpdated:
      // case NotificationType.invoiceCanceled:
      //   _navigateToInvoiceDetails(notification.data, context);
      //   break;
        // case NotificationType.observationCreated:
      // case NotificationType.observationUpdated:
      // case NotificationType.observationChangedStatus:
      //   _navigateToObservationDetails(notification.data, context);
      //   break;
      // case NotificationType.imagingStudyCreated:
      // case NotificationType.imagingStudyUpdated:
      // case NotificationType.imagingStudyChangedStatus:
      //   _navigateToImagingStudyDetails(notification.data, context);
      //   break;
      // case NotificationType.seriesCreated:
      // case NotificationType.seriesUpdated:
      //   _navigateToSeriesDetails(notification.data, context);
      //   break;
      // case NotificationType.encounterCreated:
      // case NotificationType.encounterUpdated:
      //   _navigateToEncounterDetails(notification.data, context);
      //   break;
      // case NotificationType.conditionCreated:
      // case NotificationType.conditionUpdated:
      // case NotificationType.conditionCanceled:
      //   _navigateToConditionDetails(notification.data, context);
      //   break;
      // case NotificationType.medicationRequestCreated:
      // case NotificationType.medicationRequestUpdated:
      // case NotificationType.medicationRequestCanceled:
      // // case NotificationType.reminderMedication:
      //   _navigateToMedicationRequestDetails(notification.data, context);
      //   break;
      // case NotificationType.medicationCreated:
      // case NotificationType.medicationUpdated:
      // case NotificationType.medicationCanceled:
      // case NotificationType.reminderMedication:
      //   _navigateToMedicationDetails(notification.data, context);
      //   break;
      // case NotificationType.diagnosticReportCreated:
      // case NotificationType.diagnosticReportUpdated:
      // case NotificationType.diagnosticReportCanceled:
      // case NotificationType.diagnosticReportFinalized:
      //   _navigateToDiagnosticReportDetails(notification.data, context);
      //   break;
      // case NotificationType.complaintCreated:
      // case NotificationType.complaintResolved:
      // case NotificationType.complaintRejected:
      // case NotificationType.complaintClosed:
      // case NotificationType.complaintResponded:
      //   _navigateToComplaintDetails(notification.data, context);
      //   break;
      // case NotificationType.dailyHealthTip:
      //   _showHealthTipDialog(notification, context);
      //   break;
      default:
        _showGenericNotificationDialog(notification, context);
    }
  }

  void _navigateToServiceRequestDetails(NotificationData data, BuildContext context) {
    if (data.serviceRequestId == null) {
      _showErrorDialog(context, 'Service Request ID is missing');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>ServiceRequestDetailsPage(serviceId: data.serviceRequestId!, patientId: data.patientId!, appointmentId: data.appointmentId,),
      ),
    ).then((_){
      _loadInitialNotifications();
    });
  }
  void _navigateToAppointmentDetails(NotificationData data, BuildContext context) {
    if (data.appointmentId == null) {
      _showErrorDialog(context, 'Appointment ID is missing');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MedicalRecordForAppointment(
              patientId: data.patientId!,
              appointmentId: data.appointmentId!,
            ),
      ),
    ).then((_){
      _loadInitialNotifications();
    });
  }
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGenericNotificationDialog(NotificationModel notification, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Text(
            notification.body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }



// void _navigateToArticleDetails(NotificationData data, BuildContext context) {
  //   if (data.articleId == null) {
  //     _showErrorDialog(context, 'Article ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// ArticleDetailsNotificationPage(articleId: data.articleId!),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToAllergyDetails(NotificationData data, BuildContext context) {
  //   if (data.allergyId == null) {
  //     _showErrorDialog(context, 'Allergy ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//AllergyDetailsPage(allergyId: data.allergyId!),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToOrganizationDetails(NotificationData data, BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//OrganizationcDetailsPage(),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToReactionDetails(NotificationData data, BuildContext context) {
  //   if (data.allergyId == null || data.reactionId == null) {
  //     _showErrorDialog(context, 'Allergy or Reaction ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//ReactionDetailsPacge(allergyId: data.allergyId!, reactionId: data.reactionId!,),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToInvoiceDetails(NotificationData data, BuildContext context) {
  //   if (data.encounterId == null) {
  //     _showErrorDialog(context, 'Encounter ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// InvoiceDetailsPage(appointmentId: data.appointmentId!,invoiceId: data.invoiceId!,),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }


  // void _navigateToObservationDetails(NotificationData data, BuildContext context) {
  //   if (data.observationId == null) {
  //     _showErrorDialog(context, 'Observation ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// ObservationDetailsPage(observationId: data.observationId!,serviceId: data.serviceRequestId!,),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToImagingStudyDetails(NotificationData data, BuildContext context) {
  //   if (data.imagingStudyId == null) {
  //     _showErrorDialog(context, 'Imaging Study ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//ImagingStudyDetailsPage(imagingStudyId: data.imagingStudyId!,serviceId: data.serviceRequestId!,),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToSeriesDetails(NotificationData data, BuildContext context) {
  //   if (data.seriesId == null || data.imagingStudyId == null) {
  //     _showErrorDialog(context, 'Series or Imaging Study ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// SeriesDetailsPage(
  //     //     seriesId: data.seriesId!,
  //     //     imagingStudyId: data.imagingStudyId!,
  //     //     serviceId: data.serviceRequestId!,
  //     //   ),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToEncounterDetails(NotificationData data, BuildContext context) {
  //   if (data.encounterId == null) {
  //     _showErrorDialog(context, 'Encounter ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// EncounterDetailsPage(
  //       //   encounterId: data.encounterId!,
  //       // ),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }


  // void _navigateToConditionDetails(NotificationData data, BuildContext context) {
  //   if (data.conditionId == null) {
  //     _showErrorDialog(context, 'Condition ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//ConditionDetailsPage(conditionId: data.conditionId!),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToMedicationRequestDetails(NotificationData data, BuildContext context) {
  //   if (data.medicationRequestId == null) {
  //     _showErrorDialog(context, 'Medication Request ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//MedicationRequestDetailsPage(
  //       //   medicationRequestId: data.medicationRequestId!,
  //       //   // medicationId: data.medicationId,
  //       // ),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToMedicationDetails(NotificationData data, BuildContext context) {
  //   if (data.medicationId == null) {
  //     _showErrorDialog(context, 'Medication ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// MedicationDetailsPage(medicationId: data.medicationId!),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToDiagnosticReportDetails(NotificationData data, BuildContext context) {
  //   if (data.diagnosticReportId == null) {
  //     _showErrorDialog(context, 'Diagnostic Report ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) =>Container()// DiagnosticReportDetailsPage(diagnosticReportId: data.diagnosticReportId!),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _navigateToComplaintDetails(NotificationData data, BuildContext context) {
  //   if (data.complaintId == null) {
  //     _showErrorDialog(context, 'Complaint ID is missing');
  //     return;
  //   }
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Container()//ComplainDetailsPage(complainId: data.complaintId!),
  //     ),
  //   ).then((_){
  //     _loadInitialNotifications();
  //   });
  // }
  //
  // void _showHealthTipDialog(NotificationModel notification, BuildContext context) {
  //   if (notification.data.tip == null || notification.data.tip!.isEmpty) {
  //     _showErrorDialog(context, 'No health tip content available');
  //     return;
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(notification.title),
  //       content: SingleChildScrollView(child: Text(notification.data.tip!)),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }


}