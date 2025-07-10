import '../../../features/authentication/data/models/doctor_model.dart';
import 'code_type_model.dart';

class AuthResponseModel {
  final bool status;
  final String errNum;
  final dynamic msg;
  final LoginData? loginData;

  AuthResponseModel({
    required this.status,
    required this.errNum,
    required this.msg,
    this.loginData,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    dynamic parsedMsg = json['msg'];
    if (parsedMsg is Map<String, dynamic>) {
      parsedMsg = parsedMsg;
    } else if (parsedMsg is String) {
      parsedMsg = parsedMsg;
    } else {
      parsedMsg = '';
    }

    return AuthResponseModel(
      status: json['status'] ?? false,
      errNum: json['errNum'].toString(),
      msg: parsedMsg,
      loginData:
          json['loginData'] != null
              ? LoginData.fromJson(json['loginData'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString(),
      'errNum': errNum.toString(),
      'msg': msg,
      'loginData': loginData?.toJson(),
    };
  }
}

class LoginData {
  final String tokenType;
  final String token;
  final DoctorModel doctor;

  LoginData({
    required this.tokenType,
    required this.token,
    required this.doctor,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      tokenType: json['token_type'] as String,
      token: json['token'] as String,
      doctor: DoctorModel.fromJson(
        json['practitioner'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_type': tokenType,
      'token': token,
      'practitioner': doctor.toJson(),
    };
  }
}

class CodesResponseModel {
  final bool status;
  final int errNum;
  final String msg;
  final List<CodeModel> codes;

  CodesResponseModel({
    required this.status,
    required this.errNum,
    required this.msg,
    required this.codes,
  });

  factory CodesResponseModel.fromJson(Map<String, dynamic> json) {
    return CodesResponseModel(
      status: json['status'] ?? false,
      errNum: json['errNum'] ?? 0,
      msg: json['msg'] ?? '',
      codes:
          json.containsKey('codes') && json['codes'].containsKey('data')
              ? (json['codes']['data'] as List<dynamic>?)
                      ?.map(
                        (item) =>
                            CodeModel.fromJson(item as Map<String, dynamic>),
                      )
                      .toList() ??
                  []
              : (json['codes'] as List<dynamic>?)
                      ?.map(
                        (item) =>
                            CodeModel.fromJson(item as Map<String, dynamic>),
                      )
                      .toList() ??
                  [],
    );
  }
}

class CodeTypesResponseModel {
  final bool status;
  final int errNum;
  final String msg;
  final List<CodeTypeModel> codeTypes;

  CodeTypesResponseModel({
    required this.status,
    required this.errNum,
    required this.msg,
    required this.codeTypes,
  });

  factory CodeTypesResponseModel.fromJson(Map<String, dynamic> json) {
    return CodeTypesResponseModel(
      status: json['status'] ?? false,
      errNum: json['errNum'] ?? 0,
      msg: json['msg'] ?? '',
      codeTypes:
          (json['codeTypes'] as List<dynamic>?)
              ?.map(
                (item) => CodeTypeModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
