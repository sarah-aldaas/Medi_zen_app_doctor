import 'package:bloc/bloc.dart';

import '../model/medical_record_model.dart';
import 'medical_record_state.dart';

class MedicalRecordCubit extends Cubit<MedicalRecordState> {
  MedicalRecordCubit()
    : super(MedicalRecordState(encounters: _initialEncounters()));

  static List<Encounter> _initialEncounters() {
    return [
      Encounter(
        encounterId: 1,
        dateTime: DateTime(2025, 2, 2, 9, 30),
        provider: 'د. أحمد خالد',
        type: 'مراجعة',
        reason: 'فحص روتيني سنوي',
        summary:
            'تم إجراء فحص عام، قياس العلامات الحيوية كانت ضمن المعدل الطبيعي.',
        notes: 'المريضة بصحة جيدة ولا تشكو من أي أعراض.',
      ),
      Encounter(
        encounterId: 2,
        dateTime: DateTime(2025, 3, 15, 11, 00),
        provider: 'د. ليلى سعيد',
        type: 'استشارة',
        reason: 'شكوى من صداع متكرر',
        summary: 'تم أخذ تاريخ مرضي مفصل، فحص عصبي مبدئي.',
        notes: 'تم وصف مسكنات بسيطة وطلب فحوصات إضافية.',
      ),
      // المزيد من اللقاءات...
    ];
  }
}
