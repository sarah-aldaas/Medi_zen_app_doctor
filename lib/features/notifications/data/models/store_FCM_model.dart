class StoreFCMModel {
  final String tokenFCM;
  String appName = "medizen_practitioner";
  final String platform;
  final String deviceName;

  StoreFCMModel({required this.tokenFCM, this.appName = "medizen_practitioner", required this.platform, required this.deviceName});

  factory StoreFCMModel.fromJson(Map<String, dynamic> json) {
    return StoreFCMModel(tokenFCM: json['token'], appName: json['app_name'], platform: json['platform'], deviceName: json['device_name']);
  }

  Map<String, dynamic> toJson() {
    return {'token': tokenFCM, 'app_name': "medizen_practitioner", 'platform': platform.toLowerCase(), 'device_name': deviceName};
  }

  Map<String, dynamic> deleteJson() {
    return {'token': tokenFCM, 'app_name': "medizen_practitioner"};
  }
}
