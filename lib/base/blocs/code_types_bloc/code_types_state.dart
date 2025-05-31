part of 'code_types_cubit.dart';

@immutable
abstract class CodeTypesState {}

class CodeTypesInitial extends CodeTypesState {}

class CodeTypesLoading extends CodeTypesState {}

class CodeTypesSuccess extends CodeTypesState {
  final List<CodeTypeModel> codeTypes;
  final List<CodeModel>? codes;

  CodeTypesSuccess({required this.codeTypes, this.codes});
}

class CodeTypesError extends CodeTypesState {
  final String error;

  CodeTypesError({required this.error});
}

class CodesLoading extends CodeTypesState {}

class CodesSuccess extends CodeTypesState {
  final List<CodeModel> codes;

  CodesSuccess({required this.codes});
}

class CodesError extends CodeTypesState {
  final String error;

  CodesError({required this.error});
}
