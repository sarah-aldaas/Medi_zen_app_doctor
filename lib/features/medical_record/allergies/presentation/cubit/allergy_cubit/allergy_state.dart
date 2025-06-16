part of 'allergy_cubit.dart';

@immutable
sealed class AllergyState {}

final class AllergyInitial extends AllergyState {}

class AllergyLoading extends AllergyState {
  final bool isInitialLoad;
  AllergyLoading({this.isInitialLoad = false});
}

class AllergySuccess extends AllergyState {
  final List<AllergyModel> allergies;
  final bool hasMore;
  AllergySuccess({required this.allergies, required this.hasMore});
}

class AllergyDetailsLoaded extends AllergyState {
  final AllergyModel allergy;
  AllergyDetailsLoaded({required this.allergy});
}

class AllergyCreated extends AllergyState {}

class AllergyUpdated extends AllergyState {}

class AllergyDeleted extends AllergyState {
  final String allergyId;
  AllergyDeleted({required this.allergyId});
}

class AllergyError extends AllergyState {
  final String error;
  AllergyError({required this.error});
}