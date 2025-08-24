import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../constant/storage_key.dart';
import '../../services/di/injection_container_common.dart';
import '../../services/storage/storage_service.dart';

part 'localization_event.dart';
part 'localization_state.dart';

class LocalizationBloc extends Bloc<LocalizationEvent, LocalizationState> {
  LocalizationBloc() : super(const LocalizationState(Locale("ar"))) {
    String? lang =
        serviceLocator<StorageService>().getFromDisk(StorageKey.lang) ?? "ar";
    emit(LocalizationState(Locale(lang!)));
    on<ChangeLanguageEvent>(_onChangeLanguageEvent);
  }

  _onChangeLanguageEvent(
    ChangeLanguageEvent event,
    Emitter<LocalizationState> emit,
  ) {
    serviceLocator<StorageService>().saveToDisk(
      StorageKey.lang,
      event.locale.languageCode,
    );
    emit(state.copyWith(event.locale));
  }

  bool isArabic() {
    return state.locale == const Locale("ar");
  }

  bool isEnglish() {
    return state.locale == const Locale("en");
  }
}
