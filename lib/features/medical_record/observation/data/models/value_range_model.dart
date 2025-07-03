import 'package:medi_zen_app_doctor/features/medical_record/observation/data/models/range_value_model.dart';

class ValueRangeModel {
  final RangeValueModel? low;
  final RangeValueModel? high;

  ValueRangeModel({this.low, this.high});

  factory ValueRangeModel.fromJson(Map<String, dynamic> json) {
    return ValueRangeModel(
      low: json['low'] != null ? RangeValueModel.fromJson(json['low']) : null,
      high: json['high'] != null ? RangeValueModel.fromJson(json['high']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low': low?.toJson(),
      'high': high?.toJson(),
    };
  }

}
