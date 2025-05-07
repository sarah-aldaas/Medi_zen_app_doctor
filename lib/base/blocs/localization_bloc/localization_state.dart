part of 'localization_bloc.dart';

class LocalizationState extends Equatable {
  final Locale locale;

  const LocalizationState(this.locale);

  LocalizationState copyWith(Locale locale) => LocalizationState(locale);

  @override
  List<Object> get props => [locale];
}
