class DaysWorkDoctorModel {
  final bool status;
  final int errNum;
  final String msg;
  final List<DoctorAvailability> availability;

  DaysWorkDoctorModel({
    required this.status,
    required this.errNum,
    required this.msg,
    required this.availability,
  });

  DaysWorkDoctorModel copyWith({
    bool? status,
    int? errNum,
    String? msg,
    List<DoctorAvailability>? availability,
  }) {
    return DaysWorkDoctorModel(
      status: status ?? this.status,
      errNum: errNum ?? this.errNum,
      msg: msg ?? this.msg,
      availability: availability ?? this.availability,
    );
  }
  factory DaysWorkDoctorModel.fromJson(Map<String, dynamic> json) {
    return DaysWorkDoctorModel(
      status: json['status'] as bool,
      errNum: json['errNum'] as int,
      msg: json['msg'] as String,
      availability:json['availability']!=null? (json['availability'] as List)
          .map((item) => DoctorAvailability.fromJson(item as Map<String, dynamic>))
          .toList():[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'errNum': errNum,
      'msg': msg,
      'availability': availability.map((item) => item.toJson()).toList(),
    };
  }
}

class DoctorAvailability {
  final DateTime date;
  final int status; // 0 = unavailable, 1 = available

  DoctorAvailability({
    required this.date,
    required this.status,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      date: DateTime.parse(json['date']),
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'status': status,
    };
  }

  bool get isAvailable => status == 1;
}