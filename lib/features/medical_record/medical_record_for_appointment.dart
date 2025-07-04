import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/pages/allergy_list_of_Appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/conditions/presentation/pages/conditions_list_of_appointment.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medication/presentation/pages/my_medications_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/medication_request/presentation/pages/my_medication_requests_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_filter.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/pages/service_requests_of_appointment_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/widgets/service_request_filter_dialog.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';

import '../../base/theme/app_color.dart';
import 'allergies/data/models/allergy_filter_model.dart';
import 'allergies/presentation/pages/allergy_list_page.dart';
import 'allergies/presentation/widgets/allergy_filter_dialog.dart';
import 'conditions/data/models/conditions_filter_model.dart';
import 'conditions/presentation/widgets/condition_filter_dialog.dart';
import 'medication/data/models/medication_filter_model.dart';
import 'medication/presentation/widgets/medication_filter_dialog.dart';
import 'medication_request/data/models/medication_request_filter.dart';
import 'medication_request/presentation/widgets/medication_request_filter_dialog.dart';

class MedicalRecordForAppointment extends StatefulWidget {
  final PatientModel patientModel;
  final String appointmentId;

  const MedicalRecordForAppointment({super.key, required this.patientModel, required this.appointmentId});

  @override
  _MedicalRecordForAppointmentState createState() => _MedicalRecordForAppointmentState();
}

class _MedicalRecordForAppointmentState extends State<MedicalRecordForAppointment> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AllergyFilterModel _allergyFilter = AllergyFilterModel();
  ServiceRequestFilter _serviceRequestFilter = ServiceRequestFilter();
  ConditionsFilterModel _conditionFilter = ConditionsFilterModel();
  MedicationRequestFilterModel _medicationRequestFilter = MedicationRequestFilterModel();
  MedicationFilterModel _medicationFilter = MedicationFilterModel();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _showAllergyFilterDialog() async {
    final result = await showDialog<AllergyFilterModel>(context: context, builder: (context) => AllergyFilterDialog(currentFilter: _allergyFilter));

    if (result != null) {
      setState(() => _allergyFilter = result);
    }
  }

  Future<void> _showServiceRequestFilterDialog() async {
    final result = await showDialog<ServiceRequestFilter>(
      context: context,
      builder: (context) => ServiceRequestFilterDialog(currentFilter: _serviceRequestFilter),
    );

    if (result != null) {
      setState(() => _serviceRequestFilter = result);
    }
  }

  Future<void> _showConditionFilterDialog() async {
    final result = await showDialog<ConditionsFilterModel>(context: context, builder: (context) => ConditionsFilterDialog(currentFilter: _conditionFilter));

    if (result != null) {
      setState(() => _conditionFilter = result);
    }
  }

  Future<void> _showMedicationRequestFilterDialog() async {
    final result = await showDialog<MedicationRequestFilterModel>(
      context: context,
      builder: (context) => MedicationRequestFilterDialog(currentFilter: _medicationRequestFilter, patientId: widget.patientModel.id!),
    );

    if (result != null) {
      setState(() => _medicationRequestFilter = result);
    }
  }

  Future<void> _showMedicationFilterDialog() async {
    final result = await showDialog<MedicationFilterModel>(
      context: context,
      builder: (context) => MedicationFilterDialog(currentFilter: _medicationFilter, patientId: widget.patientModel.id!),
    );

    if (result != null) {
      setState(() => _medicationFilter = result);
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
    final onSurfaceColor = theme.colorScheme.onSurface;

    final List<String> _tabs = [
      ('medicalRecordPage.tabs.encounters'.tr(context)),
      ('medicalRecordPage.tabs.allergies'.tr(context)),
      'medicalRecordPage.tabs.serviceRequest'.tr(context),
      'medicalRecordPage.tabs.conditions'.tr(context),
      'medicalRecordPage.tabs.medicationRequests'.tr(context),
      'medicalRecordPage.tabs.medication'.tr(context),
      'medicalRecordPage.tabs.diagnosticReports'.tr(context),
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
              textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22, color: primaryColor),
        ),
        actions: [
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showAllergyFilterDialog,
              tooltip: 'medicalRecordPage.filterAllergy'.tr(context),
            ),
          if (_tabController.index == 2)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showServiceRequestFilterDialog,
              tooltip: "Filter service request",
            ),
          if (_tabController.index == 3)
            IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showConditionFilterDialog,
                tooltip: "Filter condition"
            ),
          if (_tabController.index == 4)
            IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showMedicationRequestFilterDialog,
                tooltip: "Filter mediation request"
            ),
          if (_tabController.index == 5)
            IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showMedicationFilterDialog,
                tooltip: "Filter mediation"
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
              unselectedLabelColor: textTheme.bodyMedium?.color?.withOpacity(0.7),
              labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
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
            EncounterListOfAppointmentPage(patientId: widget.patientModel.id!, appointmentId: widget.appointmentId),
            AllergyListOfAppointmentPage(filter: _allergyFilter, patientId: widget.patientModel.id!, appointmentId: widget.appointmentId),
            ServiceRequestsOfAppointmentPage(patientId: widget.patientModel.id!, appointmentId: widget.appointmentId, filter: _serviceRequestFilter),
            ConditionsListOfAppointmentPage(filter: _conditionFilter, patientId: widget.patientModel.id!, appointmentId: widget.appointmentId),
            MyMedicationRequestsOfAppointmentPage(filter: _medicationRequestFilter, patientId: widget.patientModel.id!, appointmentId: widget.appointmentId),
            MyMedicationsOfAppointmentPage(patientId: widget.patientModel.id!, appointmentId: widget.appointmentId, filter: _medicationFilter),
            _buildChronicDiseasesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChronicDiseasesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChronicDiseaseTile(
          diseaseName: ('medicalRecordPage.chronicDiseases.asthma'.tr(context)),
          diagnosisDate: '2015-03-10',
          notes: ('medicalRecordPage.chronicDiseases.asthmaNotes'.tr(context)),
        ),
      ],
    );
  }

  Widget _buildObservationTile({required String observationName, required String value, required String date}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(observationName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: textTheme.titleMedium?.color)),
          Text(
            '${('medicalRecordPage.common.value'.tr(context))}: $value',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
          Text('${('medicalRecordPage.common.date')}: $date', style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReportTile({required String reportName, required String reportDate, required String result}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reportName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: textTheme.titleMedium?.color)),
          Text(
            '${('medicalRecordPage.common.reportDate'.tr(context))}: $reportDate',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
          Text(
            '${('medicalRecordPage.common.result'.tr(context))}: $result',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationRequestTile({required String medicationName, required String startDate, required String dosage}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medicationName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: textTheme.titleMedium?.color)),
          Text(
            '${('medicalRecordPage.common.startDate'.tr(context))}: $startDate',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
          Text(
            '${('medicalRecordPage.common.dosage'.tr(context))}: $dosage',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyTile({required String allergyName, required String reaction, required String notes}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(allergyName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: textTheme.titleMedium?.color)),
          Text(
            '${('medicalRecordPage.common.reaction'.tr(context))}: $reaction',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
          Text(
            '${('medicalRecordPage.common.notes'.tr(context))}: $notes',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  Widget _buildChronicDiseaseTile({required String diseaseName, required String diagnosisDate, required String notes}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(diseaseName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: textTheme.titleMedium?.color)),
          Text(
            '${('medicalRecordPage.common.diagnosisDate'.tr(context))}: $diagnosisDate',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
          Text(
            '${('medicalRecordPage.common.notes'.tr(context))}: $notes',
            style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}
