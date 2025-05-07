import 'package:flutter/material.dart';

import '../services/localization/app_localization_service.dart';

extension GetTranslationFromKey on String {
  tr(BuildContext context) => AppLocalizations.of(context)!.translate(this);
}
