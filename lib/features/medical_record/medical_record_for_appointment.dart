import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/appointment/presentation/pages/appointment_patient_details.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/pages/allergy_list_of_Appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/conditions/presentation/pages/conditions_list_of_appointment.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_filter.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/pages/service_requests_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/widgets/service_request_filter_dialog.dart';
import '../../base/theme/app_color.dart';
import 'allergies/data/models/allergy_filter_model.dart';
import 'allergies/presentation/widgets/allergy_filter_dialog.dart';
import 'conditions/data/models/conditions_filter_model.dart';
import 'conditions/presentation/widgets/condition_filter_dialog.dart';

class MedicalRecordForAppointment extends StatefulWidget {
  final String patientId;
  final String appointmentId;

  const MedicalRecordForAppointment({
    super.key,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  _MedicalRecordForAppointmentState createState() =>
      _MedicalRecordForAppointmentState();
}

class _MedicalRecordForAppointmentState
    extends State<MedicalRecordForAppointment>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AllergyFilterModel _allergyFilter = AllergyFilterModel();
  ServiceRequestFilter _serviceRequestFilter = ServiceRequestFilter();
  ConditionsFilterModel _conditionFilter = ConditionsFilterModel();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _showAllergyFilterDialog() async {
    final result = await showDialog<AllergyFilterModel>(
      context: context,
      builder: (context) => AllergyFilterDialog(currentFilter: _allergyFilter),
    );

    if (result != null) {
      setState(() => _allergyFilter = result);
    }
  }

  Future<void> _showServiceRequestFilterDialog() async {
    final result = await showDialog<ServiceRequestFilter>(
      context: context,
      builder:
          (context) =>
              ServiceRequestFilterDialog(currentFilter: _serviceRequestFilter),
    );

    if (result != null) {
      setState(() => _serviceRequestFilter = result);
    }
  }


  Future<void> _showConditionFilterDialog() async {
    final result = await showDialog<ConditionsFilterModel>(
      context: context,
      builder:
          (context) => ConditionsFilterDialog(currentFilter: _conditionFilter),
    );

    if (result != null) {
      setState(() => _conditionFilter = result);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.primaryColor;

    final List<String> _tabs = [
      'medicalRecordPage.tabs.appointmentDetails'.tr(context),
      'medicalRecordPage.tabs.encounters'.tr(context),
      'medicalRecordPage.tabs.allergies'.tr(context),
      'medicalRecordPage.tabs.serviceRequest'.tr(context),
      'medicalRecordPage.tabs.conditions'.tr(context),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          ('medicalRecordPage.appBarTitle'.tr(context)),
          style:
              theme.appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: theme.appBarTheme.titleTextStyle?.color ?? primaryColor,
              ) ??
              textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: primaryColor,
              ),
        ),
        actions: [
          if (_tabController.index == 2)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showAllergyFilterDialog,
              tooltip: 'medicalRecordPage.filterAllergy'.tr(context),
            ),
          if (_tabController.index == 3)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showServiceRequestFilterDialog,
              tooltip: "Filter service request",
            ),
          if (_tabController.index == 4)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showConditionFilterDialog,
              tooltip: "Filter condition",
            ),

        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              labelColor: primaryColor,
              unselectedLabelColor: textTheme.bodyMedium?.color?.withOpacity(
                0.7,
              ),
              labelStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: textTheme.labelLarge?.copyWith(
                fontSize: 16,
              ),
              indicatorColor: primaryColor,
              tabs: _tabs.map((tabText) => Tab(text: tabText)).toList(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          children: [
            AppointmentPatientDetails(appointmentId: widget.appointmentId),
            EncounterListOfAppointmentPage(
              patientId: widget.patientId,
              appointmentId: widget.appointmentId,
            ),
            AllergyListOfAppointmentPage(
              filter: _allergyFilter,
              patientId: widget.patientId,
              appointmentId: widget.appointmentId,
            ),
            ServiceRequestsOfAppointmentPage(
              patientId: widget.patientId,
              appointmentId: widget.appointmentId,
              filter: _serviceRequestFilter,
            ),
            ConditionsListOfAppointmentPage(
              filter: _conditionFilter,
              patientId: widget.patientId,
              appointmentId: widget.appointmentId,
            ),
          ],
        ),
      ),
    );
  }
}
