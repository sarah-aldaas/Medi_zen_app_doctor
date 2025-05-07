abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int currentImage;

  HomeLoaded(this.currentImage);
}

class HomeError extends HomeState {
  final String errorMessage;

  HomeError(this.errorMessage);
}
