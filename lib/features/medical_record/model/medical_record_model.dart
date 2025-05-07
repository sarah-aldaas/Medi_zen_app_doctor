class Encounter {
  final int encounterId;
  final DateTime dateTime;
  final String provider;
  final String type;
  final String reason;
  final String summary;
  final String notes;

  Encounter({
    required this.encounterId,
    required this.dateTime,
    required this.provider,
    required this.type,
    required this.reason,
    required this.summary,
    required this.notes,
  });
}
