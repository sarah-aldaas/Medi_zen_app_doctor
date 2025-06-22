import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_page.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';

import 'allergies/presentation/pages/allergy_list_page.dart';

class MedicalRecordForAppointment extends StatefulWidget {
  final PatientModel patientModel;
  final String appointmentId;

  const MedicalRecordForAppointment({
    super.key,
    required this.patientModel,
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
      ('medicalRecordPage.tabs.conditions'.tr(context)),
      ('medicalRecordPage.tabs.observations'.tr(context)),
      ('medicalRecordPage.tabs.diagnosticReports'.tr(context)),
      ('medicalRecordPage.tabs.medicationRequests'.tr(context)),
      ('medicalRecordPage.tabs.chronicDiseases'.tr(context)),
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
            EncounterListPage(
              patientId: widget.patientModel.id!,
              appointmentId: widget.appointmentId,
            ),
            AllergyListPage(
              patientId: widget.patientModel.id!,
              appointmentId: widget.appointmentId,
            ),

            _buildPlaceholderTab(
              ('medicalRecordPage.tabs.conditions'.tr(context)),
            ),
            _buildObservationsList(),
            _buildDiagnosticReportsList(),
            _buildMedicationRequestsList(),
            _buildChronicDiseasesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 60,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            ('medicalRecordPage.common.underConstruction'.tr(context)),
            style: textTheme.headlineSmall?.copyWith(
              color: textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildObservationTile(
          observationName: ('medicalRecordPage.observations.bloodPressure'.tr(
            context,
          )),
          value: '120/80 mmHg',
          date: '2023-11-20',
        ),
      ],
    );
  }

  Widget _buildDiagnosticReportsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDiagnosticReportTile(
          reportName: ('medicalRecordPage.diagnosticReports.generalCheckup'.tr(
            context,
          )),
          reportDate: '2023-11-15',
          result: ('medicalRecordPage.diagnosticReports.normalResults'.tr(
            context,
          )),
        ),
      ],
    );
  }

  Widget _buildMedicationRequestsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMedicationRequestTile(
          medicationName: ('medicalRecordPage.medications.metformin'.tr(
            context,
          )),
          startDate: '2020-05-15',
          dosage: ('medicalRecordPage.medications.metforminDosage'.tr(context)),
        ),
      ],
    );
  }

  Widget _buildConditionsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChronicDiseaseTile(
          diseaseName: ('medicalRecordPage.conditions.commonCold'.tr(context)),
          diagnosisDate: '2023-10-01',
          notes: ('medicalRecordPage.conditions.commonColdNotes'.tr(context)),
        ),
      ],
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

  Widget _buildObservationTile({
    required String observationName,
    required String value,
    required String date,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            observationName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textTheme.titleMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.value'.tr(context))}: $value',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.date')}: $date',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReportTile({
    required String reportName,
    required String reportDate,
    required String result,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reportName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textTheme.titleMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.reportDate'.tr(context))}: $reportDate',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.result'.tr(context))}: $result',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationRequestTile({
    required String medicationName,
    required String startDate,
    required String dosage,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicationName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textTheme.titleMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.startDate'.tr(context))}: $startDate',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.dosage'.tr(context))}: $dosage',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyTile({
    required String allergyName,
    required String reaction,
    required String notes,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allergyName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textTheme.titleMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.reaction'.tr(context))}: $reaction',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.notes'.tr(context))}: $notes',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChronicDiseaseTile({
    required String diseaseName,
    required String diagnosisDate,
    required String notes,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diseaseName,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textTheme.titleMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.diagnosisDate'.tr(context))}: $diagnosisDate',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${('medicalRecordPage.common.notes'.tr(context))}: $notes',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
