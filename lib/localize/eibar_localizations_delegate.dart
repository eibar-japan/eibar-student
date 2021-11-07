import 'dart:async';
import 'package:flutter/material.dart';
import 'eibar_localizations.dart';

class EibarLocalizationsDelegate
    extends LocalizationsDelegate<EibarLocalizations> {
  const EibarLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<EibarLocalizations> load(Locale locale) =>
      EibarLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<EibarLocalizations> old) => false;
}
