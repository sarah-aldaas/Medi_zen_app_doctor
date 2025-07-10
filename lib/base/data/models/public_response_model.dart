class PublicResponseModel {
  final bool status;
  final String errNum;
  final String msg;

  PublicResponseModel({
    required this.status,
    required this.errNum,
    required this.msg,
  });

  factory PublicResponseModel.fromJson(Map<String, dynamic> json) {
    return PublicResponseModel(
      status: json['status'] as bool,
      errNum: json['errNum'].toString(),
      msg: json['msg'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'errNum': errNum, 'msg': msg};
  }
}
