import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/data/models/service_request_filter.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/pages/service_requests_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/service_request/presentation/widgets/service_request_filter_dialog.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';

import '../../base/theme/app_color.dart';
import 'allergies/data/models/allergy_filter_model.dart';
import 'allergies/presentation/pages/allergy_list_page.dart';
import 'allergies/presentation/widgets/allergy_filter_dialog.dart';
import 'conditions/data/models/conditions_filter_model.dart';
import 'conditions/presentation/pages/conditions_list_page.dart';
import 'conditions/presentation/widgets/condition_filter_dialog.dart';
import 'diagnostic_report/data/models/diagnostic_report_filter_model.dart';
import 'diagnostic_report/presentation/pages/diagnostic_report_list_page.dart';
import 'diagnostic_report/presentation/widgets/diagnostic_report_filter_dialog.dart';
import 'encounters/data/models/encounter_filter_model.dart';
import 'encounters/presentation/widgets/encounter_filter_dialog.dart';
import 'medication/data/models/medication_filter_model.dart';
import 'medication/presentation/pages/my_medications_page.dart';
import 'medication/presentation/widgets/medication_filter_dialog.dart';
import 'medication_request/data/models/medication_request_filter.dart';
import 'medication_request/presentation/pages/my_medication_requests_page.dart';
import 'medication_request/presentation/widgets/medication_request_filter_dialog.dart';

class MedicalRecordPage extends StatefulWidget {
  final PatientModel patientModel;

  const MedicalRecordPage({super.key, required this.patientModel});

  @override
  _MedicalRecordPageState createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EncounterFilterModel _encounterFilter = EncounterFilterModel();
  AllergyFilterModel _allergyFilter = AllergyFilterModel();
  ServiceRequestFilter _serviceRequestFilter = ServiceRequestFilter();
  ConditionsFilterModel _conditionFilter = ConditionsFilterModel();
  MedicationRequestFilterModel _medicationRequestFilter =
      MedicationRequestFilterModel();
  MedicationFilterModel _medicationFilter = MedicationFilterModel();
  DiagnosticReportFilterModel _diagnosticReportFilter =
      DiagnosticReportFilterModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _showEncounterFilterDialog() async {
    final result = await showDialog<EncounterFilterModel>(
      context: context,
      builder:
          (context) => EncounterFilterDialog(currentFilter: _encounterFilter),
    );

    if (result != null) {
      setState(() => _encounterFilter = result);
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

  Future<void> _showMedicationRequestFilterDialog() async {
    final result = await showDialog<MedicationRequestFilterModel>(
      context: context,
      builder:
          (context) => MedicationRequestFilterDialog(
            currentFilter: _medicationRequestFilter,
            patientId: widget.patientModel.id!,
          ),
    );

    if (result != null) {
      setState(() => _medicationRequestFilter = result);
    }
  }

  Future<void> _showMedicationFilterDialog() async {
    final result = await showDialog<MedicationFilterModel>(
      context: context,
      builder:
          (context) => MedicationFilterDialog(
            currentFilter: _medicationFilter,
            patientId: widget.patientModel.id!,
          ),
    );

    if (result != null) {
      setState(() => _medicationFilter = result);
    }
  }

  Future<void> _showDiagnosticReportFilterDialog() async {
    final result = await showDialog<DiagnosticReportFilterModel>(
      context: context,
      builder:
          (context) => DiagnosticReportFilterDialog(
            currentFilter: _diagnosticReportFilter,
          ),
    );

    if (result != null) {
      setState(() => _diagnosticReportFilter = result);
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
          tooltip: 'medicalRecordPage.back'.tr(context),
        ),
        title: Text(
          ('medicalRecordPage.appBarTitle'.tr(context)),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.primaryColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showEncounterFilterDialog,
              tooltip: 'medicalRecordPage.filterEncounters'.tr(context),
            ),
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
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showServiceRequestFilterDialog,
              tooltip: "Filter service request",
            ),
          if (_tabController.index == 3)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showConditionFilterDialog,
              tooltip: "Filter condition",
            ),
          if (_tabController.index == 4)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showMedicationRequestFilterDialog,
              tooltip: "Filter mediation request",
            ),
          if (_tabController.index == 5)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showMedicationFilterDialog,
              tooltip: "Filter mediation",
            ),
          if (_tabController.index == 6)
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppColors.primaryColor,
              ),
              onPressed: _showDiagnosticReportFilterDialog,
              tooltip: "Diagnostic report ",
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primaryColor,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              indicatorColor: AppColors.primaryColor,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          children: [
            EncounterListPage(patientId: widget.patientModel.id!),
            AllergyListPage(
              patientId: widget.patientModel.id!,
              filter: _allergyFilter,
            ),
            ServiceRequestsPage(
              patientId: widget.patientModel.id!,
              filter: _serviceRequestFilter,
            ),
            ConditionsListPage(
              patientId: widget.patientModel.id!,
              filter: _conditionFilter,
            ),
            MyMedicationRequestsPage(
              patientId: widget.patientModel.id!,
              filter: _medicationRequestFilter,
            ),
            MyMedicationsPage(
              patientId: widget.patientModel.id!,
              filter: _medicationFilter,
            ),
            DiagnosticReportListPage(
              patientId: widget.patientModel.id!,
              filter: _diagnosticReportFilter,
            ),
          ],
        ),
      ),
    );
  }
}
