import '../../../../../base/data/models/code_type_model.dart';
import '../../../imaging_study/data/models/imaging_study_model.dart';

class SeriesModel {
  final String? id;
  final String? title;
  final String? description;
  final List<String> images;
  final CodeModel? bodySite;
  final ImagingStudyModel? imagingStudy;

  SeriesModel({
    this.id,
    this.title,
    this.description,
    this.images = const [],
    this.bodySite,
    this.imagingStudy,
  });

  factory SeriesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SeriesModel();

    return SeriesModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      images: json['images'] is List
          ? List<String>.from(
          json['images'].where((x) => x != null).map((x) => x.toString()))
          : const [],
      bodySite: json['body_site'] != null
          ? CodeModel.fromJson(json['body_site'])
          : null,
      imagingStudy: json['imaging_study'] != null
          ? ImagingStudyModel.fromJson(json['imaging_study'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': images,
      'body_site': bodySite?.toJson(),
      'imaging_study': imagingStudy?.toJson(),
    };
  }

  // Optional: Add validation method
  bool get isValid =>
      id != null &&
          title != null &&
          description != null &&
          bodySite != null &&
          imagingStudy != null;

  // Optional: Add copyWith method
  SeriesModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? images,
    CodeModel? bodySite,
    ImagingStudyModel? imagingStudy,
  }) {
    return SeriesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      bodySite: bodySite ?? this.bodySite,
      imagingStudy: imagingStudy ?? this.imagingStudy,
    );
  }


}