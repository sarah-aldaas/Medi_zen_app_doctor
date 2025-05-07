import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalRecordPage extends StatelessWidget {
  final String patientName;
  final List<Map<String, dynamic>> services = [
    {
      'icon': Icons.system_update_tv,
      'title': 'Encounters',
      'color': const Color(0xFF64B5F6),
      'details':
          'This section displays a history of your medical encounters, including doctor visits, hospital admissions, and outpatient procedures.',
    },
    {
      'icon': Icons.person_search_outlined,
      'title': 'Conditions',
      'color': const Color(0xFF4DB6AC),
      'details':
          'Here you can find a list of your current and past medical conditions, along with relevant notes and diagnoses.',
    },
    {
      'icon': Icons.north,
      'title': 'Observations',
      'color': const Color(0xFF9CCC65),
      'details':
          'This section contains recorded observations such as vital signs (blood pressure, heart rate), lab results, and other physiological measurements.',
    },
    {
      'icon': Icons.call,
      'title': 'Diagnostic Reports',
      'color': const Color(0xFFAA4F6F),
      'details':
          'View your diagnostic reports here, including imaging scans (X-rays, MRIs), pathology reports, and other diagnostic test results.',
    },
    {
      'icon': Icons.medication_outlined,
      'title': 'Medication Requests',
      'color': const Color(0xFFFFA726),
      'details':
          'This area lists your current and past medication prescriptions, including dosage, frequency, and prescribing doctor.',
    },
    {
      'icon': Icons.warning_amber_outlined,
      'title': 'Allergies',
      'color': const Color(0xFFD4E157),
      'details':
          'A record of your known allergies and adverse reactions to medications, food, or other substances.',
    },
    {
      'icon': Icons.healing_outlined,
      'title': 'Chronic Diseases',
      'color': const Color(0xFF7E57C2),
      'details':
          'This section provides information about any chronic medical conditions you may have, along with management plans and treatment history.',
    },
  ];
  final List<Map<String, dynamic>> encountersDataSara = [
    {
      'encounterId': 1,
      'dateTime': DateTime(2025, 2, 2, 9, 30),
      'provider': 'د. أحمد خالد',
      'type': 'مراجعة',
      'reason': 'فحص روتيني سنوي',
      'summary':
          'تم إجراء فحص عام، قياس العلامات الحيوية كانت ضمن المعدل الطبيعي.',
      'notes': 'المريضة بصحة جيدة ولا تشكو من أي أعراض.',
    },
    {
      'encounterId': 2,
      'dateTime': DateTime(2025, 3, 15, 11, 00),
      'provider': 'د. ليلى سعيد',
      'type': 'استشارة',
      'reason': 'شكوى من صداع متكرر',
      'summary': 'تم أخذ تاريخ مرضي مفصل، فحص عصبي مبدئي.',
      'notes':
          'تم وصف مسكنات بسيطة وطلب فحوصات إضافية (صورة دم وفحص نظر) لاستبعاد أسباب أخرى.',
    },
    // ... باقي اللقاءات
  ];

  final List<Map<String, dynamic>> conditionsDataSara = [
    {
      'encounterId': 1,
      'dateTime': DateTime(2025, 2, 2, 9, 30),
      'provider': 'د. أحمد خالد',
      'type': 'مراجعة',
      'reason': 'فحص روتيني سنوي',
      'summary':
          'تم إجراء فحص عام، قياس العلامات الحيوية كانت ضمن المعدل الطبيعي.',
      'notes': 'المريضة بصحة جيدة ولا تشكو من أي أعراض.',
    },
    {
      'encounterId': 2,
      'dateTime': DateTime(2025, 3, 15, 11, 00),
      'provider': 'د. ليلى سعيد',
      'type': 'استشارة',
      'reason': 'شكوى من صداع متكرر',
      'summary': 'تم أخذ تاريخ مرضي مفصل، فحص عصبي مبدئي.',
      'notes':
          'تم وصف مسكنات بسيطة وطلب فحوصات إضافية (صورة دم وفحص نظر) لاستبعاد أسباب أخرى.',
    },
    // ... باقي اللقاءات
  ];
  MedicalRecordPage({Key? key, required this.patientName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildAppBar(context),
              const SizedBox(height: 20),
              Text(
                'Patient Name : $patientName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.separated(
                  itemCount: services.length,
                  separatorBuilder:
                      (BuildContext context, int index) =>
                          const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return _buildServiceItem(
                      context: context,
                      icon: service['icon'] as IconData,
                      title: service['title'] as String,
                      color: service['color'] as Color,
                      details: service['details'] as String,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: Colors.blue[700],
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Medical Record',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required String details,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ServiceDetailsPage(
                  title: title,
                  details: details,
                  color: color,
                  icon: icon,
                  encountersData:
                      title == 'Encounters' ? encountersDataSara : [],
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailsPage extends StatelessWidget {
  final String title;
  final String details;
  final Color color;
  final IconData icon;
  final List<Map<String, dynamic>> encountersData;

  const ServiceDetailsPage({
    Key? key,
    required this.title,
    required this.details,
    required this.color,
    required this.icon,
    this.encountersData = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: 20),
            if (title == 'Encounters' && encountersData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: encountersData.length,
                  itemBuilder: (context, index) {
                    final encounter = encountersData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          'اللقاء رقم: ${encounter['encounterId']} - ${DateFormat('yyyy/MM/dd').format(encounter['dateTime'])}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'النوع: ${encounter['type']}, الطبيب: ${encounter['provider']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الوقت: ${DateFormat('hh:mm a').format(encounter['dateTime'])}',
                                ),
                                Text(
                                  'سبب اللقاء: ${encounter['reason']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  'ملخص الإجراءات:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(encounter['summary'] as String),
                                const SizedBox(height: 8.0),
                                const Text(
                                  'ملاحظات:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(encounter['notes'] as String),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else if (title != 'Encounters')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    details,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
