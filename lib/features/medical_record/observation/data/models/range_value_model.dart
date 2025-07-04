class RangeValueModel {
  final String? value;
  final String? unit;

  RangeValueModel({this.value, this.unit});

  factory RangeValueModel.fromJson(Map<String, dynamic> json) {
    return RangeValueModel(value: json['value']?.toString(), unit: json['unit']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }

}
