import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../localize/messages_all.dart';

class EibarLocalizations {
  /// Initialize localization systems and messages
  static Future<EibarLocalizations> load(Locale locale) async {
    // If we're given "en_US", we'll use it as-is. If we're
    // given "en", we extract it and use it.
    final String localeName =
        locale.countryCode == null || locale.countryCode == ""
            ? locale.languageCode
            : locale.toString();
    // We make sure the locale name is in the right format e.g.
    // converting "en-US" to "en_US".
    final String canonicalLocaleName = Intl.canonicalizedLocale(localeName);
    // Load localized messages for the current locale.
    await initializeMessages(canonicalLocaleName);
    // We'll uncomment the above line after we've built our messages file
    // Force the locale in Intl.
    Intl.defaultLocale = canonicalLocaleName;
    return EibarLocalizations();
  }

  /// Retrieve localization resources for the widget tree
  /// corresponding to the given `context`
  static EibarLocalizations? of(BuildContext context) =>
      Localizations.of<EibarLocalizations>(context, EibarLocalizations);

  String get promptLogin => Intl.message('Please log in', name: 'promptLogin');
  String get buttonLogin => Intl.message('Log in', name: 'buttonLogin');
  String get labelEmail => Intl.message('e-mail', name: 'labelEmail');
}
