class CodeTypeModel {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CodeTypeModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CodeTypeModel.fromJson(Map<String, dynamic> json) {
    return CodeTypeModel(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CodeTypeModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// models/code_model.dart
class CodeModel {
  final String id;
  final String code;
  final String display;
  final String description;
  final String codeTypeId;
  final String? createdAt;
  final String? updatedAt;
  CodeTypeModel? codeTypeModel;

  CodeModel({
    required this.id,
    required this.code,
    required this.display,
    required this.description,
    required this.codeTypeId,
    this.createdAt,
    this.updatedAt,
    this.codeTypeModel,
  });

  factory CodeModel.fromJson(Map<String, dynamic> json) {
    return CodeModel(
      id: json['id'].toString(),
      code: json['code'].toString(),
      display: json['display'].toString(),
      description: json['description'].toString(),
      codeTypeId: json['code_type_id'].toString(),
      createdAt: json['created_at'] != null ? json['created_at'].toString() : "",
      updatedAt: json['updated_at'] != null ? json['updated_at'].toString() : "",
      codeTypeModel: json["code_type"] != null
          ? CodeTypeModel.fromJson(json["code_type"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'code': code.toString(),
      'display': display.toString(),
      'description': description.toString(),
      'code_type_id': codeTypeId.toString(),
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CodeModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
