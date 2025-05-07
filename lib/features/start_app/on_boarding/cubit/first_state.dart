abstract class FirstState {}

class FirstInitial extends FirstState {}

class FirstPageIndexChanged extends FirstState {
  final int index;

  FirstPageIndexChanged(this.index);
}

class FirstNavigationToLogin extends FirstState {}

class FirstNavigationToFirst extends FirstState {}