part of 'observation_cubit.dart';

abstract class ObservationState extends Equatable {
  const ObservationState();
}

class ObservationInitial extends ObservationState {
  @override
  List<Object> get props => [];
}

class ObservationLoading extends ObservationState {
  @override
  List<Object> get props => [];
}

class ObservationLoaded extends ObservationState {
  final ObservationModel observation;

  const ObservationLoaded(this.observation);

  @override
  List<Object> get props => [observation];
}

class ObservationError extends ObservationState {
  final String message;

  const ObservationError(this.message);

  @override
  List<Object> get props => [message];
}