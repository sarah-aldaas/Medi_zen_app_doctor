import '../../../../../base/data/models/code_type_model.dart';
import '../../../medication_request/data/models/medication_request_model.dart';

class MedicationModel {
  final String? id;
  final String? name;
  final int? dose;
  final String? doseUnit;
  final DateTime? effectiveMedicationStartDate;
  final DateTime? effectiveMedicationEndDate;
  final String? definition;
  final String? dosageInstructions;
  final String? additionalInstructions;
  final String? patientInstructions;
  final bool? asNeeded;
  final MaxDose? maxDosePerPeriod;
  final String? event;
  final String? when;
  final int? offset;
  final CodeModel? doseForm;
  final CodeModel? status;
  final CodeModel? site;
  final CodeModel? route;
  final CodeModel? offsetUnit;
  final MedicationRequestModel? medicationRequest;

  MedicationModel({
    this.id,
    this.name,
    this.dose,
    this.doseUnit,
    this.effectiveMedicationStartDate,
    this.effectiveMedicationEndDate,
    this.definition,
    this.dosageInstructions,
    this.additionalInstructions,
    this.patientInstructions,
    this.asNeeded,
    this.maxDosePerPeriod,
    this.event,
    this.when,
    this.offset,
    this.doseForm,
    this.status,
    this.site,
    this.route,
    this.offsetUnit,
    this.medicationRequest,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      dose: json['dose'] as int?,
      doseUnit: json['dose_unit']?.toString(),
      effectiveMedicationStartDate: json['effective_medication_start_date'] != null ? DateTime.parse(json['effective_medication_start_date']) : null,
      effectiveMedicationEndDate: json['effective_medication_end_date'] != null ? DateTime.parse(json['effective_medication_end_date']) : null,
      definition: json['definition']?.toString(),
      dosageInstructions: json['dosage_instructions']?.toString(),
      additionalInstructions: json['additional_instructions']?.toString(),
      patientInstructions: json['patient_instructions']?.toString(),
      asNeeded: json['as_needed'] as bool?,
      maxDosePerPeriod: json['max_dose_per_period'] != null ? MaxDose.fromJson(json['max_dose_per_period']) : null,
      event: json['event']?.toString(),
      when: json['when']?.toString(),
      offset: json['offset'] as int?,
      doseForm: json['dose_form'] != null ? CodeModel.fromJson(json['dose_form']) : null,
      status: json['status'] != null ? CodeModel.fromJson(json['status']) : null,
      site: json['site'] != null ? CodeModel.fromJson(json['site']) : null,
      route: json['route'] != null ? CodeModel.fromJson(json['route']) : null,
      offsetUnit: json['offset_unit'] != null ? CodeModel.fromJson(json['offset_unit']) : null,
      medicationRequest: json['medication_request'] != null ? MedicationRequestModel.fromJson(json['medication_request']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'dose_unit': doseUnit,
      'effective_medication_start_date': effectiveMedicationStartDate?.toIso8601String(),
      'effective_medication_end_date': effectiveMedicationEndDate?.toIso8601String(),
      'definition': definition,
      'dosage_instructions': dosageInstructions,
      'additional_instructions': additionalInstructions,
      'patient_instructions': patientInstructions,
      'as_needed': asNeeded,
      'max_dose_per_period': maxDosePerPeriod?.toJson(),
      'event': event,
      'when': when,
      'offset': offset,
      'dose_form': doseForm?.toJson(),
      'status': status?.toJson(),
      'site': site?.toJson(),
      'route': route?.toJson(),
      'offset_unit': offsetUnit,
      'medication_request': medicationRequest?.toJson(),
    };
  }

  Map<String, dynamic> createJson() {
    return {
      if (name != null) 'name': name,
      if (dose != null) 'dose': dose,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (effectiveMedicationStartDate != null) 'effective_medication_start_date': effectiveMedicationStartDate?.toIso8601String(),
      if (effectiveMedicationEndDate != null) 'effective_medication_end_date': effectiveMedicationEndDate?.toIso8601String(),
      if (definition != null) 'definition': definition,
      if (dosageInstructions != null) 'dosage_instructions': dosageInstructions,
      if (additionalInstructions != null) 'additional_instructions': additionalInstructions,
      if (patientInstructions != null) 'patient_instructions': patientInstructions,
      if (asNeeded != null) 'as_needed': asNeeded,
      if (maxDosePerPeriod != null) 'max_dose_per_period': maxDosePerPeriod?.toJson(),
      if (event != null) 'event': event,
      if (when != null) 'when': when,
      if (offset != null) 'offset': offset,
      if (offsetUnit != null) 'offset_unit': offsetUnit?.id,
      if (doseForm != null) 'dose_form': doseForm?.id, // Use ID for creation
      if (site != null) 'site_id': site?.id, // Use ID for creation
      if (route != null) 'route_id': route?.id, // Use ID for creation
      if (medicationRequest != null && medicationRequest!.id != null) 'medication_request_id': medicationRequest!.id,
    };
  }
}

class MaxDose {
  final DoseComponent numerator;
  final DoseComponent denominator;

  MaxDose({required this.numerator, required this.denominator});

  factory MaxDose.fromJson(Map<String, dynamic> json) {
    return MaxDose(numerator: DoseComponent.fromJson(json['numerator']), denominator: DoseComponent.fromJson(json['denominator']));
  }

  Map<String, dynamic> toJson() {
    return {'numerator': numerator.toJson(), 'denominator': denominator.toJson()};
  }
}

class DoseComponent {
  final int value;
  final String unit;

  DoseComponent({required this.value, required this.unit});

  factory DoseComponent.fromJson(Map<String, dynamic> json) {
    return DoseComponent(value: json['value'] as int, unit: json['unit'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit};
  }
}