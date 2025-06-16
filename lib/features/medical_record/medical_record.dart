import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_page.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/pages/allergy_list_page.dart';

import 'package:go_router/go_router.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/pages/allergy_list_page.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_page.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';
import '../../base/theme/app_color.dart';
import 'allergies/data/models/allergy_filter_model.dart';
import 'allergies/presentation/widgets/allergy_filter_dialog.dart';
import 'encounters/data/models/encounter_filter_model.dart';
import 'encounters/presentation/widgets/encounter_filter_dialog.dart';

class MedicalRecordPage extends StatefulWidget {
  final PatientModel patientModel;

  const MedicalRecordPage({super.key, required this.patientModel});

  @override
  _MedicalRecordPageState createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EncounterFilterModel _encounterFilter = EncounterFilterModel();
  AllergyFilterModel _allergyFilter = AllergyFilterModel();

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

  Future<void> _showEncounterFilterDialog() async {
    final result = await showDialog<EncounterFilterModel>(context: context, builder: (context) => EncounterFilterDialog(currentFilter: _encounterFilter));

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

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _tabs = [
      'encounters',
      'allergies',
      'condition',
      'observations',
      'diagnosticReports',
      'medicationRequests',
      'chronicDiseases',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Medical record',
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
              icon: const Icon(Icons.filter_list),
              onPressed: _showEncounterFilterDialog,
              tooltip: 'filterEncounters',
            ),
          if (_tabController.index == 1)

            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showAllergyFilterDialog,
              tooltip: 'filterAllergy',
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
            AllergyListPage(patientId: widget.patientModel.id!),
            _buildObservationsList(),
            _buildDiagnosticReportsList(),
            _buildMedicationRequestsList(),
            _buildAllergiesList(),
            _buildChronicDiseasesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildObservationTile(
          observationName: 'الملاحظات',
          value: '120/80 mmHg',
          date: '2023-11-20',
        ),
      ],
    );
 }

  Widget _buildDiagnosticReportsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildDiagnosticReportTile(
          reportName: 'التقارير التشخيصية',
          reportDate: '2023-11-15',
          result: 'نتائج طبيعية.',
        ),
      ],
    );
  }

  Widget _buildMedicationRequestsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildMedicationRequestTile(
          medicationName: 'ميتفورمين',
          startDate: '2020-05-15',
          dosage: '1000 ملغ يوميًا',
        ),
      ],
    );
  }

  Widget _buildAllergiesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildAllergyTile(
          allergyName: 'البنسلين',
          reaction: 'طفح جلدي',
          notes: 'تجنب الأدوية المحتوية على البنسلين.',
        ),
      ],
    );
  }

  Widget _buildChronicDiseasesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildChronicDiseaseTile(
          diseaseName: 'ربو',
          diagnosisDate: '2015-03-10',
          notes: 'يتم التحكم به باستخدام أجهزة الاستنشاق.',
        ),
      ],
    );
  }

  Widget _buildObservationTile({
    required String observationName,
    required String value,
    required String date,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
       boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            observationName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Value: $value', style: TextStyle(fontSize: 16)),
          Text('Date: $date', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReportTile({
    required String reportName,
    required String reportDate,
    required String result,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reportName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Report Date: $reportDate', style: TextStyle(fontSize: 16)),
          Text('Result: $result', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMedicationRequestTile({
    required String medicationName,
    required String startDate,
    required String dosage,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medicationName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Start Date: $startDate', style: TextStyle(fontSize: 16)),
          Text('Dosage: $dosage', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAllergyTile({
    required String allergyName,
    required String reaction,
    required String notes,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            allergyName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Reaction: $reaction', style: TextStyle(fontSize: 16)),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChronicDiseaseTile({
    required String diseaseName,
    required String diagnosisDate,
    required String notes,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            diseaseName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Diagnosis Date: $diagnosisDate',
            style: TextStyle(fontSize: 16),
          ),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

