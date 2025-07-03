part of 'series_cubit.dart';

abstract class SeriesState extends Equatable {
  const SeriesState();
}

class SeriesInitial extends SeriesState {
  @override
  List<Object> get props => [];
}

class SeriesLoading extends SeriesState {
  @override
  List<Object> get props => [];
}

class SeriesLoaded extends SeriesState {
  final SeriesModel series;

  const SeriesLoaded(this.series);

  @override
  List<Object> get props => [series];
}

class SeriesError extends SeriesState {
  final String message;

  const SeriesError(this.message);

  @override
  List<Object> get props => [message];
}