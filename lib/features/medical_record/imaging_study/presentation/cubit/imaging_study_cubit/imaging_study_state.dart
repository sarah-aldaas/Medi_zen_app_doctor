part of 'imaging_study_cubit.dart';

abstract class ImagingStudyState extends Equatable {
  const ImagingStudyState();
}

class ImagingStudyInitial extends ImagingStudyState {
  @override
  List<Object> get props => [];
}

class ImagingStudyLoading extends ImagingStudyState {
  @override
  List<Object> get props => [];
}

class ImagingStudyLoaded extends ImagingStudyState {
  final ImagingStudyModel imagingStudy;
  // final List<SeriesModel> series;
  // final bool hasMoreSeries;

  const ImagingStudyLoaded({
    required this.imagingStudy,
    // required this.series,
    // required this.hasMoreSeries,
  });

  @override
  List<Object> get props => [imagingStudy,];
}

class ImagingStudyError extends ImagingStudyState {
  final String message;

  const ImagingStudyError(this.message);

  @override
  List<Object> get props => [message];
}