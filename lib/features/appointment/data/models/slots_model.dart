
import '../../../../base/data/models/code_type_model.dart';
import '../../../schedule/data/model/schedule_model.dart';

class AllSlotModel {
  final bool status;
  final int errNum;
  final String msg;
  final List<SlotModel>? listSlots;

  AllSlotModel({required this.status, required this.errNum, required this.msg, this.listSlots});

  factory AllSlotModel.fromJson(Map<String, dynamic> json) {
    return AllSlotModel(
      status: json['status'] ?? false,
      errNum: json['errNum'] ?? 0,
      msg: json['msg'] ?? '',
      listSlots: (json['slots'] as List<dynamic>?)?.map((item) => SlotModel.fromJson(item as Map<String, dynamic>)).toList() ?? [],
    );
  }

}

class SlotModel {
  final String id;
  final String startDate;
  final String endDate;
  final String? comment;
  final ScheduleModel? schedule;
  final CodeModel status;

  SlotModel({required this.id, required this.startDate, required this.endDate, this.comment, required this.schedule, required this.status});

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'].toString(),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      comment: json['comment'] as String?,
      schedule:json['schedule']!=null? ScheduleModel.fromJson(json['schedule'] as Map<String, dynamic>):null,
      status: CodeModel.fromJson(json['status'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'start_date': startDate, 'end_date': endDate, 'comment': comment, 'schedule': schedule!.toJson(), 'status': status.toJson()};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotModel &&
          id == other.id &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          comment == other.comment &&
          schedule == other.schedule &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, startDate, endDate, comment, schedule, status);
}
