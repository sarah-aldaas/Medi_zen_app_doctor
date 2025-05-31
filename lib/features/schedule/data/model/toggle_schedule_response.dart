import 'package:medi_zen_app_doctor/base/data/models/code_type_model.dart';

class ToggleScheduleResponse {
  final bool status;
  final int errNum;
  final String msg;
  final List<BookedSlot> bookedSlots;

  ToggleScheduleResponse({
    required this.status,
    required this.errNum,
    required this.msg,
    required this.bookedSlots,
  });

  factory ToggleScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ToggleScheduleResponse(
      status: json['status'],
      errNum: json['errNum'],
      msg: json['msg'],
      bookedSlots:json['booked_slots'] !=null? (json['booked_slots'] as List)
          .map((slot) => BookedSlot.fromJson(slot))
          .toList():[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'errNum': errNum,
      'msg': msg,
      'booked_slots': bookedSlots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class BookedSlot {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String comment;
  final CodeModel status;

  BookedSlot({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.comment,
    required this.status,
  });

  factory BookedSlot.fromJson(Map<String, dynamic> json) {
    return BookedSlot(
      id: json['id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      comment: json['comment'],
      status: CodeModel.fromJson(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'comment': comment,
      'status': status.toJson(),
    };
  }
}