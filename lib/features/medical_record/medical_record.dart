import 'package:flutter/material.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:medi_zen_app_doctor/features/medical_record/encounters/presentation/pages/encounter_list_page.dart';
import 'package:medi_zen_app_doctor/features/patients/data/models/patient_model.dart';
import 'package:medi_zen_app_doctor/features/medical_record/allergies/presentation/pages/allergy_list_page.dart';
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
    final result = await showDialog<AllergyFilterModel>(context: context, builder: (context) => AllergyFilterDialog(currentFilter: _allergyFilter));

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
    final List<String> _tabs = ['encounters', 'allergies', 'condition', 'observations', 'diagnosticReports', 'medicationRequests', 'chronicDiseases'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Medical record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primaryColor)),
        centerTitle: true,
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showEncounterFilterDialog,
              tooltip: 'filterEncounters',
            ),
          if (_tabController.index == 1)
            IconButton(icon: const Icon(Icons.filter_list), onPressed: _showAllergyFilterDialog, tooltip: 'filterAllergy'),
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
    return ListView(padding: EdgeInsets.all(16), children: [_buildObservationTile(observationName: 'الملاحظات', value: '120/80 mmHg', date: '2023-11-20')]);
  }

  Widget _buildDiagnosticReportsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildDiagnosticReportTile(reportName: 'التقارير التشخيصية', reportDate: '2023-11-15', result: 'نتائج طبيعية.')],
    );
  }

  Widget _buildMedicationRequestsList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildMedicationRequestTile(medicationName: 'ميتفورمين', startDate: '2020-05-15', dosage: '1000 ملغ يوميًا')],
    );
  }

  Widget _buildAllergiesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildAllergyTile(allergyName: 'البنسلين', reaction: 'طفح جلدي', notes: 'تجنب الأدوية المحتوية على البنسلين.')],
    );
  }

  Widget _buildChronicDiseasesList() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [_buildChronicDiseaseTile(diseaseName: 'ربو', diagnosisDate: '2015-03-10', notes: 'يتم التحكم به باستخدام أجهزة الاستنشاق.')],
    );
  }

  Widget _buildObservationTile({required String observationName, required String value, required String date}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(observationName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Value: $value', style: TextStyle(fontSize: 16)),
          Text('Date: $date', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReportTile({required String reportName, required String reportDate, required String result}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reportName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Report Date: $reportDate', style: TextStyle(fontSize: 16)),
          Text('Result: $result', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMedicationRequestTile({required String medicationName, required String startDate, required String dosage}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medicationName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Start Date: $startDate', style: TextStyle(fontSize: 16)),
          Text('Dosage: $dosage', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAllergyTile({required String allergyName, required String reaction, required String notes}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(allergyName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Reaction: $reaction', style: TextStyle(fontSize: 16)),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildChronicDiseaseTile({required String diseaseName, required String diagnosisDate, required String notes}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(diseaseName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Diagnosis Date: $diagnosisDate', style: TextStyle(fontSize: 16)),
          Text('Notes: $notes', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class MedicalRecordPage extends StatelessWidget {
//   final String patientName;
//
//   // بيانات الخدمات
//   final List<Map<String, dynamic>> services = [
//     {
//       'icon': Icons.system_update_tv,
//       'title': 'Encounters',
//       'color': const Color(0xFF64B5F6),
//       'details':
//           'This section displays a history of your medical encounters...',
//     },
//     {
//       'icon': Icons.person_search_outlined,
//       'title': 'Conditions',
//       'color': const Color(0xFF4DB6AC),
//       'details':
//           'Here you can find a list of your current and past medical conditions...',
//     },
//     {
//       'icon': Icons.north,
//       'title': 'Observations',
//       'color': const Color(0xFF9CCC65),
//       'details':
//           'This section contains recorded observations such as vital signs...',
//     },
//     {
//       'icon': Icons.call,
//       'title': 'Diagnostic Reports',
//       'color': const Color(0xFFAA4F6F),
//       'details': 'View your diagnostic reports here...',
//     },
//     {
//       'icon': Icons.medication_outlined,
//       'title': 'Medication Requests',
//       'color': const Color(0xFFFFA726),
//       'details':
//           'This area lists your current and past medication prescriptions...',
//     },
//     {
//       'icon': Icons.warning_amber_outlined,
//       'title': 'Allergies',
//       'color': const Color(0xFFD4E157),
//       'details': 'A record of your known allergies and adverse reactions...',
//     },
//     {
//       'icon': Icons.healing_outlined,
//       'title': 'Chronic Diseases',
//       'color': const Color(0xFF7E57C2),
//       'details':
//           'This section provides information about any chronic medical conditions...',
//     },
//   ];
//
//   // بيانات اللقاءات
//   final List<Map<String, dynamic>> encountersData = [
//     {
//       'encounterId': 1,
//       'dateTime': DateTime(2023, 1, 15, 9, 30),
//       'provider': 'د. أحمد خالد',
//       'type': 'مراجعة',
//       'reason': 'فحص روتيني',
//       'summary': 'تم إجراء فحص عام، العلامات الحيوية كانت ضمن المعدل.',
//       'notes': 'المريض بصحة جيدة.',
//     },
//     {
//       'encounterId': 2,
//       'dateTime': DateTime(2023, 2, 20, 11, 00),
//       'provider': 'د. ليلى سعيد',
//       'type': 'استشارة',
//       'reason': 'شكوى من صداع',
//       'summary': 'تم إجراء فحص عصبي، الوضع مستقر.',
//       'notes': 'وصف مسكنات.',
//     },
//     {
//       'encounterId': 3,
//       'dateTime': DateTime(2023, 3, 5, 14, 15),
//       'provider': 'د. محمود عادل',
//       'type': 'فحص',
//       'reason': 'متابعة مرض السكري',
//       'summary': 'تم ضبط مستويات السكر.',
//       'notes': 'استمرار على العلاج.',
//     },
//   ];
//
//   MedicalRecordPage({Key? key, required this.patientName}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               _buildAppBar(context),
//               const SizedBox(height: 20),
//               Text(
//                 'Patient Name: $patientName',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: services.length,
//                   separatorBuilder:
//                       (BuildContext context, int index) =>
//                           const SizedBox(height: 15),
//                   itemBuilder: (context, index) {
//                     final service = services[index];
//                     return _buildServiceItem(
//                       context: context,
//                       icon: service['icon'] as IconData,
//                       title: service['title'] as String,
//                       color: service['color'] as Color,
//                       details: service['details'] as String,
//                       encountersData:
//                           service['title'] == 'Encounters'
//                               ? encountersData
//                               : [],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppBar(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         Row(
//           children: <Widget>[
//             IconButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               icon: Icon(
//                 Icons.arrow_back_ios_new_outlined,
//                 color: Colors.blue[700],
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Medical Record',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildServiceItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required Color color,
//     required String details,
//     required List<Map<String, dynamic>> encountersData,
//   }) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder:
//                 (context) => ServiceDetailsPage(
//                   title: title,
//                   details: details,
//                   color: color,
//                   icon: icon,
//                   encountersData: encountersData,
//                 ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Row(
//           children: <Widget>[
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: Colors.white, size: 28),
//             ),
//             const SizedBox(width: 15),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//             const Spacer(),
//             const Icon(Icons.arrow_forward_ios, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ServiceDetailsPage extends StatelessWidget {
//   final String title;
//   final String details;
//   final Color color;
//   final IconData icon;
//   final List<Map<String, dynamic>> encountersData;
//
//   const ServiceDetailsPage({
//     Key? key,
//     required this.title,
//     required this.details,
//     required this.color,
//     required this.icon,
//     this.encountersData = const [],
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: color,
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color, size: 48),
//             ),
//             const SizedBox(height: 20),
//             if (title == 'Encounters' && encountersData.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: encountersData.length,
//                   itemBuilder: (context, index) {
//                     final encounter = encountersData[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(vertical: 8.0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: ExpansionTile(
//                         title: Text(
//                           'اللقاء رقم: ${encounter['encounterId']} - ${DateFormat('yyyy/MM/dd').format(encounter['dateTime'])}',
//                           style: const TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         subtitle: Text(
//                           'النوع: ${encounter['type']}, الطبيب: ${encounter['provider']}',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'الوقت: ${DateFormat('hh:mm a').format(encounter['dateTime'])}',
//                                 ),
//                                 Text(
//                                   'سبب اللقاء: ${encounter['reason']}',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8.0),
//                                 const Text(
//                                   'ملخص الإجراءات:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(encounter['summary'] as String),
//                                 const SizedBox(height: 8.0),
//                                 const Text(
//                                   'ملاحظات:',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(encounter['notes'] as String),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               )
//             else if (title != 'Encounters')
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Details:',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     details,
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
